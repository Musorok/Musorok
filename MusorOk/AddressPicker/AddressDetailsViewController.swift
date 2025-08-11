//
//  AddressDetailsViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 11.08.2025.
//

import UIKit

final class AddressDetailsViewController: UIViewController {

    // входные данные
    private let addressLine: String
    var onSubmit: ((AddressDetails) -> Void)?

    // UI
    private let scroll = UIScrollView()
    private let content = UIStackView()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // 2x2 поля
    private let apartmentField = FormInputView(title: "Номер квартиры*", placeholder: "", keyboard: .numberPad, isSecure: false)
    private let floorField     = FormInputView(title: "Этаж*", placeholder: "", keyboard: .numberPad, isSecure: false)
    private let entranceField  = FormInputView(title: "Подъезд*", placeholder: "", keyboard: .numberPad, isSecure: false)
    private let intercomField  = FormInputView(title: "Домофон", placeholder: "", keyboard: .numbersAndPunctuation, isSecure: false)

    // настройки
    private let noCallTitle = UILabel()
    private let noCallSubtitle = UILabel()
    private let noCallSwitch = UISwitch()

    private let saveAddressTitle = UILabel()
    private let saveAddressSwitch: UISwitch = {
        let s = UISwitch()
        s.isOn = false
        return s
    }()

    private let addressNameField = FormInputView(title: "Название адреса", placeholder: "", keyboard: .default, isSecure: false)

