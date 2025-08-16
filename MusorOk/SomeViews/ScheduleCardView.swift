//
//  ScheduleCardView.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

//import UIKit
//
//final class ScheduleCardView: UIView {
//    private let title: UILabel = {
//        let l = UILabel()
//        l.text = "Мы принимаем заказы"
//        l.font = .systemFont(ofSize: 14, weight: .semibold)
//        l.textColor = .secondaryLabel
//        l.translatesAutoresizingMaskIntoConstraints = false
//        return l
//    }()
//
//    private let timeLabel: UILabel = {
//        let l = UILabel()
//        l.text = "9:00 — 21:00"
//        l.font = .monospacedDigitSystemFont(ofSize: 24, weight: .bold)
//        l.textColor = .label
//        l.translatesAutoresizingMaskIntoConstraints = false
//        return l
//    }()
//
//    private let everyDay: UILabel = {
//        let l = UILabel()
//        l.text = "Каждый день"
//        l.font = .systemFont(ofSize: 14, weight: .semibold)
//        l.textColor = .brandGreen
//        l.translatesAutoresizingMaskIntoConstraints = false
//        return l
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .tertiarySystemBackground
//        layer.cornerRadius = 14
//        translatesAutoresizingMaskIntoConstraints = false
//
//        addSubview(title)
//        addSubview(timeLabel)
//        addSubview(everyDay)
//
//        NSLayoutConstraint.activate([
//            title.topAnchor.constraint(equalTo: topAnchor, constant: 14),
//            title.centerXAnchor.constraint(equalTo: centerXAnchor),
//
//            timeLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
//            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//
//            everyDay.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
//            everyDay.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
//            everyDay.centerXAnchor.constraint(equalTo: centerXAnchor)
//        ])
//    }
//
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//}

// ScheduleCardView.swift
// MusorOk
//
// Обновлено: поддержка accentColor для строки "Каждый день".

//  ScheduleCardView.swift
//  MusorOk

import UIKit

final class ScheduleCardView: UIView {

    // Какой градиент рисовать
    enum Mode { case household, construction, cleaning }

    var mode: Mode = .household { didSet { updateGradient() } }

    // Акцентный цвет для текста "Каждый день"
    var accentColor: UIColor = .brandGreen {
        didSet { everyDay.textColor = accentColor }
    }

    // MARK: - UI

    private let title: UILabel = {
        let l = UILabel()
        l.text = "Мы принимаем заказы"
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.text = "9:00 — 21:00"
        l.font = .monospacedDigitSystemFont(ofSize: 24, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // иконка часов слева от времени
    private let clockIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "clock")?.withRenderingMode(.alwaysTemplate))
        iv.tintColor = .label
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // горизонтальный ряд: [clock] [time]
    private let timeRow: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 6
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private let everyDay: UILabel = {
        let l = UILabel()
        l.text = "Каждый день"
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .brandGreen
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Градиентный фон
    private let gradientLayer = CAGradientLayer()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.cornerRadius = 14
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        // слой-градиент под контент
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 14
        layer.insertSublayer(gradientLayer, at: 0)

        // контент
        addSubview(title)
        addSubview(timeRow)
        addSubview(everyDay)

        timeRow.addArrangedSubview(clockIcon)
        timeRow.addArrangedSubview(timeLabel)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            title.centerXAnchor.constraint(equalTo: centerXAnchor),

            timeRow.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            timeRow.centerXAnchor.constraint(equalTo: centerXAnchor),

            clockIcon.widthAnchor.constraint(equalToConstant: 18),
            clockIcon.heightAnchor.constraint(equalToConstant: 18),

            everyDay.topAnchor.constraint(equalTo: timeRow.bottomAnchor, constant: 8),
            everyDay.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            everyDay.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        // стартовый вид
        updateGradient()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }

    // MARK: - Gradient

    private func updateGradient() {
        let start: UIColor
        let end: UIColor

        switch mode {
        case .household:
            // зелёный — как у сегмента, но лёгкий градиент
            start = UIColor.brandGreen.lightened(0.90)
            end   = UIColor.brandGreen.lightened(0.97)
        case .construction:
            // оранжевый
            start = UIColor.brandOrange.lightened(0.90)
            end   = UIColor.brandOrange.lightened(0.97)
        case .cleaning:
            // голубой/teal
            start = UIColor.brandTeal.lightened(0.90)
            end   = UIColor.brandTeal.lightened(0.97)
        }

        gradientLayer.colors = [start.cgColor, end.cgColor]
    }
}

// MARK: - Helpers

private extension UIColor {
    /// Осветлить цвет, смешав с белым (0...1)
    func lightened(_ fraction: CGFloat) -> UIColor {
        var r: CGFloat = 1, g: CGFloat = 1, b: CGFloat = 1, a: CGFloat = 1
        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            // если цвет в другой цветовой модели — просто уменьшим альфу
            return withAlphaComponent(0.08)
        }
        let f = min(max(fraction, 0), 1)
        return UIColor(red: r + (1 - r) * f,
                       green: g + (1 - g) * f,
                       blue: b + (1 - b) * f,
                       alpha: 1)
    }
}
