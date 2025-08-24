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
    var isKZPhoneMask: Bool = false
    private let titleActiveColor: UIColor?

    // MARK: UI
    private let titleLabel = UILabel()
    private let field = PaddedTextField()
    private var eyeButton: UIButton?
    private var clearButton: UIButton?

    // MARK: Config
    private let isSecure: Bool
    private let showsClearButton: Bool
    private var rawValue: String?                // хранит "сырое" значение (для телефона — 10 цифр)

    // MARK: Init
    init(title: String,
         placeholder: String,
         keyboard: UIKeyboardType,
         isSecure: Bool,
         isKZPhoneMask: Bool = false,
         showsClearButton: Bool = false,
         titleActiveColor: UIColor? = nil) {

        self.isSecure = isSecure
        self.isKZPhoneMask = isKZPhoneMask
        self.showsClearButton = showsClearButton
        self.titleActiveColor = titleActiveColor
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // TextField
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

        // Right view: приоритет у "глаза" (secure). Если не secure — можно показать кнопку очистки.
        if isSecure {
            let b = UIButton(type: .system)
            b.setImage(UIImage(systemName: "eye"), for: .normal)
            b.tintColor = .tertiaryLabel
            b.addTarget(self, action: #selector(toggleSecure), for: .touchUpInside)
            b.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            b.contentEdgeInsets = .zero
            field.rightView = b
            field.rightViewMode = .always
            eyeButton = b
        } else if showsClearButton {
            let b = UIButton(type: .system)
            b.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            b.tintColor = .tertiaryLabel
            b.addTarget(self, action: #selector(clearText), for: .touchUpInside)
            b.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            b.contentEdgeInsets = .zero
            field.rightView = b
            field.rightViewMode = .always
            clearButton = b
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

    // MARK: - Actions
    @objc private func toggleSecure() {
        field.isSecureTextEntry.toggle()
        let name = field.isSecureTextEntry ? "eye" : "eye.slash"
        eyeButton?.setImage(UIImage(systemName: name), for: .normal)
    }

    @objc private func clearText() {
        field.text = ""
        rawValue = nil
        onTextChange?("")
        updateColors()
    }

    // MARK: - UI Feedback
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

    // MARK: - Colors / State
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
        let activeTitle = titleActiveColor ?? .brandGreen
        var border: UIColor = hasText ? .brandGreen : .systemGray4
        var title:  UIColor = hasText ? activeTitle : .secondaryLabel

        var isPrefixError = false
        if isKZPhoneMask {
            let national = rawValue ?? ""
            if national.count == 10 && !PhoneFormatter.isValidKZMobile(nationalDigits: national) {
                isPrefixError = true
                border = .systemRed
                title  = .systemRed
            }
        }

        // Шейк только при входе в ошибку
        if isPrefixError && !wasPrefixError { shake(field) }
        wasPrefixError = isPrefixError
        
        if let clear = clearButton {
            clear.isUserInteractionEnabled = hasText
            clear.alpha = hasText ? 1.0 : 0.4
        }

        field.layer.borderColor = border.cgColor
        titleLabel.textColor = title
    }

    // MARK: UITextFieldDelegate
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard isKZPhoneMask else { return true }
        // своя замена с форматированием
        let current = textField.text ?? ""
        let new = (current as NSString).replacingCharacters(in: range, with: string)
        let digits = PhoneFormatter.onlyDigits(from: new)
        let formatted = PhoneFormatter.formatKZ(digits: digits)
        textField.text = formatted.text
        rawValue = formatted.nationalDigits
        onTextChange?(formatted.text)
        updateColors()
        return false
    }

    func setText(_ text: String) {
        if isKZPhoneMask {
            let digits = PhoneFormatter.onlyDigits(from: text)
            let formatted = PhoneFormatter.formatKZ(digits: digits)
            field.text = formatted.text
            rawValue = formatted.nationalDigits
        } else {
            field.text = text
            rawValue = text
        }
        onTextChange?(field.text ?? "")
        updateColors()
    }
}

// MARK: - UITextField с динамическими паддингами под rightView
final class PaddedTextField: UITextField {
    private let baseInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
    private let rightPadding: CGFloat = 5            // ⬅️ Ровно 5 pt от правого края
    private let gapTextToRightView: CGFloat = 6      // зазор между текстом и иконкой
    private let rightViewSize: CGFloat = 24          // размер кнопок X/eye

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let size = rightViewSize
        let y = (bounds.height - size) / 2.0
        // Кнопка стоит в 5 pt от правого края поля
        return CGRect(x: bounds.width - size - rightPadding, y: y, width: size, height: size)
    }

    private func adjustedInsets() -> UIEdgeInsets {
        var i = baseInsets
        if rightView != nil, rightViewMode != .never {
            // Сдвигаем правый инсет так, чтобы текст не попадал под иконку
            let needed = rightPadding + rightViewSize + gapTextToRightView
            i.right = max(i.right, needed)
        }
        return i
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: adjustedInsets()) }
    override func editingRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: adjustedInsets()) }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: adjustedInsets()) }
}
