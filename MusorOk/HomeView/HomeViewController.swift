//
//  HomeViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

//import UIKit
//
//final class HomeViewController: UIViewController {
//
//    private var isAnimating = false
//    private var currentChildIndex: Int = 0
//
//    private let segmented: UISegmentedControl = {
//        let control = UISegmentedControl(items: ["Бытовой", "Строительный", "Клининг"])
//        control.selectedSegmentIndex = 0
//        control.translatesAutoresizingMaskIntoConstraints = false
//        control.selectedSegmentTintColor = .brandGreen
//        control.setTitleTextAttributes(
//            [.foregroundColor: UIColor.white,
//             .font: UIFont.systemFont(ofSize: 15, weight: .semibold)],
//            for: .selected
//        )
//        control.setTitleTextAttributes(
//            [.foregroundColor: UIColor.label.withAlphaComponent(0.85),
//             .font: UIFont.systemFont(ofSize: 15, weight: .medium)],
//            for: .normal
//        )
//        return control
//    }()
//
//    private let containerView: UIView = {
//        let v = UIView()
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
//
//    private lazy var childControllers: [UIViewController] = [
//        CategoryViewController(kind: .household),
//        CategoryViewController(kind: .construction),
//        CategoryViewController(kind: .cleaning)
//    ]
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationItem.largeTitleDisplayMode = .never
//        setupLogoTitle()
//        view.backgroundColor = .systemBackground
//
//        setupLayout()
//        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
//
//        // Свайпы по контейнеру
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        swipeLeft.direction = .left
//        containerView.addGestureRecognizer(swipeLeft)
//
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
//        swipeRight.direction = .right
//        containerView.addGestureRecognizer(swipeRight)
//
//        displayChild(at: 0)
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        segmented.layer.cornerRadius = 8
//        segmented.layer.masksToBounds = true
//    }
//
//    // MARK: - Layout
//
//    private func setupLayout() {
//        view.addSubview(segmented)
//        view.addSubview(containerView)
//
//        let guide = view.safeAreaLayoutGuide
//        NSLayoutConstraint.activate([
//            segmented.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12),
//            segmented.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
//            segmented.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
//            segmented.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
//
//            containerView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 16),
//            containerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
//            containerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
//            containerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16)
//        ])
//    }
//
//    // MARK: - Child switching
//
//    @objc private func segmentChanged() {
//        let to = segmented.selectedSegmentIndex
//        let from = currentChildIndex
//        guard to != from else { return }
//        displayChildAnimated(from: from, to: to, swipeLeft: to > from)
//    }
//
//    @objc private func handleSwipe(_ g: UISwipeGestureRecognizer) {
//        let dir = g.direction
//        let next = currentChildIndex + (dir == .left ? 1 : -1)
//        guard (0..<childControllers.count).contains(next) else { return }
//        let from = currentChildIndex
//        segmented.selectedSegmentIndex = next
//        displayChildAnimated(from: from, to: next, swipeLeft: dir == .left)
//    }
//
//    private func displayChild(at index: Int) {
//        // убрать предыдущего
//        let old = children.first
//        old?.willMove(toParent: nil)
//        old?.view.removeFromSuperview()
//        old?.removeFromParent()
//
//        // добавить нового
//        let vc = childControllers[index]
//        addChild(vc)
//        vc.view.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(vc.view)
//        NSLayoutConstraint.activate([
//            vc.view.topAnchor.constraint(equalTo: containerView.topAnchor),
//            vc.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//            vc.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            vc.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
//        ])
//        vc.didMove(toParent: self)
//        currentChildIndex = index
//    }
//
//    private func displayChildAnimated(from: Int, to: Int, swipeLeft: Bool) {
//        guard !isAnimating else { return }
//        isAnimating = true
//
//        let oldVC = children.first
//        let newVC = childControllers[to]
//
//        addChild(newVC)
//        newVC.view.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(newVC.view)
//        NSLayoutConstraint.activate([
//            newVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
//            newVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//            newVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            newVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
//        ])
//        containerView.layoutIfNeeded()
//
//        let width = containerView.bounds.width
//        let offset: CGFloat = swipeLeft ? width : -width
//        newVC.view.transform = CGAffineTransform(translationX: offset, y: 0)
//
//        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
//            newVC.view.transform = .identity
//            oldVC?.view.transform = CGAffineTransform(translationX: -offset, y: 0)
//        } completion: { _ in
//            oldVC?.willMove(toParent: nil)
//            oldVC?.view.removeFromSuperview()
//            oldVC?.removeFromParent()
//            oldVC?.view.transform = .identity
//
//            newVC.didMove(toParent: self)
//            self.currentChildIndex = to
//            self.isAnimating = false
//        }
//    }
//
//    // MARK: - Nav title (логотип)
//
//    private func setupLogoTitle() {
//        let image = UIImage(named: "musorok")?.withRenderingMode(.alwaysOriginal)
//
//        let imageView = UIImageView(image: image)
//        imageView.contentMode = .scaleAspectFit
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//
//        let container = UIView(frame: .zero)
//        container.translatesAutoresizingMaskIntoConstraints = false
//        container.addSubview(imageView)
//
//        NSLayoutConstraint.activate([
//            imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
//            imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
//            imageView.heightAnchor.constraint(equalToConstant: 28),
//            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: 140),
//
//            container.heightAnchor.constraint(equalToConstant: 32),
//            container.widthAnchor.constraint(greaterThanOrEqualTo: imageView.widthAnchor)
//        ])
//
//        navigationItem.titleView = container
//    }
//}


