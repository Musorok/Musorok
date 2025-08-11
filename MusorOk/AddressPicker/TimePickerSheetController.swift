//
//  TimePickerSheetController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 11.08.2025.
//

import UIKit

final class TimePickerSheetController: UIViewController, UICollectionViewDelegate {

    var onConfirm: ((Date) -> Void)?

    private let dimView = UIView()
    private let container = UIView()
    private var bottomC: NSLayoutConstraint!

    private var dates: [Date] = []
    private var times: [DateComponents] = [] // только часы/минуты
    private var selectedDayIndex = 0
    private var selectedTimeIndex = 0

    private lazy var dfDay: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "d MMMM, EEEE"
        return f
    }()
    private lazy var dfTime: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ru_RU")
        f.dateFormat = "HH:mm"
        return f
    }()

    private var daysCV: UICollectionView!
    private var timesCV: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        buildData()
        buildUI()
        presentAnimate()
    }

    private func buildData() {
        // 7 дней начиная с сегодня
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        dates = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: today) }

        // слоты 09:00...21:00
        times = (9...21).map { DateComponents(hour: $0, minute: 0) }

        // Предвыбор: ближайший слот ≥ текущего времени
        let now = Date()
        if let todayIdx = dates.firstIndex(where: { cal.isDate($0, inSameDayAs: now) }) {
            selectedDayIndex = todayIdx
            let nowH = cal.component(.hour, from: now)
            if let idx = times.firstIndex(where: { ($0.hour ?? 0) > nowH }) {
                selectedTimeIndex = idx
            } else {
                selectedTimeIndex = max(0, times.count - 1)
            }
        }
    }

    private func buildUI() {
        view.backgroundColor = .clear

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissAnimate)))

        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 24
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(container)
        bottomC = container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 400)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomC
        ])

        let title = UILabel()
        title.text = "Выберите время"
        title.font = .systemFont(ofSize: 28, weight: .bold)

        let subtitle = UILabel()
        subtitle.text = "Заказ будет выполнен\nв назначенную дату и время"
        subtitle.numberOfLines = 0
        subtitle.textColor = .secondaryLabel
        subtitle.font = .systemFont(ofSize: 16)

        let datesLayout = UICollectionViewFlowLayout()
        datesLayout.scrollDirection = .horizontal
        datesLayout.minimumLineSpacing = 12
        datesLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        daysCV = UICollectionView(frame: .zero, collectionViewLayout: datesLayout)
        daysCV.backgroundColor = .clear
        daysCV.showsHorizontalScrollIndicator = false
        daysCV.decelerationRate = .fast
        daysCV.register(PillCell.self, forCellWithReuseIdentifier: "day")
        daysCV.delegate = self; daysCV.dataSource = self

        let timesLayout = UICollectionViewFlowLayout()
        timesLayout.scrollDirection = .horizontal
        timesLayout.minimumLineSpacing = 12
        timesLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        timesCV = UICollectionView(frame: .zero, collectionViewLayout: timesLayout)
        timesCV.backgroundColor = .clear
        timesCV.showsHorizontalScrollIndicator = false
        timesCV.decelerationRate = .fast
        timesCV.register(PillCell.self, forCellWithReuseIdentifier: "time")
        timesCV.delegate = self; timesCV.dataSource = self

        let confirm = PrimaryButton()
        confirm.setTitle("Указать", for: .normal)
        confirm.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        // layout
        for v in [title, subtitle, daysCV, timesCV, confirm] as [UIView?] {
            if let v = v {
                v.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(v)
            }
        }
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.trailingAnchor.constraint(equalTo: title.trailingAnchor),

            daysCV.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 16),
            daysCV.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            daysCV.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            daysCV.heightAnchor.constraint(equalToConstant: 52),

            timesCV.topAnchor.constraint(equalTo: daysCV.bottomAnchor, constant: 16),
            timesCV.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            timesCV.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            timesCV.heightAnchor.constraint(equalToConstant: 52),

            confirm.topAnchor.constraint(equalTo: timesCV.bottomAnchor, constant: 16),
            confirm.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            confirm.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            confirm.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            confirm.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: animation
    private func presentAnimate() {
        view.layoutIfNeeded()
        bottomC.constant = 0
        UIView.animate(withDuration: 0.28) {
            self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            self.view.layoutIfNeeded()
        }
    }
    @objc private func dismissAnimate() {
        bottomC.constant = 400
        UIView.animate(withDuration: 0.25, animations: {
            self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    @objc private func confirmTapped() {
        let cal = Calendar.current
        let day = dates[selectedDayIndex]
        let t = times[selectedTimeIndex]
        let date = cal.date(bySettingHour: t.hour ?? 9, minute: t.minute ?? 0, second: 0, of: day) ?? day
        onConfirm?(date)
        dismissAnimate()
    }
}

// MARK: - CollectionView
extension TimePickerSheetController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cv == daysCV ? dates.count : times.count
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: cv == daysCV ? "day" : "time", for: indexPath) as! PillCell
        if cv == daysCV {
            let d = dates[indexPath.item]
            cell.title = dfDay.string(from: d)
            cell.isOn = (indexPath.item == selectedDayIndex)
        } else {
            let comps = times[indexPath.item]
            let today = Calendar.current.date(from: comps) ?? Date()
            cell.title = dfTime.string(from: today)
            cell.isOn = (indexPath.item == selectedTimeIndex)
        }
        return cell
    }

    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cv == daysCV {
            selectedDayIndex = indexPath.item
            daysCV.reloadData()
        } else {
            selectedTimeIndex = indexPath.item
            timesCV.reloadData()
        }
    }

    // размеры «пилюлек»
    func collectionView(_ cv: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = cv == daysCV ? cv.bounds.width * 0.75 : 96
        return CGSize(width: w, height: 44)
    }
}

/// Чиповая ячейка
final class PillCell: UICollectionViewCell {
    private let label = UILabel()
    var title: String = "" { didSet { label.text = title } }
    var isOn: Bool = false { didSet { contentView.backgroundColor = isOn ? UIColor.systemGray5 : UIColor.systemGray6 } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 22
        contentView.backgroundColor = .systemGray6
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

