//
//  FormInputView.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

final class FormInputView: UIView, UITextFieldDelegate {
    
    private var wasPrefixError = false

    // MARK: Public API
    var text: String? { field.text }             // отформатированный текст (телефон — с +7 и пробелами)
    var rawText: String? { rawValue }            // "сырое" значение: для телефона это 10 цифр без кода страны
    var onTextChange: ((String) -> Void)?
    var isKZPhoneMask: Bool = false              // Включает форматирование телефона

    // MARK: UI
    private let titleLabel = UILabel()
    private let field = PaddedTextField()
    private var eyeButton: UIButton?
    private let isSecure: Bool
    private var rawValue: String?                // хранит "сырое" значение (для телефона — 10 цифр)

    init(title: String,
         placeholder: String,
         keyboard: UIKeyboardType,
         isSecure: Bool,
         isKZPhoneMask: Bool = false) {
        self.isSecure = isSecure
        self.isKZPhoneMask = isKZPhoneMask
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        field.keyboardType = keyboard
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.clearButtonMode = .never
        field.textColor = .label
        field.tintColor = .brandGreen
        field.placeholder = placeholder
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1.5
        field.backgroundColor = .systemBackground
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        if isKZPhoneMask {
            field.attributedPlaceholder = NSAttributedString(
                string: "+7 ___ ___ __ __",
                attributes: [.foregroundColor: UIColor.systemGray3]
            )
        }

        if isSecure {
            field.isSecureTextEntry = true
            let b = UIButton(type: .system)
            b.setImage(UIImage(systemName: "eye"), for: .normal)
            b.tintColor = .tertiaryLabel
            b.addTarget(self, action: #selector(toggleSecure), for: .touchUpInside)
            b.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
            field.rightView = b
            field.rightViewMode = .always
            eyeButton = b
        }

        addSubview(titleLabel)
        addSubview(field)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

            field.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            field.leadingAnchor.constraint(equalTo: leadingAnchor),
            field.trailingAnchor.constraint(equalTo: trailingAnchor),
            field.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        updateColors()
        field.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        field.addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
        field.addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func shake(_ v: UIView) {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.values = [-6, 6, -5, 5, -3, 3, 0]
        anim.duration = 0.35
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        v.layer.add(anim, forKey: "shake")
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    @objc private func toggleSecure() {
        field.isSecureTextEntry.toggle()
        let name = field.isSecureTextEntry ? "eye" : "eye.slash"
        eyeButton?.setImage(UIImage(systemName: name), for: .normal)
    }

    @objc private func editingChanged() {
        if isKZPhoneMask {
            // Переформатируем полностью после любого изменения
            let digits = PhoneFormatter.onlyDigits(from: field.text ?? "")
            let formatted = PhoneFormatter.formatKZ(digits: digits)
            field.text = formatted.text
            rawValue = formatted.nationalDigits // 10 цифр
        }
        onTextChange?(field.text ?? "")
        updateColors()
    }
    @objc private func editingEnded() { updateColors() }
    @objc private func editingBegan() { updateColors() }
    
    func setErrorVisible(_ on: Bool) {
        layer.borderWidth = on ? 1 : 0
        layer.borderColor = on ? UIColor.systemRed.cgColor : nil
    }

    private func updateColors() {
        let hasText = !(field.text?.isEmpty ?? true)
        var border: UIColor = hasText ? .brandGreen : .systemGray4
        var title:  UIColor = hasText ? .brandGreen : .secondaryLabel

        var isPrefixError = false
        if isKZPhoneMask {
            let national = rawValue ?? ""
            if national.count == 10 && !PhoneFormatter.isValidKZMobile(nationalDigits: national) {
                isPrefixError = true
                border = .systemRed
                title  = .systemRed
            }
        }

        // 🔔 Шейк только когда вошли в состояние ошибки (false -> true)
        if isPrefixError && !wasPrefixError {
            shake(field)
        }
        wasPrefixError = isPrefixError

        field.layer.borderColor = border.cgColor
        titleLabel.textColor = title
    }

    // MARK: UITextFieldDelegate
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard isKZPhoneMask else { return true }
        // Делаем "свою" замену: считаем новые цифры и кладём отформатированный текст
        let current = textField.text ?? ""
        let new = (current as NSString).replacingCharacters(in: range, with: string)
        let digits = PhoneFormatter.onlyDigits(from: new)
        let formatted = PhoneFormatter.formatKZ(digits: digits)
        textField.text = formatted.text
        rawValue = formatted.nationalDigits
        onTextChange?(formatted.text)
        updateColors()
        return false // уже выставили текст сами
    }
    
    func setText(_ text: String) {
        if isKZPhoneMask {
            // если инпут телефонный — форматируем как +7 XXX XXX XX XX
            let digits = PhoneFormatter.onlyDigits(from: text)
            let formatted = PhoneFormatter.formatKZ(digits: digits)
            field.text = formatted.text
            rawValue = formatted.nationalDigits
        } else {
            // обычный текст (адрес и т.п.)
            field.text = text
            rawValue = text
        }
        onTextChange?(field.text ?? "")
        updateColors()
    }
}

// UITextField с паддингами
final class PaddedTextField: UITextField {
    private let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
    override func textRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: insets) }
    override func editingRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: insets) }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: insets) }
}
