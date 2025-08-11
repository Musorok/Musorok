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
    private var times: [DateComponents] = []
    private var selectedDayIndex = 0
    private var selectedTimeIndex = 0

    private var didSetInsets = false

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

    // 7 дней с сегодня + слоты 09:00...21:00
    private func buildData() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        dates = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: today) }
        times = (9...21).map { DateComponents(hour: $0, minute: 0) }

        // выберем ближайший доступный слот на сегодня
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

        // dim
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

        // container
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

        // заголовки
        let title = UILabel()
        title.text = "Выберите время"
        title.font = .systemFont(ofSize: 28, weight: .bold)

        let subtitle = UILabel()
        subtitle.text = "Заказ будет выполнен\nв назначенную дату и время"
        subtitle.numberOfLines = 0
        subtitle.textColor = .secondaryLabel
        subtitle.font = .systemFont(ofSize: 16)

        // даты
        let datesLayout = CenterSnappingFlowLayout()
        datesLayout.scrollDirection = .horizontal
        datesLayout.minimumLineSpacing = 12
        daysCV = UICollectionView(frame: .zero, collectionViewLayout: datesLayout)
        daysCV.backgroundColor = .clear
        daysCV.showsHorizontalScrollIndicator = false
        daysCV.decelerationRate = .normal
        daysCV.register(PillCell.self, forCellWithReuseIdentifier: "day")
        daysCV.delegate = self; daysCV.dataSource = self

        // время
        let timesLayout = CenterSnappingFlowLayout()
        timesLayout.scrollDirection = .horizontal
        timesLayout.minimumLineSpacing = 12
        timesCV = UICollectionView(frame: .zero, collectionViewLayout: timesLayout)
        timesCV.backgroundColor = .clear
        timesCV.showsHorizontalScrollIndicator = false
        timesCV.decelerationRate = .fast
        timesCV.register(PillCell.self, forCellWithReuseIdentifier: "time")
        timesCV.delegate = self; timesCV.dataSource = self

        // кнопка
        let confirm = PrimaryButton()
        confirm.setTitle("Указать", for: .normal)
        confirm.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        // layout
        for v in [title, subtitle, daysCV!, timesCV!, confirm] as [UIView] {
            v.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(v)
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

    // инсет для центрирования первого/последнего, + прокрутка к выбранному
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !didSetInsets else { return }

        let dayItemW = daysCV.bounds.width * 0.75
        let daySide  = max(0, (daysCV.bounds.width - dayItemW) / 2)
        daysCV.contentInset = UIEdgeInsets(top: 0, left: daySide, bottom: 0, right: daySide)

        let timeItemW: CGFloat = 96
        let timeSide  = max(0, (timesCV.bounds.width - timeItemW) / 2)
        timesCV.contentInset = UIEdgeInsets(top: 0, left: timeSide, bottom: 0, right: timeSide)

        didSetInsets = true
        scrollToSelected(animated: false)
    }

    private func scrollToSelected(animated: Bool) {
        if selectedDayIndex < dates.count {
            daysCV.scrollToItem(at: IndexPath(item: selectedDayIndex, section: 0),
                                at: .centeredHorizontally, animated: animated)
        }
        if selectedTimeIndex < times.count {
            timesCV.scrollToItem(at: IndexPath(item: selectedTimeIndex, section: 0),
                                 at: .centeredHorizontally, animated: animated)
        }
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
extension TimePickerSheetController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cv === daysCV ? dates.count : times.count
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = (cv === daysCV) ? "day" : "time"
        let cell = cv.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! PillCell
        if cv === daysCV {
            cell.title = dfDay.string(from: dates[indexPath.item])
            cell.isOn = (indexPath.item == selectedDayIndex)
        } else {
            let comps = times[indexPath.item]
            let sample = Calendar.current.date(from: comps) ?? Date()
            cell.title = dfTime.string(from: sample)
            cell.isOn = (indexPath.item == selectedTimeIndex)
        }
        return cell
    }

    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cv === daysCV {
            selectedDayIndex = indexPath.item
            daysCV.reloadData()
            daysCV.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            selectedTimeIndex = indexPath.item
            timesCV.reloadData()
            timesCV.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    // размеры «пилюлек»
    func collectionView(_ cv: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (cv === daysCV) ? (cv.bounds.width * 0.75) : 96
        return CGSize(width: w, height: 44)
    }
}

