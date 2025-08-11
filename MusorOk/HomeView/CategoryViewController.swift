

//import UIKit
//
//enum CategoryKind {
//    case household, construction, cleaning
//
//    var titleText: String {
//        switch self {
//        case .household:    return "Выбросим мусор из квартиры за вас!"
//        case .construction: return "Вывоз строительного мусора"
//        case .cleaning:     return "Клининг и вынос мусора"
//        }
//    }
//
//    var buttonTitle: String {
//        switch self {
//        case .household:    return "Вынести мусор"
//        case .construction: return "Оформить вывоз"
//        case .cleaning:     return "Заказать клининг"
//        }
//    }
//
//    /// Имя ассета для баннера. Если ассета нет — баннер схлопнется.
//    var bannerAssetName: String? {
//        switch self {
//        case .household:    return "homeMusor"
//        case .construction: return "stroitelMusor"
//        case .cleaning:     return "cleaning" // добавь ассет при необходимости
//        }
//    }
//
//    var accentColor: UIColor {
//        switch self {
//        case .household:    return .brandGreen
//        case .construction: return .brandOrange
//        case .cleaning:     return .brandTeal
//        }
//    }
//}
//
//final class CategoryViewController: UIViewController {
//
//    private let kind: CategoryKind
//
//    // MARK: - UI
//
//    private let titleLabel: UILabel = {
//        let l = UILabel()
//        l.numberOfLines = 0
//        l.font = .systemFont(ofSize: 28, weight: .bold)
//        l.textColor = .label
//        l.translatesAutoresizingMaskIntoConstraints = false
//        return l
//    }()
//
//    private let scheduleCard = ScheduleCardView()
//
//    private let bannerImageView: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFit
//        iv.clipsToBounds = true
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        // чтобы баннер не давил верстку
//        iv.setContentHuggingPriority(.defaultLow, for: .vertical)
//        iv.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
//        return iv
//    }()
//    private var bannerMaxHeight: NSLayoutConstraint!
//    private var bannerTopSoft: NSLayoutConstraint!
//
//    private let actionButton: UIButton = {
//        let b = UIButton(type: .system)
//        b.translatesAutoresizingMaskIntoConstraints = false
//        if #available(iOS 15.0, *) {
//            var cfg = UIButton.Configuration.filled()
//            cfg.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
//            cfg.baseForegroundColor = .white
//            cfg.cornerStyle = .medium
//            b.configuration = cfg
//        } else {
//            b.setTitleColor(.white, for: .normal)
//            b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
//            b.layer.cornerRadius = 14
//        }
//        b.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
//        return b
//    }()
//
//    // MARK: - Init
//
//    init(kind: CategoryKind) {
//        self.kind = kind
//        super.init(nibName: nil, bundle: nil)
//    }
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .secondarySystemBackground
//        view.layer.cornerRadius = 16
//
//        titleLabel.text = kind.titleText
//        setButtonTitle(kind.buttonTitle)
//        actionButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
//
//        layout()
//        addBanner()
//        configureBanner()
//        applyTheme()
//    }
//
//    // MARK: - Layout
//
//    private func layout() {
//        view.addSubview(titleLabel)
//        view.addSubview(scheduleCard)
//        view.addSubview(actionButton)
//
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//
//            scheduleCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
//            scheduleCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            scheduleCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//
//            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            actionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
//        ])
//    }
//
//    /// Баннер идёт **между** карточкой и кнопкой и не тянет заголовок.
//    private func addBanner() {
//        view.insertSubview(bannerImageView, belowSubview: actionButton)
//
//        // Привязать к кнопке
//        let bottomC = bannerImageView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -12)
//        // Мягкая связь с карточкой (не давит вверх)
//        bannerTopSoft = bannerImageView.topAnchor.constraint(greaterThanOrEqualTo: scheduleCard.bottomAnchor, constant: 8)
//        bannerTopSoft.priority = .defaultLow
//
//        let lead = bannerImageView.leadingAnchor.constraint(equalTo: scheduleCard.leadingAnchor)
//        let trail = bannerImageView.trailingAnchor.constraint(equalTo: scheduleCard.trailingAnchor)
//
//        bannerMaxHeight = bannerImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
//        bannerMaxHeight.isActive = true
//
//        NSLayoutConstraint.activate([bottomC, bannerTopSoft, lead, trail])
//    }
//
//    private func configureBanner() {
//        if let name = kind.bannerAssetName, let img = UIImage(named: name) {
//            bannerImageView.image = img
//            bannerImageView.isHidden = false
//            switch kind {
//            case .household:    bannerMaxHeight.constant = 200
//            case .construction: bannerMaxHeight.constant = 230
//            case .cleaning:     bannerMaxHeight.constant = 200
//            }
//            bannerTopSoft.constant = 8
//        } else {
//            bannerImageView.image = nil
//            bannerImageView.isHidden = true
//            bannerMaxHeight.constant = 0
//            bannerTopSoft.constant = 0
//        }
//    }
//
//    private func setButtonTitle(_ title: String) {
//        if #available(iOS 15.0, *) {
//            var cfg = actionButton.configuration ?? .filled()
//            cfg.title = title
//            actionButton.configuration = cfg
//        } else {
//            actionButton.setTitle(title, for: .normal)
//        }
//    }
//
//    private func applyTheme() {
//        let accent = kind.accentColor
//        scheduleCard.accentColor = accent
//        if #available(iOS 15.0, *) {
//            var cfg = actionButton.configuration ?? .filled()
//            cfg.baseBackgroundColor = accent
//            cfg.baseForegroundColor = .white
//            actionButton.configuration = cfg
//        } else {
//            actionButton.backgroundColor = accent
//            actionButton.setTitleColor(.white, for: .normal)
//        }
//    }
//
//    // MARK: - Actions
//
//    @objc private func tap() {
//        guard kind == .household else { return }
//        let vc = AddressPickerViewController()
//        vc.hidesBottomBarWhenPushed = true
//        navigationItem.backButtonDisplayMode = .minimal
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}

