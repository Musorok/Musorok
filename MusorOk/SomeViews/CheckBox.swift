//
//  CheckBox.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import UIKit

final class CheckBox: UIControl {
    private let imageView = UIImageView()
    var isChecked: Bool = false { didSet { update() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
        update()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func toggle() {
        isChecked.toggle()
        sendActions(for: .valueChanged)
    }
    private func update() {
        imageView.tintColor = isChecked ? .brandGreen : .label
        imageView.image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
    }
}
