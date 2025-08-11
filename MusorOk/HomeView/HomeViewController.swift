//
//  HomeViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

final class HomeViewController: UIViewController {
    
    private var segmentedHeightConstraint: NSLayoutConstraint!
    private var isAnimating = false

    private let segmented: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Бытовой", "Строительный", "Клининг"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentTintColor = .brandGreen
        control.setTitleTextAttributes([.foregroundColor: UIColor.white,
                                        .font: UIFont.systemFont(ofSize: 15, weight: .semibold)], for: .selected)
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.label.withAlphaComponent(0.85),
            .font: UIFont.systemFont(ofSize: 15, weight: .medium)
        ], for: .normal)
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
        navigationItem.largeTitleDisplayMode = .never   // не используем large title на этом экране
        setupLogoTitle()
        view.backgroundColor = .systemBackground

        setupLayout()
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        // свайпы по контейнеру
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        containerView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        containerView.addGestureRecognizer(swipeRight)
        
        displayChild(at: 0)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // опционально: скруглить под большую высоту (красиво как «пилюля»)
        segmented.layer.cornerRadius = 8
        segmented.layer.masksToBounds = true
    }

    private func setupLayout() {
        view.addSubview(segmented)
        view.addSubview(containerView)
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12),
            segmented.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16)
        ])
        
        // 👇 высота сегмента на +10pt от базовой
        segmentedHeightConstraint = segmented.heightAnchor.constraint(
            equalToConstant: segmented.intrinsicContentSize.height + 10
        )
        segmentedHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16)
        ])
    }

    @objc private func segmentChanged() {
        let to = segmented.selectedSegmentIndex
        let from = currentChildIndex
        guard to != from else { return }
        displayChildAnimated(from: from, to: to, swipeLeft: to > from)
    }
    
    @objc private func handleSwipe(_ g: UISwipeGestureRecognizer) {
        let dir = g.direction
        let next = currentChildIndex + (dir == .left ? 1 : -1)
        guard next >= 0, next < childControllers.count else { return }
        let from = currentChildIndex
        segmented.selectedSegmentIndex = next
        displayChildAnimated(from: from, to: next, swipeLeft: dir == .left)
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
    
    private func displayChildAnimated(from: Int, to: Int, swipeLeft: Bool) {
        guard !isAnimating else { return }
        isAnimating = true

        let oldVC = children.first
        let newVC = childControllers[to]

        // добавляем нового ребёнка
        addChild(newVC)
        newVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(newVC.view)
        NSLayoutConstraint.activate([
            newVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            newVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        containerView.layoutIfNeeded()

        // слайд-анимация через transform
        let width = containerView.bounds.width
        let offset: CGFloat = swipeLeft ? width : -width
        newVC.view.transform = CGAffineTransform(translationX: offset, y: 0)

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            newVC.view.transform = .identity
            oldVC?.view.transform = CGAffineTransform(translationX: -offset, y: 0)
        } completion: { _ in
            oldVC?.willMove(toParent: nil)
            oldVC?.view.removeFromSuperview()
            oldVC?.removeFromParent()
            oldVC?.view.transform = .identity

            newVC.didMove(toParent: self)
            self.currentChildIndex = to
            self.isAnimating = false
        }
    }
    
    private func setupLogoTitle() {
        // берём картинку из Assets (название: musorok)
        let image = UIImage(named: "musorok")?.withRenderingMode(.alwaysOriginal)

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // контейнер, чтобы зафиксировать размер в навбаре
        let container = UIView(frame: .zero)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 28),
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 140),

            container.heightAnchor.constraint(equalToConstant: 32),
            container.widthAnchor.constraint(greaterThanOrEqualTo: imageView.widthAnchor)
        ])

        navigationItem.titleView = container
    }
}
