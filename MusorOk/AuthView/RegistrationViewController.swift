//
//  RegistrationViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import UIKit

final class RegistrationViewController: UIViewController {

    private let phoneField = FormInputView(
        title: "Телефон",
        placeholder: "",
        keyboard: .numberPad,
        isSecure: false,
        isKZPhoneMask: true
    )

    private let sendCodeButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Отправить код", for: .normal)
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let checkBox = CheckBox()
    private let agreementLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 15)
        l.translatesAutoresizingMaskIntoConstraints = false

        let base = NSMutableAttributedString(
            string: "Соглашаюсь со следующими документами: ",
            attributes: [.foregroundColor: UIColor.label]
        )
        let green: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.brandGreen,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        base.append(NSAttributedString(string: "Регламент использования системы", attributes: green))
        base.append(NSAttributedString(string: ", а также ", attributes: [.foregroundColor: UIColor.label]))
        base.append(NSAttributedString(string: "Обработка персональных данных, включая геолокацию", attributes: green))
        l.attributedText = base
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Регистрация"

        checkBox.translatesAutoresizingMaskIntoConstraints = false  // важно!
            layoutWithStacks()
        phoneField.onTextChange = { [weak self] _ in self?.validateForm() }
        checkBox.addTarget(self, action: #selector(validateForm), for: .valueChanged)
        sendCodeButton.addTarget(self, action: #selector(sendCodeTapped), for: .touchUpInside)
    }

    private func layoutWithStacks() {
        // Горизонтальная строка: чекбокс + текст
        let agreementRow = UIStackView(arrangedSubviews: [checkBox, agreementLabel])
        agreementRow.axis = .horizontal
        agreementRow.alignment = .top
        agreementRow.spacing = 12
        agreementRow.translatesAutoresizingMaskIntoConstraints = false

        // Вертикальный стек всего экрана
        let vstack = UIStackView(arrangedSubviews: [phoneField, sendCodeButton, agreementRow])
        vstack.axis = .vertical
        vstack.spacing = 16
        vstack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(vstack)

        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: view.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vstack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),

            sendCodeButton.heightAnchor.constraint(equalToConstant: 56),
            checkBox.widthAnchor.constraint(equalToConstant: 28),
            checkBox.heightAnchor.constraint(equalToConstant: 28)
        ])

        // Чтобы длинный текст соглашения не «толкал» чекбокс
        agreementLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    @objc private func validateForm() {
        let national = phoneField.rawText ?? ""
        let isValidPhone = PhoneFormatter.isValidKZMobile(nationalDigits: national)
        sendCodeButton.isEnabled = isValidPhone && checkBox.isChecked
    }
    
    @objc private func sendCodeTapped() {
        view.endEditing(true)

        // то, что показываем пользователю
        let formattedPhone = phoneField.text ?? ""
        // «чистые» 10 цифр (национальная часть) — пригодится бэку
        let national10 = phoneField.rawText ?? ""

        // экран ввода кода
        let vc = CodeConfirmViewController(phone: formattedPhone)

        // отправка повторного кода (потом дернёшь свой эндпоинт)
        vc.onResend = {
            // AuthService.sendCode(phoneNational10: national10) { _ in }
        }

        // верификация 4-значного кода (здесь дергай бэк)
        vc.onVerify = { [weak self] code in
            guard let self = self else { return }
            // AuthService.verifyCode(phoneNational10: national10, code: code) { result in
            //   switch result {
            //   case .success(let resp):
            //       AuthManager.shared.setToken(resp.token, userId: resp.user)
            //       AuthManager.shared.setDisplayName(/* имя из формы регистрации */)
            //   case .failure(let err):
            //       // показать алерт
            //   }
            // }
        }

        // пушим
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            // на случай, если это child VC в контейнере
            (self.parent as? AuthContainerViewController)?
                .navigationController?.pushViewController(vc, animated: true)
        }
    }

}
