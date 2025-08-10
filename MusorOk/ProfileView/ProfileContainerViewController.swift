//
//  ProfileContainerViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import UIKit

final class ProfileContainerViewController: UIViewController {

    private var current: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(authStateChanged),
                                               name: .authStateDidChange,
                                               object: nil)
        showInitial()
    }

    private func showInitial() {
        if AuthManager.shared.isAuthorized {
            showProfile()
        } else {
            showAuth()
        }
    }

    @objc private func authStateChanged() {
        if AuthManager.shared.isAuthorized {
            showProfile()
        } else {
            showAuth()
        }
    }

    private func setChild(_ vc: UIViewController) {
        if let cur = current {
            cur.willMove(toParent: nil)
            cur.view.removeFromSuperview()
            cur.removeFromParent()
        }
        addChild(vc)
        vc.view.frame = view.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        current = vc
    }

    private func showAuth() {
        let auth = AuthContainerViewController()
        setChild(auth)
    }

    private func showProfile() {
        let profile = ProfileViewController()
        let nav = UINavigationController(rootViewController: profile)
        nav.navigationBar.isTranslucent = false
        setChild(nav)
    }
}
