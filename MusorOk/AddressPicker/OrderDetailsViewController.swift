//
//  OrderDetailsViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 11.08.2025.
//

import UIKit

final class OrderDetailsViewController: UIViewController {

    // входные данные
    private let details: AddressDetails
    private let bagsCount: Int
    private let pricePerBagKZT: Int
    private var totalKZT: Int { bagsCount * pricePerBagKZT }

    // колбэки в твой флоу
    var onEditAddress: (() -> Void)?
    var onEditBags: (() -> Void)?
    var onProceedToPay: ((_ scheduledAt: Date?) -> Void)?

    // состояние "когда"
    private enum Arrival { case asap, scheduled(Date) }
    private var arrival: Arrival = .asap { didSet { updateArrivalUI() } }

    // UI
    private let scroll = UIScrollView()
    private let stack = UIStackView()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Детали заказа"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Адрес
    private let addressCaption = OrderDetailsViewController.makeCaption("Адрес")
    private let addressLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 17)
        return l
    }()
    private let addressEdit = OrderDetailsViewController.editButton()

    // Состав
    private let compositionCaption = OrderDetailsViewController.makeCaption("Состав")
    private let compositionLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 17)
        return l
    }()
    private let compositionEdit = OrderDetailsViewController.editButton()

    // Радио «когда»
    private let arrivalCaption = OrderDetailsViewController.makeCaption("Курьер приедет")
    private let asapRow = RadioRow(title: "Как можно скорее", isOn: true)
    private let byTimeRow = RadioRow(title: "Ко времени", isOn: false)
    private let scheduledHint = UILabel()

    // Комментарий
    private let commentCaption = OrderDetailsViewController.makeCaption("Комментарий курьеру")
    private let commentView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.cornerRadius = 12
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        tv.heightAnchor.constraint(greaterThanOrEqualToConstant: 92).isActive = true
        return tv
    }()

    // Низ
    private let priceTitle: UILabel = {
        let l = UILabel()
        l.text = "Стоимость заказа"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        return l
    }()
    private let priceValue = UILabel()
    private let payButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Перейти к оплате", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: init
    init(details: AddressDetails, bagsCount: Int, pricePerBagKZT: Int = 150) {
        self.details = details
        self.bagsCount = bagsCount
        self.pricePerBagKZT = pricePerBagKZT
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        buildUI()
        fillData()
        wire()
    }

    private func buildUI() {
        // scroll + stack
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -16),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -40)
        ])

        // заголовок
        stack.addArrangedSubview(titleLabel)

        // Адрес + edit
        stack.addArrangedSubview(addressCaption)
        stack.setCustomSpacing(3, after: addressCaption)
        stack.addArrangedSubview(hStack(addressLabel, trailing: addressEdit))

        // Состав + edit
        stack.addArrangedSubview(compositionCaption)
        stack.setCustomSpacing(3, after: compositionCaption)
        stack.addArrangedSubview(hStack(compositionLabel, trailing: compositionEdit))

        // Радио
        stack.addArrangedSubview(arrivalCaption)
        stack.setCustomSpacing(3, after: arrivalCaption)
        stack.addArrangedSubview(asapRow)
        stack.addArrangedSubview(byTimeRow)

        stack.setCustomSpacing(3, after: asapRow)
        scheduledHint.textColor = .secondaryLabel
        scheduledHint.font = .systemFont(ofSize: 15)
        scheduledHint.isHidden = true
        stack.addArrangedSubview(scheduledHint)

        // Комментарий
        stack.addArrangedSubview(commentCaption)
        stack.addArrangedSubview(commentView)

        // Нижняя панель
        let bottom = UIView()
        bottom.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottom)
        NSLayoutConstraint.activate([
            bottom.topAnchor.constraint(equalTo: scroll.bottomAnchor),
            bottom.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottom.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottom.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        let priceRow = UIStackView(arrangedSubviews: [priceTitle, UIView(), priceValue])
        priceRow.axis = .horizontal
        priceRow.alignment = .center
        priceRow.translatesAutoresizingMaskIntoConstraints = false
        priceValue.font = .systemFont(ofSize: 24, weight: .bold)

        bottom.addSubview(priceRow)
        bottom.addSubview(payButton)
        NSLayoutConstraint.activate([
            priceRow.leadingAnchor.constraint(equalTo: bottom.leadingAnchor, constant: 20),
            priceRow.trailingAnchor.constraint(equalTo: bottom.trailingAnchor, constant: -20),
            priceRow.topAnchor.constraint(equalTo: bottom.topAnchor, constant: 8),

            payButton.leadingAnchor.constraint(equalTo: bottom.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: bottom.trailingAnchor, constant: -20),
            payButton.bottomAnchor.constraint(equalTo: bottom.bottomAnchor, constant: -12),
            payButton.topAnchor.constraint(equalTo: priceRow.bottomAnchor, constant: 8),
            payButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func wire() {
        addressEdit.addTarget(self, action: #selector(editAddress), for: .touchUpInside)
        compositionEdit.addTarget(self, action: #selector(editBags), for: .touchUpInside)

        asapRow.onTap = { [weak self] in self?.arrival = .asap }
        byTimeRow.onTap = { [weak self] in self?.presentTimePicker() }

        payButton.addTarget(self, action: #selector(pay), for: .touchUpInside)
    }

    private func fillData() {
        var addr = details.addressLine
        var parts: [String] = []
        if !details.apartment.isEmpty { parts.append("кв. \(details.apartment)") }
        if !details.floor.isEmpty     { parts.append("эт. \(details.floor)") }
        if !details.entrance.isEmpty  { parts.append("подъезд \(details.entrance)") }
        if let inter = details.intercom, !inter.isEmpty { parts.append("домофон \(inter)") }
        if !parts.isEmpty { addr += ", " + parts.joined(separator: ", ") }
        addressLabel.text = addr

        let bagsWord = bagsCount == 1 ? "мешок" : (bagsCount < 5 ? "мешка" : "мешков")
        compositionLabel.text = "\(bagsCount) \(bagsWord) по 70 литров"

        priceValue.text = "\(totalKZT) ₸"
    }

    private func updateArrivalUI() {
        switch arrival {
        case .asap:
            asapRow.isOn = true
            byTimeRow.isOn = false
            scheduledHint.isHidden = true
            byTimeRow.setTitle("Ко времени")
        case .scheduled(let date):
            asapRow.isOn = false
            byTimeRow.isOn = true
            scheduledHint.isHidden = true
            let df = DateFormatter()
            df.locale = Locale(identifier: "ru_RU")
            df.dateFormat = "d MMMM, HH:mm"
            byTimeRow.setTitle("К \(df.string(from: date))")
        }
    }

    @objc private func editAddress() { onEditAddress?() }
    @objc private func editBags()    { onEditBags?() }

    @objc private func pay() {
        let when: Date? = {
            if case .scheduled(let d) = arrival { return d }
            return nil
        }()
        onProceedToPay?(when)
    }

    // helpers
    private func hStack(_ leading: UIView, trailing: UIView) -> UIView {
        let v = UIView()
        leading.translatesAutoresizingMaskIntoConstraints = false
        trailing.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(leading); v.addSubview(trailing)
        NSLayoutConstraint.activate([
            leading.topAnchor.constraint(equalTo: v.topAnchor),
            leading.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            leading.bottomAnchor.constraint(equalTo: v.bottomAnchor),

            trailing.leadingAnchor.constraint(greaterThanOrEqualTo: leading.trailingAnchor, constant: 8),
            trailing.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            trailing.centerYAnchor.constraint(equalTo: leading.firstBaselineAnchor)
        ])
        return v
    }

    private static func makeCaption(_ t: String) -> UILabel {
        let l = UILabel()
        l.text = t
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        return l
    }
    private static func editButton() -> UIButton {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "pencil"), for: .normal)
        b.tintColor = .tertiaryLabel
        return b
    }

    // MARK: Time picker
    private func presentTimePicker() {
        let sheet = TimePickerSheetController()
        sheet.modalPresentationStyle = .overCurrentContext
        sheet.onConfirm = { [weak self] date in
            self?.arrival = .scheduled(date)
        }
        present(sheet, animated: false, completion: nil)
    }
}

