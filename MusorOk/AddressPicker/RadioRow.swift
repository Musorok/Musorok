//
//  RadioRow.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 11.08.2025.
//

import UIKit

final class RadioRow: UIControl {
    private let dot = UIView()
    private let ring = UIView()
    private let title = UILabel()
    private let icon = UIView()              // ← делаем полем

    var onTap: (() -> Void)?
    var isOn: Bool = false { didSet { updateUI() } }

    init(title: String, isOn: Bool) {
        super.init(frame: .zero)
        self.title.text = title
        self.isOn = isOn
        build()
        addTarget(self, action: #selector(tap), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError() }

    // публичный сеттер названия
    func setTitle(_ text: String) { title.text = text }

    private func build() {
        translatesAutoresizingMaskIntoConstraints = false

        title.font = .systemFont(ofSize: 17)
        title.textColor = .label
        title.numberOfLines = 0
        title.translatesAutoresizingMaskIntoConstraints = false

        ring.translatesAutoresizingMaskIntoConstraints = false
        ring.layer.cornerRadius = 12
        ring.layer.borderWidth = 2

        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.layer.cornerRadius = 6

        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.addSubview(ring)
        icon.addSubview(dot)

        // ВАЖНО: все сабвью не перехватывают тапы — кликабелен весь контрол
        icon.isUserInteractionEnabled = false
        title.isUserInteractionEnabled = false

        addSubview(icon)
        addSubview(title)

        NSLayoutConstraint.activate([
            ring.widthAnchor.constraint(equalToConstant: 24),
            ring.heightAnchor.constraint(equalToConstant: 24),
            ring.centerXAnchor.constraint(equalTo: icon.centerXAnchor),
            ring.centerYAnchor.constraint(equalTo: icon.centerYAnchor),

            dot.widthAnchor.constraint(equalToConstant: 12),
            dot.heightAnchor.constraint(equalToConstant: 12),
            dot.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
            dot.centerYAnchor.constraint(equalTo: ring.centerYAnchor),

            icon.leadingAnchor.constraint(equalTo: leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: title.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 28),
            icon.heightAnchor.constraint(equalToConstant: 28),

            // между кружком и текстом пусть останется 5 pt — хорошо читается
            title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 5),
            title.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            title.trailingAnchor.constraint(equalTo: trailingAnchor),
            title.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])

        updateUI()
    }

    private func updateUI() {
        ring.layer.borderColor = (isOn ? UIColor.brandGreen : UIColor.label).cgColor
        dot.backgroundColor = isOn ? .brandGreen : .clear
        dot.isHidden = !isOn
        title.textColor = isOn ? .label : .secondaryLabel
    }

    // Чуть расширим хит-бокс (чтобы промахов было меньше)
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inset: CGFloat = -8
        let larger = bounds.insetBy(dx: inset, dy: inset)
        return larger.contains(point)
    }

    @objc private func tap() { onTap?() }
}
