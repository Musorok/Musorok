//
//  GradientButton.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 12.08.2025.
//

import UIKit

final class GradientButton: UIButton {
    private let gradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        layer.cornerRadius = 14
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)

        gradient.colors = [UIColor.systemGreen.cgColor, UIColor(red: 0.0, green: 0.63, blue: 0.43, alpha: 1).cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint   = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(gradient, at: 0)

        // лёгкая тень
        layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}

