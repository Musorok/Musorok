//
//  ProfileViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        view.backgroundColor = .systemBackground

        let logout = UIButton(type: .system)
        logout.setTitle("Выйти", for: .normal)
        logout.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logout.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(logout)
        NSLayoutConstraint.activate([
            logout.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logout.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func logoutTapped() {
        AuthManager.shared.logout()
        // вернём пользователя на вкладку «Заказы» с авторизацией
        if let tab = self.tabBarController as? RootTabBarController {
            let auth = AuthContainerViewController()
            auth.delegate = tab
            if let nav = tab.viewControllers?[1] as? UINavigationController {
                nav.setViewControllers([auth], animated: true)
            }
            tab.selectedIndex = 1
        }
    }
}
