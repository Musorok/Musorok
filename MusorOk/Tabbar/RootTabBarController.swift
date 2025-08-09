//
//  RootTabBarController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

final class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tabBar.tintColor = .label

        let home = UINavigationController(rootViewController: HomeViewController())
        home.tabBarItem = UITabBarItem(title: "Главная",
                                       image: UIImage(systemName: "house"),
                                       selectedImage: UIImage(systemName: "house.fill"))

        let orders = UINavigationController(rootViewController: OrdersViewController())
        orders.tabBarItem = UITabBarItem(title: "Заказы",
                                         image: UIImage(systemName: "list.bullet"),
                                         selectedImage: UIImage(systemName: "list.bullet"))

        let profile = UINavigationController(rootViewController: ProfileViewController())
        profile.tabBarItem = UITabBarItem(title: "Профиль",
                                          image: UIImage(systemName: "person.crop.circle"),
                                          selectedImage: UIImage(systemName: "person.crop.circle.fill"))

        viewControllers = [home, orders, profile]
    }
}