// CategoryViewController.swift
// MusorOk
//
// Добавлены чипы доверия под заголовком (ChipsBarView), аккуратные констрейнты,
// баннер между карточкой и кнопкой, тема — по типу категории.

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

    var bannerAssetName: String? {
        switch self {
        case .household:    return "homeMusor"
        case .construction: return "stroitelMusor"
        case .cleaning:     return "cleaning" // добавь ассет при необходимости
        }
    }

    var accentColor: UIColor {
        switch self {
        case .household:    return .brandGreen
        case .construction: return .brandOrange
        case .cleaning:     return .brandTeal
        }
    }
}

final class CategoryViewController: UIViewController {

    private let kind: CategoryKind

    // MARK: - UI

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .label
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let chipsBar = ChipsBarView()

    private let scheduleCard = ScheduleCardView()

    private let bannerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.setContentHuggingPriority(.defaultLow, for: .vertical)
        iv.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        return iv
    }()
    private var bannerMaxHeight: NSLayoutConstraint!
    private var bannerTopSoft: NSLayoutConstraint!

    private let actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 15.0, *) {
            var cfg = UIButton.Configuration.filled()
            cfg.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
            cfg.baseForegroundColor = .white
            cfg.cornerStyle = .medium
            b.configuration = cfg
        } else {
            b.setTitleColor(.white, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            b.layer.cornerRadius = 14
        }
        b.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        return b
    }()

    // MARK: - Init

    init(kind: CategoryKind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16

        titleLabel.text = kind.titleText
        setButtonTitle(kind.buttonTitle)
        actionButton.addTarget(self, action: #selector(tap), for: .touchUpInside)

        // Чипы доверия (иконки SF Symbols — маленькие)
        chipsBar.configure(items: [
            .init(text: "Сегодня",         symbol: "calendar"),
            .init(text: "от 150 ₸",        symbol: "tag"),
            .init(text: "Оплата картой",   symbol: "creditcard"),
            .init(text: "Быстро: 25–40 мин", symbol: "bolt")
        ])
        chipsBar.accentColor = kind.accentColor

        layout()
        addBanner()
        configureBanner()
        applyTheme()
    }

    // MARK: - Layout

    private func layout() {
        view.addSubview(titleLabel)
        view.addSubview(chipsBar)
        view.addSubview(scheduleCard)
        view.addSubview(actionButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Чипы сразу под заголовком
            chipsBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            chipsBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            chipsBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Карточка — уже под чипами
            scheduleCard.topAnchor.constraint(equalTo: chipsBar.bottomAnchor, constant: 16),
            scheduleCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            actionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

    /// Баннер идёт между карточкой и кнопкой и не тянет заголовок.
    private func addBanner() {
        view.insertSubview(bannerImageView, belowSubview: actionButton)

        let bottomC = bannerImageView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -12)
        bannerTopSoft = bannerImageView.topAnchor.constraint(greaterThanOrEqualTo: scheduleCard.bottomAnchor, constant: 8)
        bannerTopSoft.priority = .defaultLow

        let lead = bannerImageView.leadingAnchor.constraint(equalTo: scheduleCard.leadingAnchor)
        let trail = bannerImageView.trailingAnchor.constraint(equalTo: scheduleCard.trailingAnchor)

        bannerMaxHeight = bannerImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
        bannerMaxHeight.isActive = true

        NSLayoutConstraint.activate([bottomC, bannerTopSoft, lead, trail])
    }

    private func configureBanner() {
        if let name = kind.bannerAssetName, let img = UIImage(named: name) {
            bannerImageView.image = img
            bannerImageView.isHidden = false
            switch kind {
            case .household:    bannerMaxHeight.constant = 200
            case .construction: bannerMaxHeight.constant = 230
            case .cleaning:     bannerMaxHeight.constant = 200
            }
            bannerTopSoft.constant = 8
        } else {
            bannerImageView.image = nil
            bannerImageView.isHidden = true
            bannerMaxHeight.constant = 0
            bannerTopSoft.constant = 0
        }
    }

    private func setButtonTitle(_ title: String) {
        if #available(iOS 15.0, *) {
            var cfg = actionButton.configuration ?? .filled()
            cfg.title = title
            actionButton.configuration = cfg
        } else {
            actionButton.setTitle(title, for: .normal)
        }
    }

    private func applyTheme() {
        let accent = kind.accentColor
        scheduleCard.accentColor = accent
        if #available(iOS 15.0, *) {
            var cfg = actionButton.configuration ?? .filled()
            cfg.baseBackgroundColor = accent
            cfg.baseForegroundColor = .white
            actionButton.configuration = cfg
        } else {
            actionButton.backgroundColor = accent
            actionButton.setTitleColor(.white, for: .normal)
        }
    }

    // MARK: - Actions

    @objc private func tap() {
        guard kind == .household else { return }
        let vc = AddressPickerViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(vc, animated: true)
    }
}


