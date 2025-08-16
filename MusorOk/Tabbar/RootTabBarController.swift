//
//  RootTabBarController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

final class RootTabBarController: UITabBarController {
    private weak var ordersNav: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tabBar.tintColor = .label
        setupTabBarAppearance()

        let home = UINavigationController(rootViewController: HomeViewController())
        home.tabBarItem = UITabBarItem(title: "Главная",
                                       image: UIImage(systemName: "house"),
                                       selectedImage: UIImage(systemName: "house.fill"))

        // Вкладка «Заказы» стартует с авторизации
        let authContainer = AuthContainerViewController()
        let orders = UINavigationController(rootViewController: authContainer)
        self.ordersNav = orders
        orders.tabBarItem = UITabBarItem(title: "Заказы",
                                         image: UIImage(systemName: "list.bullet"),
                                         selectedImage: UIImage(systemName: "list.bullet"))

        let profile = UINavigationController(rootViewController: ProfileContainerViewController())
        profile.tabBarItem = UITabBarItem(title: "профиль",
                                          image: UIImage(systemName: "person"),
                                          selectedImage: UIImage(systemName: "person.fill"))

        viewControllers = [home, orders, profile]

        // если уже авторизованы — сразу показываем список заказов
        if AuthManager.shared.isAuthorized {
            showOrdersList(animated: false)
        }

        // 🔔 единая подписка на смену auth-состояния (логин/логаут)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(authStateChanged),
                                               name: .authStateDidChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(openMyOrdersActiveTab),
                                               name: .openMyOrdersActive,
                                               object: nil)
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
    
    private func setupTabBarAppearance() {
        tabBar.tintColor = UIColor.systemGreen // активная вкладка
        tabBar.unselectedItemTintColor = UIColor.gray // неактивные вкладки
        tabBar.backgroundColor = .systemBackground
        tabBar.isTranslucent = false
    }
}