    private let submitButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Сделать заказ", for: .normal)
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Init
    init(addressLine: String) {
        self.addressLine = addressLine
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .label
        setupLayout()
        setupBehavior()
        titleLabel.text = addressLine

        // реакции для валидации
        [apartmentField, floorField, entranceField, addressNameField].forEach {
            $0.onTextChange = { [weak self] _ in self?.validateForm() }
        }
        saveAddressSwitch.addTarget(self, action: #selector(validateForm), for: .valueChanged)
        if saveAddressSwitch.isOn { onSaveSwitch() }
        // выставить начальное состояние кнопки
        validateForm()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let extra = 56 + 12 + view.safeAreaInsets.bottom // высота кнопки + отступ
        scroll.contentInset.bottom = extra
        scroll.verticalScrollIndicatorInsets.bottom = extra
    }

    // MARK: - UI
    private func setupLayout() {
        // scroll + content
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .interactive
        scroll.translatesAutoresizingMaskIntoConstraints = false

        content.axis = .vertical
        content.spacing = 20
        content.isLayoutMarginsRelativeArrangement = true
        content.layoutMargins = .init(top: 16, left: 24, bottom: 24, right: 24)
        content.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scroll)
        scroll.addSubview(content)

        NSLayoutConstraint.activate([
            // скролл во весь экран
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // ВАЖНО: контент к contentLayoutGuide/ frameLayoutGuide
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor),
            content.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor) // фикс ширины, чтобы не было горизонтального скролла
        ])

        // заголовок
        content.addArrangedSubview(titleLabel)

        // 2x2 поля
        let row1 = UIStackView(arrangedSubviews: [apartmentField, floorField])
        let row2 = UIStackView(arrangedSubviews: [entranceField, intercomField])
        [row1, row2].forEach {
            $0.axis = .horizontal
            $0.spacing = 16
            $0.distribution = .fillEqually
            content.addArrangedSubview($0)
        }

        // «Не звонить»
        let noCallRow = UIView()
        noCallRow.translatesAutoresizingMaskIntoConstraints = false
        noCallTitle.text = "Не звонить"
        noCallTitle.font = .systemFont(ofSize: 20, weight: .semibold)
        noCallSubtitle.text = "Курьер позвонит только в случае крайней необходимости"
        noCallSubtitle.textColor = .secondaryLabel
        noCallSubtitle.numberOfLines = 0
        [noCallTitle, noCallSubtitle, noCallSwitch].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            noCallRow.addSubview($0)
        }
        NSLayoutConstraint.activate([
            noCallTitle.topAnchor.constraint(equalTo: noCallRow.topAnchor),
            noCallTitle.leadingAnchor.constraint(equalTo: noCallRow.leadingAnchor),
            noCallTitle.trailingAnchor.constraint(lessThanOrEqualTo: noCallSwitch.leadingAnchor, constant: -12),

            noCallSwitch.centerYAnchor.constraint(equalTo: noCallTitle.centerYAnchor),
            noCallSwitch.trailingAnchor.constraint(equalTo: noCallRow.trailingAnchor),

            noCallSubtitle.topAnchor.constraint(equalTo: noCallTitle.bottomAnchor, constant: 6),
            noCallSubtitle.leadingAnchor.constraint(equalTo: noCallRow.leadingAnchor),
            noCallSubtitle.trailingAnchor.constraint(equalTo: noCallRow.trailingAnchor),
            noCallSubtitle.bottomAnchor.constraint(equalTo: noCallRow.bottomAnchor)
        ])
        content.addArrangedSubview(noCallRow)

        // «Запомнить адрес»
        let saveRow = UIView()
        saveRow.translatesAutoresizingMaskIntoConstraints = false
        saveAddressTitle.text = "Запомнить адрес"
        saveAddressTitle.font = .systemFont(ofSize: 20, weight: .semibold)
        [saveAddressTitle, saveAddressSwitch].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            saveRow.addSubview($0)
        }
        NSLayoutConstraint.activate([
            saveAddressTitle.topAnchor.constraint(equalTo: saveRow.topAnchor),
            saveAddressTitle.leadingAnchor.constraint(equalTo: saveRow.leadingAnchor),
            saveAddressTitle.trailingAnchor.constraint(lessThanOrEqualTo: saveRow.trailingAnchor),

            saveAddressSwitch.centerYAnchor.constraint(equalTo: saveAddressTitle.centerYAnchor),
            saveAddressSwitch.trailingAnchor.constraint(equalTo: saveRow.trailingAnchor),
            saveAddressSwitch.bottomAnchor.constraint(equalTo: saveRow.bottomAnchor)
        ])
        content.addArrangedSubview(saveRow)

        content.addArrangedSubview(addressNameField)

        // кнопка
        view.addSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            submitButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
    }


    private func setupBehavior() {
        // скрываем «Название адреса», если выключили «Запомнить адрес»
        addressNameField.isHidden = !saveAddressSwitch.isOn
        saveAddressSwitch.addTarget(self, action: #selector(onSaveSwitch), for: .valueChanged)

        let tap = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions
    @objc private func back() { navigationController?.popViewController(animated: true) }
    @objc private func endEdit() { view.endEditing(true) }

    @objc private func onSaveSwitch() {
        addressNameField.isHidden = !saveAddressSwitch.isOn

        if saveAddressSwitch.isOn {
            let current = (addressNameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if current.isEmpty {
                // подставляем адрес с карты
                addressNameField.setText(addressLine)  // если есть setter
                // либо, если у тебя метод:
                // addressNameField.setText(addressLine)
            }
        }
        validateForm()
    }

    @objc private func validateForm() {
        let trim: (String?) -> String = { ($0 ?? "").trimmingCharacters(in: .whitespacesAndNewlines) }
        let aptOK  = !trim(apartmentField.text).isEmpty
        let floorOK = !trim(floorField.text).isEmpty
        let entOK   = !trim(entranceField.text).isEmpty
        let nameOK  = !saveAddressSwitch.isOn || !trim(addressNameField.text).isEmpty
        submitButton.isEnabled = aptOK && floorOK && entOK && nameOK
    }

    @objc private func submit() {
        guard submitButton.isEnabled else { return }
        let payload = AddressDetails(
            addressLine: addressLine,
            apartment: apartmentField.text ?? "",
            floor: floorField.text ?? "",
            entrance: entranceField.text ?? "",
            intercom: intercomField.text,
            noCall: noCallSwitch.isOn,
            saveAddress: saveAddressSwitch.isOn,
            addressName: saveAddressSwitch.isOn ? (addressNameField.text ?? "") : nil
        )
        let vc = TrashQuantityViewController(details: payload)
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(vc, animated: true)
    }
}

