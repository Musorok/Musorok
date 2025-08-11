//
//  RegistrationExtraInfoViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 11.08.2025.
//

import UIKit

final class RegistrationExtraInfoViewController: UIViewController {
    
    private let phoneNational10: String

    // MARK: UI
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .label
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Доп. информация"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameField = FormInputView(title: "Представьтесь", placeholder: "", keyboard: .default, isSecure: false)
    private let passwordField = FormInputView(title: "Придумайте пароль*", placeholder: "", keyboard: .default, isSecure: true)
    private let repeatPasswordField = FormInputView(title: "Повторите пароль*", placeholder: "", keyboard: .default, isSecure: true)
    private let emailField = FormInputView(title: "Электронная почта*", placeholder: "", keyboard: .emailAddress, isSecure: false)

    private let registerButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Зарегистрироваться", for: .normal)
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // простой лоадер по центру
    private lazy var loader: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .large)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    init(phoneNational10: String) {
        self.phoneNational10 = phoneNational10
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()

        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)

        // валидация на ввод
        nameField.onTextChange = { [weak self] _ in self?.validate() }
        passwordField.onTextChange = { [weak self] _ in self?.validate() }
        repeatPasswordField.onTextChange = { [weak self] _ in self?.validate() }
        emailField.onTextChange = { [weak self] _ in self?.validate() }
    }

    private func layout() {
        [backButton, titleLabel, nameField, passwordField, repeatPasswordField, emailField, registerButton, loader]
            .forEach { view.addSubview($0); $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),

            titleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            nameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            passwordField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 18),
            passwordField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),

            repeatPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 18),
            repeatPasswordField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            repeatPasswordField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),

            emailField.topAnchor.constraint(equalTo: repeatPasswordField.bottomAnchor, constant: 18),
            emailField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),

            registerButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 28),
            registerButton.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 56),

            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func back() { navigationController?.popViewController(animated: true) }

    private func validate() {
        let nameOK = !(nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let p1 = passwordField.text ?? ""
        let p2 = repeatPasswordField.text ?? ""
        let passOK = p1.count >= 6 && p1 == p2
        let mail = emailField.text ?? ""
        let mailOK = isValidEmail(mail)

        registerButton.isEnabled = nameOK && passOK && mailOK

        // подсветка ошибок (мягко)
        repeatPasswordField.setErrorVisible(!p1.isEmpty && !p2.isEmpty && p1 != p2)
    }

    private func isValidEmail(_ s: String) -> Bool {
        // простая проверка
        let regex = #"^\S+@\S+\.\S+$"#
        return s.range(of: regex, options: .regularExpression) != nil
    }

    @objc private func registerTapped() {
        view.endEditing(true)
        registerButton.isEnabled = false
        loader.startAnimating()

        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text ?? ""

        AuthService.register(email: email,
                             name: name,
                             password: password,
                             phoneNational10: phoneNational10) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.loader.stopAnimating()

                switch result {
                case .success(let resp):
                    guard let token = resp.token, let userId = resp.user else {
                        self.showError("Некорректный ответ сервера"); self.registerButton.isEnabled = true; return
                    }

                    // ✅ сохраняем имя для приветствия
                    let name = self.nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    if !name.isEmpty { AuthManager.shared.setDisplayName(name) }
                    let email = self.emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    AuthManager.shared.setDisplayName(name)
                    AuthManager.shared.setEmail(email)
                    AuthManager.shared.setPhoneNational10(self.phoneNational10)

                    // сохраняем токен
                    AuthManager.shared.setToken(token, userId: userId)

                    // вернёмся к корню; таббар сам переключит «Заказы», а «Профиль» прочитает имя
                    self.navigationController?.popToRootViewController(animated: true)

                case .failure(let err):
                    self.showError(err.localizedDescription)
                    self.registerButton.isEnabled = true
                }
            }
        }
    }

    private func showError(_ msg: String) {
        let a = UIAlertController(title: "Ошибка", message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

