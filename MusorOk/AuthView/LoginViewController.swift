//
//  LoginViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

final class LoginViewController: UIViewController {

    private let phoneField = FormInputView(title: "Телефон", placeholder: "", keyboard: .numberPad, isSecure: false, isKZPhoneMask: true)
    private let passwordField = FormInputView(title: "Пароль", placeholder: "", keyboard: .default, isSecure: true)
    private let loginButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Войти", for: .normal)
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layout()

        phoneField.onTextChange = { [weak self] _ in self?.validate() }
        passwordField.onTextChange = { [weak self] _ in self?.validate() }
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
    }

    private func layout() {
        view.addSubview(phoneField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)

        NSLayoutConstraint.activate([
            phoneField.topAnchor.constraint(equalTo: view.topAnchor), // контейнер задаёт отступы
            phoneField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            phoneField.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            passwordField.topAnchor.constraint(equalTo: phoneField.bottomAnchor, constant: 18),
            passwordField.leadingAnchor.constraint(equalTo: phoneField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: phoneField.trailingAnchor),

            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 28),
            loginButton.leadingAnchor.constraint(equalTo: phoneField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: phoneField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 56),
            loginButton.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }

    private func validate() {
        let national = phoneField.rawText ?? ""
        let okPhone = PhoneFormatter.isValidKZMobile(nationalDigits: national)
        let ok = okPhone && !(passwordField.text?.isEmpty ?? true)
        loginButton.isEnabled = ok
    }
    
    @objc private func loginTapped() {
        view.endEditing(true)
        loginButton.isEnabled = false

        let national10 = phoneField.rawText ?? ""     // 10 цифр после +7
        let password = passwordField.text ?? ""

        // Простейший лоадер на кнопке
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor)
        ])

        AuthService.login(phoneNational10: national10, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                spinner.removeFromSuperview()
                switch result {
                case .success(let resp):
                    // сохраняем токен в Keychain и сообщаем приложению, что авторизованы
                    AuthManager.shared.setToken(resp.token, userId: resp.user)
                    let national10 = self.phoneField.rawText ?? ""
                    AuthManager.shared.setPhoneNational10(national10)

                case .failure(let err):
                    self.loginButton.isEnabled = true
                    let alert = UIAlertController(title: "Ошибка входа",
                                                  message: err.localizedDescription,
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

}
