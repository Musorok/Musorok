//
//  PaymentViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 17.08.2025.
//

import UIKit

enum PaymentMethod: String, CaseIterable {
    case card = "Банковская карта"
    case applePay = "Apple Pay"
    case qr = "QR (Kaspi/Halyk)"
}

final class PaymentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let orderId: Int?  // если заказ уже создан — передавай сюда id
    private let amount: Int
    private var selected: PaymentMethod? = .applePay

    // UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Оплата заказа"
        l.font = .boldSystemFont(ofSize: 20)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let amountLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let table = UITableView(frame: .zero, style: .insetGrouped)
    private let payButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Оплатить", for: .normal)
        b.titleLabel?.font = .boldSystemFont(ofSize: 18)
        b.backgroundColor = .systemGreen
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 12
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    init(orderId: Int?, amount: Int) {
        self.orderId = orderId
        self.amount = amount
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildUI()
        amountLabel.text = "К оплате: \(amount) ₸"
        payButton.addTarget(self, action: #selector(payTapped), for: .touchUpInside)
    }

    private func buildUI() {
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self

        view.addSubview(titleLabel)
        view.addSubview(amountLabel)
        view.addSubview(table)
        view.addSubview(payButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            amountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            table.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 12),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: payButton.topAnchor, constant: -16),

            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            payButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { PaymentMethod.allCases.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let m = PaymentMethod.allCases[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = m.rawValue
        cell.accessoryType = (m == selected) ? .checkmark : .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected = PaymentMethod.allCases[indexPath.row]
        tableView.reloadData()
    }

    // MARK: - Pay
    @objc private func payTapped() {
        guard let selected else {
            let ac = UIAlertController(title: "Выберите способ оплаты", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }

        payButton.isEnabled = false
        payButton.alpha = 0.7

        // TODO: заменить на реальный вызов бэка
        APIClient.shared.createOrPay(orderId: orderId, amount: amount, method: selected) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.payButton.isEnabled = true
                self.payButton.alpha = 1.0

                switch result {
                case .success:
                    // Закрываем шторку и просим RootTabBar открыть "Мои заказы → Активные"
                    self.dismiss(animated: true) {
                        NotificationCenter.default.post(name: .openMyOrdersActive, object: nil)
                    }
                case .failure(let error):
                    let ac = UIAlertController(title: "Оплата не прошла", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }
}

// Глобальные события
extension Notification.Name {
    /// RootTabBar должен переключиться на «Мои заказы», а MyOrders — на «Активные»
    static let openMyOrdersActive = Notification.Name("openMyOrdersActive")
    /// Внутри MyOrders — переключаем таб на «Активные»
    static let switchOrdersToActive = Notification.Name("switchOrdersToActive")
}
