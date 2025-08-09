//
//  OrdersViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

final class OrdersViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Заказы"
        view.backgroundColor = .systemBackground

        let l = UILabel()
        l.text = "Здесь будут ваши заказы"
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(l)
        NSLayoutConstraint.activate([
            l.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            l.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

