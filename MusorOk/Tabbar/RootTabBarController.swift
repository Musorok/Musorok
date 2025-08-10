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

        let home = UINavigationController(rootViewController: HomeViewController())
        home.tabBarItem = UITabBarItem(title: "Главная",
                                       image: UIImage(systemName: "house"),
                                       selectedImage: UIImage(systemName: "house.fill"))

        let authContainer = AuthContainerViewController()
        authContainer.delegate = self
        let orders = UINavigationController(rootViewController: authContainer)
        self.ordersNav = orders
        orders.tabBarItem = UITabBarItem(title: "Заказы",
                                         image: UIImage(systemName: "list.bullet"),
                                         selectedImage: UIImage(systemName: "list.bullet"))

        let profile = UINavigationController(rootViewController: ProfileViewController())
        profile.tabBarItem = UITabBarItem(title: "Профиль",
                                          image: UIImage(systemName: "person.crop.circle"),
                                          selectedImage: UIImage(systemName: "person.crop.circle.fill"))

        viewControllers = [home, orders, profile]
        
        if AuthManager.shared.isAuthorized {
            let vc = MyOrdersViewController()
            if let nav = viewControllers?[1] as? UINavigationController {
                nav.setViewControllers([vc], animated: false)
            }
        }
    }
}

extension RootTabBarController: AuthFlowDelegate {
    func authDidSucceed() {
        let vc = MyOrdersViewController()
        if let nav = viewControllers?[1] as? UINavigationController {
            nav.setViewControllers([vc], animated: true)
        }
        selectedIndex = 1
    }
}
