//
//  ProfileEditViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 12.08.2025.
//

import UIKit

final class ProfileEditViewController: UIViewController {
    
    private struct UpdateProfileRequest: Encodable {
        let email: String
        let name: String
    }

    // MARK: - UI
    private let scroll = UIScrollView()
    private let stack = UIStackView()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Мои данные"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        return l
    }()

    private let nameField = FormInputView(title: "Ваше имя", placeholder: "", keyboard: .default, isSecure: false)
    private let phoneField = FormInputView(title: "Телефон", placeholder: "", keyboard: .numberPad, isSecure: false, isKZPhoneMask: true)
    private let emailField = FormInputView(title: "Электронная почта*", placeholder: "", keyboard: .emailAddress, isSecure: false)
    private let passwordField = FormInputView(title: "Пароль", placeholder: "********", keyboard: .default, isSecure: true)

    // маленький “карандаш” у пароля (пока без логики смены пароля)
    private let editPasswordButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "pencil"), for: .normal)
        b.tintColor = .tertiaryLabel
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let saveButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Сохранить", for: .normal)
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // исходные значения для сравнения при валидации
    private var initialName: String = ""
    private var initialEmail: String = ""
    private var initialPhone: String = ""

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        buildLayout()
        fillInitialData()
        wire()
        validate()
    }

    // MARK: - Layout
    private func buildLayout() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scroll)
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -120),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(nameField)
        stack.addArrangedSubview(phoneField)
        stack.addArrangedSubview(emailField)

        // пароль + карандаш
        let passwordContainer = UIView()
        passwordContainer.translatesAutoresizingMaskIntoConstraints = false
        passwordContainer.addSubview(passwordField)
        passwordContainer.addSubview(editPasswordButton)

        passwordField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordField.topAnchor.constraint(equalTo: passwordContainer.topAnchor),
            passwordField.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor),
            passwordField.bottomAnchor.constraint(equalTo: passwordContainer.bottomAnchor),

            editPasswordButton.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor, constant: -12),
            editPasswordButton.centerYAnchor.constraint(equalTo: passwordField.centerYAnchor),
            editPasswordButton.widthAnchor.constraint(equalToConstant: 24),
            editPasswordButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        stack.addArrangedSubview(passwordContainer)

        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            saveButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        // телефон и пароль — read-only (серые как на макете)
        setReadOnly(phoneField, true)
        setReadOnly(passwordField, true)
    }

    private func setReadOnly(_ field: UIView, _ ro: Bool) {
        field.isUserInteractionEnabled = !ro
        field.alpha = ro ? 0.6 : 1.0
    }

    // MARK: - Data
    private func fillInitialData() {
        // подтягиваем из твоего AuthManager/хранилища если есть
        initialName  = AuthManager.shared.displayName ?? ""
        initialEmail = AuthManager.shared.email ?? ""
        initialPhone = AuthManager.shared.phoneNational10 ?? ""   // 10 цифр без +7

        nameField.setText(initialName)
        emailField.setText(initialEmail)

        // покажем телефон в маске +7 ___ ___ __ __
        if initialPhone.count == 10 {
            let masked = PhoneFormatter.formatNational10ToKZMasked(initialPhone) // у тебя уже есть форматтер
            phoneField.setText(masked)
        } else {
            phoneField.setText("")
        }
    }

    // MARK: - Actions
    private func wire() {
        nameField.onTextChange = { [weak self] _ in self?.validate() }
        emailField.onTextChange = { [weak self] _ in self?.validate() }
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        editPasswordButton.addTarget(self, action: #selector(editPasswordTapped), for: .touchUpInside)
    }

    @objc private func editPasswordTapped() {
        // тут можешь пушнуть ChangePasswordViewController
        let alert = UIAlertController(title: "Пароль",
                                      message: "Смена пароля будет добавлена позже.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    @objc private func saveTapped() {
        view.endEditing(true)

        let newName  = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let newEmail = (emailField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let body = UpdateProfileRequest(email: newEmail, name: newName)

        // Блокируем кнопку на время запроса
        saveButton.isEnabled = false

        APIClient.shared.put("/profile", body: body, requiresAuth: true) { (result: Result<MessageResponse, APIError>) in
            switch result {
            case .success:
                // локально обновим кэш профиля
                AuthManager.shared.setDisplayName(newName)
                AuthManager.shared.setEmail(newEmail)

                self.initialName = newName
                self.initialEmail = newEmail
                self.validate()

                let ac = UIAlertController(title: "Сохранено", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                self.present(ac, animated: true)

            case .failure(let err):
                self.saveButton.isEnabled = true
                let msg: String
                switch err {
                case .server(let m, _): msg = m
                case .network(let e):   msg = e.localizedDescription
                default:                msg = "Не удалось сохранить. Попробуйте ещё раз."
                }
                let ac = UIAlertController(title: "Ошибка", message: msg, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }
    }

    // MARK: - Validation
    private func validate() {
        let nameOK = !(nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let emailOK = isValidEmail(emailField.text ?? "")

        let changed = (nameField.text ?? "") != initialName ||
                      (emailField.text ?? "") != initialEmail

        saveButton.isEnabled = nameOK && emailOK && changed
    }

    private func isValidEmail(_ s: String) -> Bool {
        // простой валидатор
        let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES[c] %@", regex).evaluate(with: s)
    }
}

