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
        // Подготовим данные
        let phoneE164 = "+7" + (phoneField.rawText ?? "") // 10 цифр нац. части
        let password = passwordField.text ?? ""
        
        loginButton.isEnabled = false
        
        // Вызов вашего API. Здесь заглушка успеха:
        // AuthAPI.login(phone: phoneE164, password: password) { [weak self] result in ... }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.parent?.view.endEditing(true)
            (self.parent as? AuthContainerViewController)?.delegate?.authDidSucceed()
        }
    }
}
