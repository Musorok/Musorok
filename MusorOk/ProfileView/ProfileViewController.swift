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

        let l = UILabel()
        l.text = "Профиль пользователя"
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(l)
        NSLayoutConstraint.activate([
            l.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            l.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
