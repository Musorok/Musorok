//
//  MyOrdersViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import UIKit

final class MyOrdersViewController: UIViewController {

    private enum Tab: Int { case active = 0, history = 1 }

    // MARK: UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Мои заказы"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let activeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Активные", for: .normal)
        b.setTitleColor(.label, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let historyButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("История", for: .normal)
        b.setTitleColor(.label, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let underline = UIView()               // зелёная линия под выбранной вкладкой
    private var underlineLeading: NSLayoutConstraint!
    private var underlineWidth: NSLayoutConstraint!

    private let headerBottomLine = UIView()

    private let container = UIView()

    // children
    private lazy var activeVC = OrdersListViewController(kind: .active)
    private lazy var historyVC = OrdersListViewController(kind: .history)

    private var current: UIViewController?

    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        bindActions()

        // стартуем с "История" как на скрине — если хочешь "Активные", поменяй на .active
        switchTo(.history, animated: false)
    }

    private func setupUI() {
        navigationItem.largeTitleDisplayMode = .never
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])

        let segStack = UIStackView(arrangedSubviews: [activeButton, historyButton])
        segStack.axis = .horizontal
        segStack.alignment = .fill
        segStack.distribution = .fillEqually
        segStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segStack)

        headerBottomLine.backgroundColor = .separator
        headerBottomLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerBottomLine)

        underline.backgroundColor = .brandGreen
        underline.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(underline)

        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            segStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            segStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            segStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            headerBottomLine.topAnchor.constraint(equalTo: segStack.bottomAnchor, constant: 8),
            headerBottomLine.leadingAnchor.constraint(equalTo: segStack.leadingAnchor),
            headerBottomLine.trailingAnchor.constraint(equalTo: segStack.trailingAnchor),
            headerBottomLine.heightAnchor.constraint(equalToConstant: 1),

            container.topAnchor.constraint(equalTo: headerBottomLine.bottomAnchor, constant: 0),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // underline constraints (подгоняем под кнопку)
        underlineLeading = underline.leadingAnchor.constraint(equalTo: activeButton.leadingAnchor)
        underlineWidth = underline.widthAnchor.constraint(equalTo: activeButton.widthAnchor)
        NSLayoutConstraint.activate([
            underline.topAnchor.constraint(equalTo: headerBottomLine.bottomAnchor),
            underline.heightAnchor.constraint(equalToConstant: 3),
            underlineLeading, underlineWidth
        ])
    }

    private func bindActions() {
        activeButton.addTarget(self, action: #selector(tapActive), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(tapHistory), for: .touchUpInside)

        // свайпами тоже можно менять вкладки
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeLeft.direction = .left
        container.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipe(_:)))
        swipeRight.direction = .right
        container.addGestureRecognizer(swipeRight)
    }

    @objc private func tapActive() { switchTo(.active, animated: true) }
    @objc private func tapHistory() { switchTo(.history, animated: true) }

    @objc private func swipe(_ gr: UISwipeGestureRecognizer) {
        if gr.direction == .left { switchTo(.history, animated: true) }
        else { switchTo(.active, animated: true) }
    }

    private func switchTo(_ tab: Tab, animated: Bool) {
        let vc: UIViewController = (tab == .active) ? activeVC : historyVC
        let targetButton: UIButton = (tab == .active) ? activeButton : historyButton

        // обновим шрифты/цвета
        let selectedFont = UIFont.systemFont(ofSize: 19, weight: .semibold)
        let normalFont   = UIFont.systemFont(ofSize: 19, weight: .regular)

        activeButton.setTitleColor(tab == .active ? .brandGreen : .label, for: .normal)
        historyButton.setTitleColor(tab == .history ? .brandGreen : .label, for: .normal)
        activeButton.titleLabel?.font = tab == .active ? selectedFont : normalFont
        historyButton.titleLabel?.font = tab == .history ? selectedFont : normalFont

        // линия под выбранной вкладкой
        underlineLeading.isActive = false
        underlineWidth.isActive = false
        underlineLeading = underline.leadingAnchor.constraint(equalTo: targetButton.leadingAnchor)
        underlineWidth = underline.widthAnchor.constraint(equalTo: targetButton.widthAnchor)
        underlineLeading.isActive = true
        underlineWidth.isActive = true

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            view.layoutIfNeeded()
        }

        // child switching
        setChild(vc)
    }

    private func setChild(_ new: UIViewController) {
        if let current = current {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        addChild(new)
        new.view.frame = container.bounds
        new.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(new.view)
        new.didMove(toParent: self)
        current = new
    }
}

