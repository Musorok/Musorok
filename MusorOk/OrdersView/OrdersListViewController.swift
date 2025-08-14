//
//  OrdersListViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import UIKit

final class OrdersListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    enum Kind { case active, history }
    private var isLoadedOnce = false
    private let refresh = UIRefreshControl()

    private let kind: Kind
    private let table = UITableView(frame: .zero, style: .plain)
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 17)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // mock data; потом подставишь из бэка
    private var items: [String] = []

    init(kind: Kind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.tableFooterView = UIView()
        view.addSubview(table)

        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])

        emptyLabel.text = (kind == .active) ? "Нет активных заказов" : "Нет выполненных заказов"
        updateEmptyState()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            table.rowHeight = 64

            // Pull-to-refresh
            refresh.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
            table.refreshControl = refresh
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if kind == .active {
            loadActive()          // уже добавлено ранее
        } else {
            loadHistory()         // ← добавляем этот вызов
        }
    }

    private func updateEmptyState() {
        let isEmpty = items.isEmpty
        table.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
    }
    
    // изменим сигнатуры (добавим флаг):
    private func loadActive(isPullToRefresh: Bool = false) {
        if !isPullToRefresh {
            emptyLabel.text = "Загрузка..."
            emptyLabel.isHidden = false
            table.isHidden = true
        }

        APIClient.shared.getActiveOrders { [weak self] result in
            guard let self = self else { return }
            defer { self.refresh.endRefreshing() } // важно: останавливаем refresh

            switch result {
            case .success(let list):
                // показываем адрес (или #id) и статус/дату в подзаголовке
                self.items = list.map { o in
                    let title = (o.address?.isEmpty == false) ? o.address! : "Заказ #\(o.id)"
                    let detail: String = {
                        let s = (o.status?.isEmpty == false) ? o.status! : "в обработке"
                        let t = self.format(o.createdAt) ?? ""
                        return t.isEmpty ? s : "\(s) • \(t)"
                    }()
                    return "\(title)\n\(detail)" // используем две строки (см. cellForRow)
                }
                self.emptyLabel.text = "Нет активных заказов"
                self.updateEmptyState()
                self.table.reloadData()

            case .failure(let err):
                if case let .server(message, code) = err, code == 401 {
                    self.items = []
                    self.updateEmptyState()
                    let ac = UIAlertController(title: "Сессия истекла", message: message, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Войти", style: .default) { _ in
                        AuthManager.shared.logout()
                    })
                    ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
                    self.present(ac, animated: true)
                } else {
                    self.items = []
                    self.emptyLabel.text = "Не удалось загрузить. Потяните вниз, чтобы обновить."
                    self.updateEmptyState()
                }
            }
        }
    }

    private func loadHistory(isPullToRefresh: Bool = false) {
        if !isPullToRefresh {
            emptyLabel.text = "Загрузка..."
            emptyLabel.isHidden = false
            table.isHidden = true
        }

        APIClient.shared.getOrderHistory { [weak self] result in
            guard let self = self else { return }
            defer { self.refresh.endRefreshing() }

            switch result {
            case .success(let list):
                self.items = list.map { o in
                    let title = (o.address?.isEmpty == false) ? o.address! : "Заказ #\(o.id)"
                    let detail: String = {
                        let s = (o.status?.isEmpty == false) ? o.status! : "завершён"
                        let t = self.format(o.finishedAt) ?? ""
                        return t.isEmpty ? s : "\(s) • \(t)"
                    }()
                    return "\(title)\n\(detail)"
                }
                self.emptyLabel.text = "Нет выполненных заказов"
                self.updateEmptyState()
                self.table.reloadData()

            case .failure(let err):
                if case let .server(message, code) = err, code == 401 {
                    self.items = []
                    self.updateEmptyState()
                    let ac = UIAlertController(title: "Сессия истекла", message: message, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Войти", style: .default) { _ in
                        AuthManager.shared.logout()
                    })
                    ac.addAction(UIAlertAction(title: "Отмена", style: .cancel))
                    self.present(ac, animated: true)
                } else {
                    self.items = []
                    self.emptyLabel.text = "Не удалось загрузить. Потяните вниз, чтобы обновить."
                    self.updateEmptyState()
                }
            }
        }
    }

    
    @objc private func onRefresh() {
        if kind == .active {
            loadActive(isPullToRefresh: true)
        } else {
            loadHistory(isPullToRefresh: true)
        }
    }
    
    private func format(_ iso: String?) -> String? {
        guard let iso, !iso.isEmpty else { return nil }
        // если бэк вернёт ISO-8601 — этого хватит
        let f = ISO8601DateFormatter()
        if let d = f.date(from: iso) {
            let out = DateFormatter()
            out.locale = Locale(identifier: "ru_RU")
            out.dateFormat = "dd.MM HH:mm"
            return out.string(from: d)
        }
        return iso // как fallback покажем как есть
    }

    // MARK: table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "cell") ??
                   UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.numberOfLines = 1
        cell.detailTextLabel?.numberOfLines = 1  // если стиль .subtitle — будет работать

        let combo = items[indexPath.row].components(separatedBy: "\n")
        cell.textLabel?.text = combo.first
        cell.detailTextLabel?.text = (combo.count > 1) ? combo[1] : nil
        cell.selectionStyle = .none
        return cell
    }
}