// HomeViewController.swift
// MusorOk
//
// Обновлено: акцент-цвет под сегмент, плавные свайпы, haptics.
// Логотип в titleView остаётся.

import UIKit

final class HomeViewController: UIViewController {

    private var isAnimating = false
    private var currentChildIndex: Int = 0

    private let segmented: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Бытовой", "Строительный", "Клининг"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = .tertiarySystemBackground
        control.apportionsSegmentWidthsByContent = false
        control.setContentHuggingPriority(.required, for: .vertical)

        // Стиль текста
        control.setTitleTextAttributes(
            [.foregroundColor: UIColor.white,
             .font: UIFont.systemFont(ofSize: 15, weight: .semibold)],
            for: .selected
        )
        control.setTitleTextAttributes(
            [.foregroundColor: UIColor.label.withAlphaComponent(0.88),
             .font: UIFont.systemFont(ofSize: 15, weight: .medium)],
            for: .normal
        )
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        setupLogoTitle()
        view.backgroundColor = .systemBackground

        setupLayout()
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        // Свайпы по контейнеру (строго по одному экрану)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        containerView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        containerView.addGestureRecognizer(swipeRight)

        applyAccent(for: 0)
        displayChild(at: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segmented.layer.cornerRadius = 10
        segmented.layer.masksToBounds = true
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(segmented)
        view.addSubview(containerView)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            segmented.topAnchor.constraint(equalTo: guide.topAnchor, constant: 12),
            segmented.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            segmented.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            segmented.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),

            containerView.topAnchor.constraint(equalTo: segmented.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Child switching

    @objc private func segmentChanged() {
        let to = segmented.selectedSegmentIndex
        let from = currentChildIndex
        guard to != from else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        displayChildAnimated(from: from, to: to, swipeLeft: to > from)
        applyAccent(for: to)
    }

    @objc private func handleSwipe(_ g: UISwipeGestureRecognizer) {
        let dir = g.direction
        let next = currentChildIndex + (dir == .left ? 1 : -1)
        guard (0..<childControllers.count).contains(next) else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        segmented.selectedSegmentIndex = next
        displayChildAnimated(from: currentChildIndex, to: next, swipeLeft: dir == .left)
        applyAccent(for: next)
    }

    private func displayChild(at index: Int) {
        // снять предыдущего
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

    // MARK: - Accent

    private func accentColor(for index: Int) -> UIColor {
        switch index {
        case 0: return .brandGreen
        case 1: return .brandOrange
        case 2: return .brandTeal
        default: return .brandGreen
        }
    }

    private func applyAccent(for index: Int) {
        let accent = accentColor(for: index)
        segmented.selectedSegmentTintColor = accent
        navigationController?.navigationBar.tintColor = accent
    }

    // MARK: - Nav title (логотип)

    private func setupLogoTitle() {
        let image = UIImage(named: "musorok")?.withRenderingMode(.alwaysOriginal)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

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
