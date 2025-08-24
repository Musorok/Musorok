//
//  ProfileViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit

final class ProfileViewController: UIViewController {

    private let helloLabel: UILabel = {
        let l = UILabel()
        l.text = "Добрый день,"
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.text = "—"
        l.font = .systemFont(ofSize: 32, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let stack = UIStackView()
    private let versionLabel: UILabel = {
        let l = UILabel()
        l.textColor = .tertiaryLabel
        l.font = .systemFont(ofSize: 13)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Профиль"

        setupHeader()
        setupMenu()
        setupVersion()
        applyName()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyName()
    }

    private func setupHeader() {
        view.addSubview(helloLabel)
        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            helloLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            helloLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            helloLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            nameLabel.topAnchor.constraint(equalTo: helloLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: helloLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
        ])
    }

    private func setupMenu() {
        stack.axis = .vertical
        stack.spacing = 5
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        addRow(icon: "person.crop.circle", title: "Мои данные") { [weak self] in
            let vc = ProfileEditViewController()
            self?.navigationItem.backButtonDisplayMode = .minimal
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        addRow(icon: "mappin.and.ellipse", title: "Мои адреса") { [weak self] in
            let vc = AddressesViewController()
            self?.navigationItem.backButtonDisplayMode = .minimal
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        addRow(icon: "checkmark.seal", title: "Мои подписки") {
            // TODO: push SubscriptionsVC()
        }
        addRow(icon: "ticket", title: "Промокоды") { [weak self] in
            let vc = PromoInviteViewController()
            self?.navigationItem.backButtonDisplayMode = .minimal
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        addRow(icon: "arrowshape.turn.up.left", title: "Выйти из приложения") {
            self.askLogout()
        }
        addRow(icon: "trash", title: "Удалить аккаунт", tint: .systemRed, titleColor: .systemRed) {
            self.askDelete()
        }
    }

    private func setupVersion() {
        let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        versionLabel.text = "Версия: \(ver)\(build.isEmpty ? "" : "-\(build)")"
        view.addSubview(versionLabel)
        NSLayoutConstraint.activate([
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func addRow(icon: String, title: String,
                        tint: UIColor = .brandGreen,
                        titleColor: UIColor = .label,
                        action: @escaping () -> Void) {
        let container = UIControl()
        container.backgroundColor = .clear
        container.layer.cornerRadius = 14
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let img = UIImageView(image: UIImage(systemName: icon))
        img.tintColor = tint
        img.translatesAutoresizingMaskIntoConstraints = false
        img.widthAnchor.constraint(equalToConstant: 22).isActive = true
        img.heightAnchor.constraint(equalToConstant: 22).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = titleColor
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .tertiaryLabel
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.widthAnchor.constraint(equalToConstant: 12).isActive = true

        container.addSubview(img)
        container.addSubview(titleLabel)
        container.addSubview(chevron)

        NSLayoutConstraint.activate([
            img.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            img.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: img.trailingAnchor, constant: 14),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            chevron.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8)
        ])

        stack.addArrangedSubview(container)

        container.addAction(UIAction { _ in action() }, for: .touchUpInside)
    }

    private func applyName() {
        nameLabel.text = AuthManager.shared.displayName ?? "гость"
    }

    private func askLogout() {
        let a = UIAlertController(title: "Выйти из приложения?",
                                  message: nil,
                                  preferredStyle: .actionSheet)
        a.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in
            AuthManager.shared.logout()
        })
        a.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(a, animated: true)
    }

    private func askDelete() {
        let a = UIAlertController(title: "Удалить аккаунт?",
                                  message: "Это действие нельзя отменить.",
                                  preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        a.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.performDelete()
        })
        present(a, animated: true)
    }
    
    private func performDelete() {
        // блокирующий лоадер
        let overlay = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        overlay.frame = view.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        overlay.contentView.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
        view.addSubview(overlay)
        spinner.startAnimating()
        view.isUserInteractionEnabled = false

        AuthService.deleteAccount { [weak self] result in
            guard let self = self else { return }
            self.view.isUserInteractionEnabled = true
            overlay.removeFromSuperview()

            switch result {
            case .success:
                // чистим локальные данные и рассылаем нотификацию
                AuthManager.shared.logout()
                // приятный HUD об успехе
                let ok = UIAlertController(title: "Аккаунт удалён", message: nil, preferredStyle: .alert)
                ok.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ok, animated: true)

            case .failure(let err):
                let msg: String
                switch err {
                case .server(let m, let code):
                    msg = "Ошибка \(code): \(m)"
                case .network(let e):
                    msg = "Проверьте интернет. \(e.localizedDescription)"
                case .decoding:
                    msg = "Не удалось прочитать ответ сервера"
                default:
                    msg = "Неизвестная ошибка"
                }
                let alert = UIAlertController(title: "Не удалось удалить", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
