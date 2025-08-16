//
//  RootTabBarController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

private enum TabIcon {
    // системный размер для iPhone (24×24 pt); на iPad Apple рендерит схоже для template-иконок
    static let size = CGSize(width: 24, height: 24)
}

final class RootTabBarController: UITabBarController {
    private weak var ordersNav: UINavigationController?
    private enum SelectedIconStyle { case gradient, tint, original }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let useGradientSelectedIcons = true
        let brand = UIColor.systemGreen

        setupTabBarAppearance(opposing: .opposingToGreen, brand: brand, useGradientSelectedIcons: useGradientSelectedIcons)

        // home — градиент при выборе
        let home = UINavigationController(rootViewController: HomeViewController())
        home.tabBarItem = makeTabItem(assetName: "home",
                                      title: "",
                                      baseColor: brand,
                                      useGradientSelectedIcons: useGradientSelectedIcons,
                                      selectedStyle: .gradient)

        // zakaz — градиент при выборе
        let authContainer = AuthContainerViewController()
        let orders = UINavigationController(rootViewController: authContainer)
        orders.tabBarItem = makeTabItem(assetName: "zakaz",
                                        title: "",
                                        baseColor: brand,
                                        useGradientSelectedIcons: useGradientSelectedIcons,
                                        selectedStyle: .original)

        // profile — ОРИГИНАЛЬНЫЙ цвет ассета при выборе
        let profile = UINavigationController(rootViewController: ProfileContainerViewController())
        profile.tabBarItem = makeTabItem(assetName: "profile",
                                         title: "",
                                         baseColor: brand,
                                         useGradientSelectedIcons: useGradientSelectedIcons,
                                         selectedStyle: .original)

        viewControllers = [home, orders, profile]

        if AuthManager.shared.isAuthorized {
            showOrdersList(animated: false)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(authStateChanged), name: .authStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openMyOrdersActiveTab), name: .openMyOrdersActive, object: nil)
    }


    @objc private func authStateChanged() {
        if AuthManager.shared.isAuthorized {
            showOrdersList(animated: true)
            selectedIndex = 1
        } else {
            showOrdersAuth(animated: true)
        }
    }
    
    @objc private func openMyOrdersActiveTab() {
        // ➊ Если пользователь просил запомнить — сохраняем адрес сейчас (успешная оплата)
        PendingAddressKeeper.flushIfNeeded()

        // выбрать вкладку "Заказы"
        selectedIndex = 1

        // убедиться, что в корне стека именно MyOrdersViewController
        showOrdersList(animated: false)

        // попросить экран "Мои заказы" переключиться на "Активные"
        NotificationCenter.default.post(name: .switchOrdersToActive, object: nil)
    }

    private func showOrdersList(animated: Bool) {
        guard let nav = viewControllers?[1] as? UINavigationController else { return }
        if nav.viewControllers.first is MyOrdersViewController { return }
        nav.setViewControllers([MyOrdersViewController()], animated: animated)
    }

    private func showOrdersAuth(animated: Bool) {
        guard let nav = viewControllers?[1] as? UINavigationController else { return }
        if nav.viewControllers.first is AuthContainerViewController { return }
        let auth = AuthContainerViewController()
        nav.setViewControllers([auth], animated: animated)
    }
    
    private func setupTabBarAppearance(opposing: UIColor, brand: UIColor, useGradientSelectedIcons: Bool) {
        // Для выбранного состояния: если рисуем градиент внутри картинки, tint можно оставить нейтральным
        tabBar.tintColor = useGradientSelectedIcons ? .label : brand
        tabBar.unselectedItemTintColor = opposing

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground

        // Поддержка inline/stacked/compact (iPad и разные стили)
        [appearance.stackedLayoutAppearance,
         appearance.inlineLayoutAppearance,
         appearance.compactInlineLayoutAppearance].forEach { layout in
            layout.normal.iconColor = opposing
            if !useGradientSelectedIcons {
                layout.selected.iconColor = brand
            }
        }

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Tab item factory

private extension RootTabBarController {
   private func makeTabItem(assetName: String,
                     title: String,
                     baseColor: UIColor,
                     useGradientSelectedIcons: Bool,
                     selectedStyle: SelectedIconStyle = .gradient) -> UITabBarItem {

        guard let base0 = UIImage(named: assetName) else {
            return UITabBarItem(title: title, image: nil, selectedImage: nil)
        }
        let base = base0.resized(to: TabIcon.size)

        // невыбранная — шаблон, красим через unselectedItemTintColor
        let unselected = base.withRenderingMode(.alwaysTemplate)

        // выбранная
        let selected: UIImage
        switch selectedStyle {
        case .original:
            // оставляем как есть (цвет из ассета), чтобы НЕ перекрашивалось tint-ом
            selected = base.withRenderingMode(.alwaysOriginal)

        case .gradient:
            if useGradientSelectedIcons {
                let colors = baseColor.gradientPair
                let grad = UIImage.gradientMaskedIcon(named: assetName, size: TabIcon.size, colors: colors)
                selected = grad.withRenderingMode(.alwaysOriginal)
            } else {
                selected = base.withRenderingMode(.alwaysTemplate)
            }

        case .tint:
            selected = base.withRenderingMode(.alwaysTemplate)
        }

        return UITabBarItem(title: title, image: unselected, selectedImage: selected)
    }
}

// MARK: - Цвета

private extension UIColor {
    /// «Противоположный» к зелёному для НЕвыбранных: лилово-графитовый.
    /// Комплементарный зелёному (≈300°), но десатурированный, чтобы не конфликтовать с UX-семантикой «ошибка/опасность».
    static var opposingToGreen: UIColor {
        UIColor { trait in
            // Светлая тема — более тёмный сливово-графитовый; тёмная — светлее для контраста.
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 0.74, green: 0.65, blue: 0.78, alpha: 1.0) // ~ #BDA5C7 (lilac-300)
            } else {
                return UIColor(red: 0.43, green: 0.35, blue: 0.49, alpha: 1.0) // ~ #6E5A7D (lilac-700)
            }
        }
    }

    /// Пара градиента от базового цвета: светлее + темнее
    var gradientPair: [UIColor] {
        [self.lighter(by: 0.18), self.darker(by: 0.12)]
    }

    func lighter(by amount: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return self }
        return UIColor(hue: h, saturation: max(s * 0.98, 0), brightness: min(b * (1 + amount), 1), alpha: a)
    }
    func darker(by amount: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return self }
        return UIColor(hue: h, saturation: min(s * 1.02, 1), brightness: max(b * (1 - amount), 0), alpha: a)
    }
}

// MARK: - Рендер градиента по маске иконки

private extension UIImage {
    static func gradientMaskedIcon(named name: String, size: CGSize, colors: [UIColor]) -> UIImage {
        guard let icon = UIImage(named: name)?.cgImage else { return UIImage() }
        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            cg.saveGState()
            // Core Graphics координаты перевёрнуты по Y — разворачиваем
            cg.translateBy(x: 0, y: size.height)
            cg.scaleBy(x: 1, y: -1)
            cg.clip(to: rect, mask: icon)
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors.map { $0.cgColor } as CFArray,
                locations: [0.0, 1.0]
            )!
            // Диагональный градиент — выглядит живее на маленьких иконках
            cg.drawLinearGradient(gradient,
                                  start: CGPoint(x: 0, y: 0),
                                  end: CGPoint(x: size.width, y: size.height),
                                  options: [])
            cg.restoreGState()
        }
    }
}

private extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = UIScreen.main.scale
        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

