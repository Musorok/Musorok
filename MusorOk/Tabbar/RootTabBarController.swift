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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let brand = UIColor.systemGreen
        setupTabBarAppearance(brand: brand)
        let home = UINavigationController(rootViewController: HomeViewController())
        home.tabBarItem = makeSystemTabItem(
            systemName: "house",              // iOS 13+
            selectedSystemName: "house.fill",
            title: "Главная"
        )

        // Заказы
        let ordersNav = UINavigationController(rootViewController: AuthContainerViewController())
        ordersNav.tabBarItem = makeSystemTabItem(
            systemName: "doc.text",           // iOS 13+
            selectedSystemName: "doc.text.fill",
            title: "Заказы"
        )

        // Профиль
        let profile = UINavigationController(rootViewController: ProfileContainerViewController())
        profile.tabBarItem = makeSystemTabItem(
            systemName: "person.crop.circle", // iOS 13+
            selectedSystemName: "person.crop.circle.fill",
            title: "Профиль"
        )

        viewControllers = [home, ordersNav, profile]

        if AuthManager.shared.isAuthorized {
            showOrdersList(animated: false)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(authStateChanged), name: .authStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openMyOrdersActiveTab), name: .openMyOrdersActive, object: nil)
    }

    // MARK: - Notifications / навигация

    @objc private func authStateChanged() {
        if AuthManager.shared.isAuthorized {
            showOrdersList(animated: true)
            selectedIndex = 1
        } else {
            showOrdersAuth(animated: true)
        }
    }

    @objc private func openMyOrdersActiveTab() {
        PendingAddressKeeper.flushIfNeeded()
        selectedIndex = 1
        showOrdersList(animated: false)
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
        nav.setViewControllers([AuthContainerViewController()], animated: animated)
    }

    // MARK: - Внешний вид таббара

    private func setupTabBarAppearance(brand: UIColor) {
        tabBar.tintColor = brand
        tabBar.unselectedItemTintColor = .secondaryLabel

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground

        // ⬆️ Чуть крупнее шрифт для подписей
        let baseFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
        let scaledFont = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: baseFont)

        [appearance.stackedLayoutAppearance,
         appearance.inlineLayoutAppearance,
         appearance.compactInlineLayoutAppearance].forEach { layout in
            layout.normal.iconColor = .secondaryLabel
            layout.selected.iconColor = brand
            layout.normal.titleTextAttributes = [
                .foregroundColor: UIColor.secondaryLabel,
                .font: scaledFont
            ]
            layout.selected.titleTextAttributes = [
                .foregroundColor: brand,
                .font: scaledFont
            ]
        }

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.itemPositioning = .automatic
    }

    // MARK: - Фабрика айтемов

    private func makeTabItem(assetName: String, title: String, brand: UIColor) -> UITabBarItem {
        let baseImage = UIImage(named: assetName)?.resized(to: TabIcon.size) ?? UIImage()
        // обе картинки — шаблонные, чтобы работали tint-цвета (selected/unselected)
        let image = baseImage.withRenderingMode(.alwaysTemplate)
        let selectedImage = baseImage.withRenderingMode(.alwaysTemplate)
        let item = UITabBarItem(title: title, image: image, selectedImage: selectedImage)

        // гарантируем, что подпись будет отображаться
        item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)
        return item
    }
    
    private func makeSystemTabItem(systemName: String, selectedSystemName: String, title: String) -> UITabBarItem {
        let config = UIImage.SymbolConfiguration(weight: .medium) // единый вес иконок
        let image = UIImage(systemName: systemName, withConfiguration: config)?.withRenderingMode(.alwaysTemplate)
        let selectedImage = UIImage(systemName: selectedSystemName, withConfiguration: config)?.withRenderingMode(.alwaysTemplate)

        let item = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        item.titlePositionAdjustment = .zero // гарантируем подпись
        return item
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


