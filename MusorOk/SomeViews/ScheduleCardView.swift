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

import UIKit

final class ScheduleCardView: UIView {

    var accentColor: UIColor = .brandGreen {
        didSet { everyDay.textColor = accentColor }
    }

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

    private let everyDay: UILabel = {
        let l = UILabel()
        l.text = "Каждый день"
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .brandGreen
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .tertiarySystemBackground
        layer.cornerRadius = 14
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(title)
        addSubview(timeLabel)
        addSubview(everyDay)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            title.centerXAnchor.constraint(equalTo: centerXAnchor),

            timeLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            everyDay.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            everyDay.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            everyDay.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

