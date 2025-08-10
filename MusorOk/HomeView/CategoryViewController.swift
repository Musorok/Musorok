//
//  CategoryViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

enum CategoryKind {
    case household, construction, cleaning

    var titleText: String {
        switch self {
        case .household:    return "Выбросим мусор из квартиры за вас!"
        case .construction: return "Вывоз строительного мусора"
        case .cleaning:     return "Клининг и вынос мусора"
        }
    }

    var buttonTitle: String {
        switch self {
        case .household:    return "Вынести мусор"
        case .construction: return "Оформить вывоз"
        case .cleaning:     return "Заказать клининг"
        }
    }
}

final class CategoryViewController: UIViewController {
    private let kind: CategoryKind

    init(kind: CategoryKind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let actionButton: PrimaryButton = {
        let b = PrimaryButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // пример “карточки” с временем работы
    private let scheduleCard = ScheduleCardView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16

        titleLabel.text = kind.titleText
        actionButton.setTitle(kind.buttonTitle, for: .normal)
        actionButton.addTarget(self, action: #selector(tap), for: .touchUpInside)

        layout()
    }

    private func layout() {
        view.addSubview(titleLabel)
        view.addSubview(actionButton)
        view.addSubview(scheduleCard)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            scheduleCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scheduleCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            actionButton.heightAnchor.constraint(equalToConstant: 56),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            actionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

    @objc private func tap() {
        guard kind == .household else { return }
        let vc = AddressPickerViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
