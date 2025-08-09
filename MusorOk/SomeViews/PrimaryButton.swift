//
//  PrimaryButton.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

final class PrimaryButton: UIButton {
    override var isEnabled: Bool { didSet { applyStyle() } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configuration = .filled()
        configuration?.cornerStyle = .large
        titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        applyStyle()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func applyStyle() {
        if isEnabled {
            configuration?.baseBackgroundColor = .brandGreen
            configuration?.baseForegroundColor = .white
        } else {
            configuration?.baseBackgroundColor = .systemGray5
            configuration?.baseForegroundColor = .systemGray
        }
    }
}

