//
//  AddressesViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 12.08.2025.
//

import UIKit

final class AddressesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var items: [SavedAddress] = []

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Мои адреса"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        t.tableFooterView = UIView()
        return t
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "Нет сохраненных адресов"
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 18, weight: .medium)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.backButtonTitle = "Назад"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        layout()
        reload()
    }

    private func layout() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 120),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func reload() {
        items = AddressStore.load()
        tableView.reloadData()
        emptyLabel.isHidden = !items.isEmpty
    }

    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = items[indexPath.row]

        var cfg = UIListContentConfiguration.subtitleCell()
        cfg.text = item.label.isEmpty ? item.line : item.label
        cfg.secondaryText = item.label.isEmpty ? nil : item.line
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // свайп-удаление
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let del = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _,_,done in
            guard let self = self else { return }
            AddressStore.remove(id: self.items[indexPath.row].id)
            self.reload()
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [del])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // тут можешь открыть редактирование адреса или сразу оформить заказ с выбранным адресом
    }

    // MARK: - Add
    @objc private func addTapped() {
        // шаг 1: выбор на карте
        let picker = AddressPickerViewController()
        // когда пользователь подтвердит адрес, пушни форму подъезда/кв.,
        // а после сохранения положи в AddressStore и обнови список.
        navigationController?.pushViewController(picker, animated: true)
    }
}

