//
//  HomeViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

final class HomeViewController: UIViewController {

    private let segmented: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Бытовой", "Строительный", "Клининг"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentTintColor = .brandGreen
        control.setTitleTextAttributes([.foregroundColor: UIColor.white,
                                        .font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.secondaryLabel,
                                        .font: UIFont.systemFont(ofSize: 14, weight: .regular)], for: .normal)
        return control
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var childControllers: [UIViewController] = [
        CategoryViewController(kind: .household),
        CategoryViewController(kind: .construction),
        CategoryViewController(kind: .cleaning)
    ]

    private var currentChildIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Мусорок"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true

        setupLayout()
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        // стартовый экран
        displayChild(at: 0)
    }

    private func setupLayout() {
        view.addSubview(segmented)
        view.addSubview(containerView)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12),
            segmented.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),

            containerView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16)
        ])
    }

    @objc private func segmentChanged() {
        displayChild(at: segmented.selectedSegmentIndex)
    }

    private func displayChild(at index: Int) {
        // убрать предыдущего
        let old = children.first
        old?.willMove(toParent: nil)
        old?.view.removeFromSuperview()
        old?.removeFromParent()

        // добавить нового
        let vc = childControllers[index]
        addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(vc.view)
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        vc.didMove(toParent: self)
        currentChildIndex = index
    }
}
