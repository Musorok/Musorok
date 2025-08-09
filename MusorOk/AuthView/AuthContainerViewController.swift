//
//  AuthContainerViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import UIKit

protocol AuthFlowDelegate: AnyObject {
    func authDidSucceed()
}

final class AuthContainerViewController: UIViewController {

    weak var delegate: AuthFlowDelegate?
    // Верхний сегмент + подчёркивание
    private let segment = UISegmentedControl(items: ["Вход", "Регистрация"])
    private let underline = UIView()
    private var underlineLeading: NSLayoutConstraint!

    // Контейнер для дочерних VC
    private let container = UIView()

    // Дочерние экраны (создаём один раз)
    private lazy var loginVC = LoginViewController()                 // твой экран входа
    private lazy var regVC   = RegistrationViewController()          // из прошлого сообщения
    private lazy var pages: [UIViewController] = [loginVC, regVC]

    private var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Заказы" // заголовок таба

        setupUI()
        showPage(0) // старт: Вход
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Обновляем позицию подчеркивания при первом layout'е/ротации
        moveUnderline(to: segment.selectedSegmentIndex, animated: false)
    }

    private func setupUI() {
        // segmented
        segment.selectedSegmentIndex = 0
        segment.selectedSegmentTintColor = .clear
        segment.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 18, weight: .semibold)], for: .normal)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        // underline
        underline.backgroundColor = .brandGreen
        underline.translatesAutoresizingMaskIntoConstraints = false

        // container
        container.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(segment)
        view.addSubview(underline)
        view.addSubview(container)

        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            segment.topAnchor.constraint(equalTo: g.topAnchor, constant: 8),
            segment.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16),
            segment.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),

            underline.topAnchor.constraint(equalTo: segment.bottomAnchor, constant: 8),
            underline.heightAnchor.constraint(equalToConstant: 3),
            underline.widthAnchor.constraint(equalTo: segment.widthAnchor, multiplier: 0.5),

            container.topAnchor.constraint(equalTo: underline.bottomAnchor, constant: 20),
            container.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: g.bottomAnchor)
        ])

        underlineLeading = underline.leadingAnchor.constraint(equalTo: segment.leadingAnchor)
        underlineLeading.isActive = true
    }

    @objc private func segmentChanged() {
        moveUnderline(to: segment.selectedSegmentIndex, animated: true)
        showPage(segment.selectedSegmentIndex)
        view.endEditing(true) // спрятать клавиатуру при переключении
    }

    private func moveUnderline(to index: Int, animated: Bool) {
        let half = segment.bounds.width / 2
        underlineLeading.constant = (index == 0) ? 0 : half
        if animated {
            UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
        } else {
            view.layoutIfNeeded()
        }
    }

    private func showPage(_ index: Int) {
        // убрать текущего ребёнка
        if let current = children.first {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        // добавить нового
        let vc = pages[index]
        addChild(vc)
        container.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: container.topAnchor),
            vc.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        vc.didMove(toParent: self)
        currentIndex = index
    }
}

