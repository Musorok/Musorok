//
//  TrashQuantityViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 11.08.2025.
//

import UIKit

final class TrashQuantityViewController: UIViewController {

    // вход: данные из AddressDetails
    let details: AddressDetails
    init(details: AddressDetails) {
        self.details = details
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // цена
    private let pricePerBagKZT = Pricing.pricePerBagKZT
    private var count = 0 { didSet { updateUI() } }

    // UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Кол-во мусора"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let bagSubtitle: UILabel = {
        let l = UILabel()
        l.text = "От пакета из супермаркета"
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let bagTitle: UILabel = {
        let l = UILabel()
        l.text = "   до большого\nмусорного мешка"
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.textAlignment = .center
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let bagImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "musor70")?.withRenderingMode(.alwaysOriginal))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let amountTitle: UILabel = {
        let l = UILabel()
        l.text = "Кол-во мешков"
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let stepperView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 26
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.systemGray4.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let minusBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "minus"), for: .normal)
        b.tintColor = .label
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private let plusBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "plus"), for: .normal)
        b.tintColor = .label
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private let countLabel: UILabel = {
        let l = UILabel()
        l.text = "0"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // футер
    private let footer = UIView()
    private let priceTitle: UILabel = {
        let l = UILabel()
        l.text = "Стоимость заказа"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let priceValue: UILabel = {
        let l = UILabel()
        l.text = "0 ₸"
        l.font = .systemFont(ofSize: 24, weight: .bold)
        l.textAlignment = .right
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let nextButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Детали заказа", for: .normal)
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        layout()
        hooks()
        updateUI()
    }

    private func layout() {
        // Заголовок
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
        
        view.addSubview(bagSubtitle)
        view.addSubview(bagTitle)

        NSLayoutConstraint.activate([
            bagSubtitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            bagSubtitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            bagTitle.topAnchor.constraint(equalTo: bagSubtitle.bottomAnchor, constant: 1),
            bagTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])


        // Иконка
        view.addSubview(bagImage)
        NSLayoutConstraint.activate([
            bagImage.topAnchor.constraint(equalTo: bagTitle.bottomAnchor, constant: 8),
            bagImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            bagImage.widthAnchor.constraint(equalToConstant: 100),
            bagImage.heightAnchor.constraint(equalToConstant: 100)
        ])

        // СТЕППЕР — добавляем ПЕРВЫМ из пары, чтобы amountTitle мог на него ссылаться
        view.addSubview(stepperView)
        stepperView.addSubview(minusBtn)
        stepperView.addSubview(countLabel)
        stepperView.addSubview(plusBtn)

        NSLayoutConstraint.activate([
            // степпер справа от картинки
            stepperView.topAnchor.constraint(equalTo: bagImage.centerYAnchor), // или amountTitle.bottom + 8 ниже поставим title
            stepperView.leadingAnchor.constraint(equalTo: bagImage.trailingAnchor, constant: 70),
            stepperView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stepperView.heightAnchor.constraint(equalToConstant: 45),

            minusBtn.leadingAnchor.constraint(equalTo: stepperView.leadingAnchor, constant: 16),
            minusBtn.centerYAnchor.constraint(equalTo: stepperView.centerYAnchor),

            plusBtn.trailingAnchor.constraint(equalTo: stepperView.trailingAnchor, constant: -16),
            plusBtn.centerYAnchor.constraint(equalTo: stepperView.centerYAnchor),

            countLabel.centerXAnchor.constraint(equalTo: stepperView.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: stepperView.centerYAnchor),
        ])

        // ТЕКСТ НАД СТЕППЕРОМ — теперь можно ссылаться на stepperView
        view.addSubview(amountTitle)
        NSLayoutConstraint.activate([
            amountTitle.leadingAnchor.constraint(equalTo: stepperView.leadingAnchor),              // выравнивание по левому краю степпера
            amountTitle.bottomAnchor.constraint(equalTo: stepperView.topAnchor, constant: -5),     // 5 pt над степпером
            amountTitle.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])

        // ФУТЕР (цена + кнопка) — общий контейнер
        footer.translatesAutoresizingMaskIntoConstraints = false
        footer.backgroundColor = .systemBackground
        view.addSubview(footer)

        NSLayoutConstraint.activate([
            footer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        footer.addSubview(priceTitle)
        footer.addSubview(priceValue)
        footer.addSubview(nextButton)

        NSLayoutConstraint.activate([
            // строка цены
            priceTitle.topAnchor.constraint(equalTo: footer.topAnchor, constant: 12),
            priceTitle.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 24),

            priceValue.centerYAnchor.constraint(equalTo: priceTitle.centerYAnchor),
            priceValue.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -24),
            priceValue.leadingAnchor.constraint(greaterThanOrEqualTo: priceTitle.trailingAnchor, constant: 8),

            // кнопка
            nextButton.topAnchor.constraint(equalTo: priceTitle.bottomAnchor, constant: 16),
            nextButton.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -24),
            nextButton.heightAnchor.constraint(equalToConstant: 56),
            nextButton.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -12) // задаёт высоту футера
        ])
    }


    private func hooks() {
        minusBtn.addTarget(self, action: #selector(dec), for: .touchUpInside)
        plusBtn.addTarget(self, action: #selector(inc), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
    }

    @objc private func dec() {
        guard count > 0 else { return }
        count -= 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @objc private func inc() {
        count += 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func updateUI() {
        countLabel.text = "\(count)"
        let total = count * pricePerBagKZT
        priceValue.text = "\(total) ₸"      // тенге
        nextButton.isEnabled = count > 0
    }

    @objc private func nextTapped() {
        guard count > 0 else { return }
        let vc = OrderDetailsViewController(details: details, bagsCount: count, pricePerBagKZT: pricePerBagKZT)
        vc.onEditAddress = { [weak self] in
            self?.navigationController?.popToViewControllerOfType(AddressPickerViewController.self)
        }
        vc.onEditBags = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        vc.onProceedToPay = { [weak self] scheduledAt in
            // создать заказ…
        }
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.pushViewController(vc, animated: true)
    }
}
