//
//  AuthViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

final class AuthViewController: UIViewController {

    private let topSegment = UISegmentedControl(items: ["Вход", "Регистрация"])
    private let underline = UIView()

    private let phoneField = FormInputView(title: "Телефон",
                                           placeholder: "",
                                           keyboard: .numberPad,
                                           isSecure: false)

    private let passwordField = FormInputView(title: "Пароль",
                                              placeholder: "",
                                              keyboard: .default,
                                              isSecure: true)

    private let forgotButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Забыли пароль", for: .normal)
        b.setTitleColor(.secondaryLabel, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular)
        b.contentHorizontalAlignment = .right
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let loginButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Войти", for: .normal)
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private var underlineLeading: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Заказы"
        view.backgroundColor = .systemBackground
        setupSegment()
        layout()
        hookValidation()
    }

    private func setupSegment() {
        topSegment.selectedSegmentIndex = 0
        topSegment.selectedSegmentTintColor = .clear
        topSegment.setTitleTextAttributes([.foregroundColor: UIColor.label,
                                           .font: UIFont.systemFont(ofSize: 18, weight: .semibold)], for: .normal)
        topSegment.translatesAutoresizingMaskIntoConstraints = false
        topSegment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        underline.backgroundColor = .brandGreen
        underline.translatesAutoresizingMaskIntoConstraints = false
    }

    private func layout() {
        view.addSubview(topSegment)
        view.addSubview(underline)
        view.addSubview(phoneField)
        view.addSubview(passwordField)
        view.addSubview(forgotButton)
        view.addSubview(loginButton)

        let guide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            topSegment.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12),
            topSegment.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            topSegment.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),

            underline.topAnchor.constraint(equalTo: topSegment.bottomAnchor, constant: 8),
            underline.heightAnchor.constraint(equalToConstant: 3),
            underline.widthAnchor.constraint(equalTo: topSegment.widthAnchor, multiplier: 0.5),

            phoneField.topAnchor.constraint(equalTo: underline.bottomAnchor, constant: 28),
            phoneField.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            phoneField.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),

            passwordField.topAnchor.constraint(equalTo: phoneField.bottomAnchor, constant: 18),
            passwordField.leadingAnchor.constraint(equalTo: phoneField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: phoneField.trailingAnchor),

            forgotButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 8),
            forgotButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor),

            loginButton.topAnchor.constraint(equalTo: forgotButton.bottomAnchor, constant: 28),
            loginButton.leadingAnchor.constraint(equalTo: phoneField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: phoneField.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        // underline position (под выбранной вкладкой)
        underlineLeading = underline.leadingAnchor.constraint(equalTo: topSegment.leadingAnchor)
        underlineLeading.isActive = true
    }

    @objc private func segmentChanged() {
        let half = topSegment.bounds.width / 2
        underlineLeading.constant = topSegment.isLeftToRight ? 0 : 0 // для корректности направления
        UIView.animate(withDuration: 0.25) {
            self.underlineLeading.constant = (self.topSegment.selectedSegmentIndex == 0) ? 0 : half
            self.view.layoutIfNeeded()
        }
        // при переключении можно показать экран регистрации, сейчас оставляем логин
    }

    private func hookValidation() {
        phoneField.onTextChange = { [weak self] _ in self?.validate() }
        passwordField.onTextChange = { [weak self] _ in self?.validate() }
    }

    private func validate() {
        let ok = !(phoneField.text?.isEmpty ?? true) && !(passwordField.text?.isEmpty ?? true)
        loginButton.isEnabled = ok
    }
}

private extension UISegmentedControl {
    var isLeftToRight: Bool { UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight }
}

