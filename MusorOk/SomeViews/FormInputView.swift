//
//  FormInputView.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

final class FormInputView: UIView, UITextFieldDelegate {

    // Публичные API
    var text: String? { field.text }
    var onTextChange: ((String) -> Void)?

    // UI
    private let titleLabel = UILabel()
    private let field = PaddedTextField()
    private var eyeButton: UIButton?
    private let isSecure: Bool

    init(title: String,
         placeholder: String,
         keyboard: UIKeyboardType,
         isSecure: Bool) {
        self.isSecure = isSecure
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
        field.textColor = .label                // всегда черный/системный
        field.tintColor = .brandGreen
        field.placeholder = placeholder
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1.5
        field.backgroundColor = .systemBackground
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        field.heightAnchor.constraint(equalToConstant: 54).isActive = true

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

        // стартовое состояние
        updateColors()
        field.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        field.addTarget(self, action: #selector(editingEnded), for: .editingDidEnd)
        field.addTarget(self, action: #selector(editingBegan), for: .editingDidBegin)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggleSecure() {
        field.isSecureTextEntry.toggle()
        let name = field.isSecureTextEntry ? "eye" : "eye.slash"
        eyeButton?.setImage(UIImage(systemName: name), for: .normal)
    }

    @objc private func editingChanged() {
        onTextChange?(field.text ?? "")
        updateColors()
    }
    @objc private func editingEnded() { updateColors() }
    @objc private func editingBegan() { updateColors() }

    private func updateColors() {
        let hasText = !(field.text?.isEmpty ?? true)
        // Цвет бордера и заголовка: серый если пусто, зелёный если заполнено
        let border: UIColor = hasText ? .brandGreen : .systemGray4
        let title: UIColor  = hasText ? .brandGreen : .secondaryLabel

        field.layer.borderColor = border.cgColor
        titleLabel.textColor = title
    }
}

// Внутренний UITextField с паддингом
final class PaddedTextField: UITextField {
    private let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)

    override func textRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: insets) }
    override func editingRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: insets) }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: insets) }
}

