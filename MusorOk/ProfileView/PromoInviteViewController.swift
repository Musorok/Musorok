//
//  PromoInviteViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 12.08.2025.
//

import UIKit

final class PromoInviteViewController: UIViewController {

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Промокоды"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Скопируйте и вставьте код при оплате заказа"
        l.font = .systemFont(ofSize: 16)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let inviteButton: GradientButton = {
        let b = GradientButton(type: .system)
        b.setTitle("Пригласить друга", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false

        // добавим стрелку справа
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .white
        chevron.translatesAutoresizingMaskIntoConstraints = false
        b.addSubview(chevron)
        NSLayoutConstraint.activate([
            chevron.centerYAnchor.constraint(equalTo: b.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: b.trailingAnchor, constant: -16)
        ])

        b.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 44)
        return b
    }()

    private let termsButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Условия применения промокодов", for: .normal)
        b.setTitleColor(UIColor.systemGreen, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let codeLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .monospacedDigitSystemFont(ofSize: 16, weight: .medium)
        l.textColor = .label
        l.backgroundColor = .secondarySystemBackground
        l.layer.cornerRadius = 10
        l.layer.masksToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = "Назад"

        layout()
        codeLabel.text = "Промокод: \(ReferralManager.code)"
        inviteButton.addTarget(self, action: #selector(inviteTapped), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)

        // tap-to-copy
        let tap = UITapGestureRecognizer(target: self, action: #selector(copyCode))
        codeLabel.isUserInteractionEnabled = true
        codeLabel.addGestureRecognizer(tap)
    }

    private func layout() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(inviteButton)
        view.addSubview(codeLabel)
        view.addSubview(termsButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            inviteButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            inviteButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            inviteButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            inviteButton.heightAnchor.constraint(equalToConstant: 56),

            codeLabel.topAnchor.constraint(equalTo: inviteButton.bottomAnchor, constant: 16),
            codeLabel.leadingAnchor.constraint(equalTo: inviteButton.leadingAnchor),
            codeLabel.trailingAnchor.constraint(equalTo: inviteButton.trailingAnchor),
            codeLabel.heightAnchor.constraint(equalToConstant: 48),

            termsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            termsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    @objc private func inviteTapped() {
        let items: [Any] = [ReferralManager.shareMessage]
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(vc, animated: true)
    }

    @objc private func copyCode() {
        UIPasteboard.general.string = ReferralManager.code
        let alert = UIAlertController(title: "Скопировано",
                                      message: "Промокод \(ReferralManager.code) скопирован",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func termsTapped() {
        // открой свою страницу условий или заглушку
        let alert = UIAlertController(title: "Условия",
                                      message: "Здесь откроются условия применения промокодов.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        present(alert, animated: true)
    }
}

