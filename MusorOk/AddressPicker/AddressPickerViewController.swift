//
//  AddressPickerViewController.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 10.08.2025.
//

import UIKit
import CoreLocation
import YandexMapsMobile

final class AddressPickerViewController: UIViewController, CLLocationManagerDelegate, YMKMapCameraListener {

    private enum SheetState { case medium, expanded }
    private var sheetState: SheetState = .medium

    private var bottomPanelHeight: NSLayoutConstraint!
    private var confirmBottomToKeyboard: NSLayoutConstraint?
    private var confirmBottomToSafeArea: NSLayoutConstraint!
    private var bottomPanelTop: NSLayoutConstraint!
    private var bottomToKeyboard: NSLayoutConstraint!
    private var didSetInitialSheetState = false
    private var didPlayLocatePulse = false
    private var panStartHeight: CGFloat = 0
    private var mediumH: CGFloat = 0        // вычисляется по экрану
    private var expandedH: CGFloat = 0       // вычисляется по экрану
    private var didComputeHeights = false

    // MARK: - Map / Location
    private var ymapView: YMKMapView!
    private var didKickoffLocation = false
    private var userLocationLayer: YMKUserLocationLayer!
    private let locationManager = CLLocationManager()

    // MARK: - SearchKit
    private var searchManager: YMKSearchManager!
    private var searchSession: YMKSearchSession?
    private var forwardSearchSession: YMKSearchSession?
    private var searchWorkItem: DispatchWorkItem?
    private var searchResults: [SearchResult] = []
    private struct SearchResult {
        let title: String
        let subtitle: String?
        let point: YMKPoint
    }

    // MARK: - UI
    private let locateButton: UIButton = {
        let b = UIButton(type: .system)
        if let img = UIImage(named: "location")?.withRenderingMode(.alwaysOriginal) {
            b.setImage(img, for: .normal)
        }
        b.tintColor = nil
        b.backgroundColor = .clear
        b.translatesAutoresizingMaskIntoConstraints = false
        b.widthAnchor.constraint(equalToConstant: 40).isActive = true
        b.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return b
    }()
    
    private let suggestionsContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        return v
    }()

    private let centerPin: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .brandGreen
        v.layer.cornerRadius = 10
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.cgColor
        v.widthAnchor.constraint(equalToConstant: 20).isActive = true
        v.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return v
    }()

    private let bottomPanel = UIView()
    private let grabber: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .tertiaryLabel
        v.layer.cornerRadius = 2
        return v
    }()

    // Убрали titleLabel — поле сразу сверху
    private let addressField = FormInputView(title: "Адрес, откуда забрать мусор", placeholder: "Введите адрес", keyboard: .default, isSecure: false)

    private let separator: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        return v
    }()

    private let confirmButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Подтвердить адрес", for: .normal)
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let suggestTable = UITableView(frame: .zero, style: .plain)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .label

        setupMap()
        setupLayout()
        setupLocation()
        wireSearchUI()

        locateButton.addTarget(self, action: #selector(centerOnUser), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleSheetPan(_:)))
        bottomPanel.addGestureRecognizer(pan)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        computeHeightsIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didSetInitialSheetState else { return }
        didSetInitialSheetState = true

        DispatchQueue.main.async { [weak self] in
            self?.computeHeightsIfNeeded()
            self?.applySheetState(.medium, animated: false)
            if self?.didPlayLocatePulse == false {
                self?.didPlayLocatePulse = true
                self?.heartbeatLocateButton(times: 4)
            }
            self?.view.layoutIfNeeded()
        }
    }

    // MARK: - Map / Search
    private func setupMap() {
        ymapView = YMKMapView(frame: .zero)
        ymapView.translatesAutoresizingMaskIntoConstraints = false
        ymapView.isOpaque = true
        ymapView.backgroundColor = .systemBackground

        let map = ymapView.mapWindow.map
        map.isRotateGesturesEnabled = true
        map.isScrollGesturesEnabled = true
        map.isZoomGesturesEnabled = true
        map.isTiltGesturesEnabled = true

        userLocationLayer = YMKMapKit.sharedInstance()
            .createUserLocationLayer(with: ymapView.mapWindow)
        userLocationLayer.setVisibleWithOn(true)
        userLocationLayer.isHeadingModeActive = true

        map.addCameraListener(with: self)

        searchManager = YMKSearchFactory.instance().createSearchManager(with: .combined)
    }

    // MARK: - Layout
    private func setupLayout() {
        // Карта
        view.addSubview(ymapView)
        NSLayoutConstraint.activate([
            ymapView.topAnchor.constraint(equalTo: view.topAnchor),
            ymapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ymapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ymapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Плавающая кнопка "геолокация" — всегда над шитом
        view.addSubview(locateButton)

        // Центр-пин
        view.addSubview(centerPin)
        NSLayoutConstraint.activate([
            centerPin.centerXAnchor.constraint(equalTo: ymapView.centerXAnchor),
            centerPin.centerYAnchor.constraint(equalTo: ymapView.centerYAnchor, constant: -12)
        ])

        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.backgroundColor = .systemBackground
        bottomPanel.layer.cornerRadius = 24
        bottomPanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomPanel.layer.masksToBounds = true
        view.addSubview(bottomPanel)

        bottomPanelTop = bottomPanel.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: view.bounds.height
        )

        bottomToKeyboard = bottomPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        NSLayoutConstraint.activate([
            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomPanelTop,
            bottomToKeyboard
        ])

        NSLayoutConstraint.activate([
            locateButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            locateButton.bottomAnchor.constraint(equalTo: bottomPanel.topAnchor, constant: -12)
        ])
        view.bringSubviewToFront(locateButton)

        // Контент шита
        bottomPanel.addSubview(grabber)
        bottomPanel.addSubview(addressField)
        bottomPanel.addSubview(suggestTable)
        bottomPanel.addSubview(suggestionsContainer)
        bottomPanel.addSubview(separator)
        bottomPanel.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            // Grabber
            grabber.topAnchor.constraint(equalTo: bottomPanel.topAnchor, constant: 8),
            grabber.centerXAnchor.constraint(equalTo: bottomPanel.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 36),
            grabber.heightAnchor.constraint(equalToConstant: 4),

            // Address field — СРАЗУ ПОД граббером
            addressField.topAnchor.constraint(equalTo: grabber.bottomAnchor, constant: 12),
            addressField.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 16),
            addressField.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            // Контейнер со списком: серый фон, скругления 16, отступы 16 слева/справа
            suggestionsContainer.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: 8),
            suggestionsContainer.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 16),
            suggestionsContainer.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -16),
            suggestionsContainer.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -8),

            // Кнопка подтверждения (как было)
            confirmButton.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 24),
            confirmButton.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -24),
            confirmButton.heightAnchor.constraint(equalToConstant: 56),

            // Разделитель над кнопкой (как было)
            separator.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -1),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        // Таблица ВНУТРИ контейнера
        suggestionsContainer.addSubview(suggestTable)
        NSLayoutConstraint.activate([
            suggestTable.topAnchor.constraint(equalTo: suggestionsContainer.topAnchor),
            suggestTable.leadingAnchor.constraint(equalTo: suggestionsContainer.leadingAnchor),
            suggestTable.trailingAnchor.constraint(equalTo: suggestionsContainer.trailingAnchor),
            suggestTable.bottomAnchor.constraint(equalTo: suggestionsContainer.bottomAnchor)
        ])
        
        confirmBottomToSafeArea = confirmButton.bottomAnchor.constraint(
            equalTo: bottomPanel.safeAreaLayoutGuide.bottomAnchor, constant: -12
        )

        // 2) когда есть клавиатура — прилипнуть к её верху
        if #available(iOS 15.0, *) {
            confirmBottomToKeyboard = confirmButton.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor, constant: -12
            )
            confirmBottomToKeyboard?.priority = .required           // клавиатура — главнее
            confirmBottomToSafeArea.priority = .defaultHigh         // запасной вариант
            NSLayoutConstraint.activate([confirmBottomToSafeArea, confirmBottomToKeyboard!])
        } else {
            NSLayoutConstraint.activate([confirmBottomToSafeArea])
        }

        view.layoutIfNeeded()
    }

    private func computeHeightsIfNeeded() {
        guard !didComputeHeights else { return }
        didComputeHeights = true

        let h = view.bounds.height
        // medium — «рабочая» высота шита
        mediumH = max(260, min(h * 0.42, 460))
        // expanded — почти на весь экран, но оставляем «воздух» сверху
        expandedH = max(h * 0.72, h - 140)

        applySheetState(.medium, animated: false)
    }

    // MARK: - Sheet gestures / state
    @objc private func handleSheetPan(_ gr: UIPanGestureRecognizer) {
        switch gr.state {
        case .began:
            panStartHeight = bottomPanelTop.constant

        case .changed:
            let dy = gr.translation(in: bottomPanel).y
            let available = view.bounds.height - view.safeAreaInsets.top

            // Тянем верх/вниз: работаем «по top», а высоту держим в [mediumH ... expandedH]
            var newTop = panStartHeight + dy
            newTop = max(available - expandedH, min(available - mediumH, newTop))

            bottomPanelTop.constant = newTop
            view.layoutIfNeeded()

        case .ended, .cancelled, .failed:
            let vy = gr.velocity(in: bottomPanel).y
            let available = view.bounds.height - view.safeAreaInsets.top
            let currentHeight = available - bottomPanelTop.constant

            let target: SheetState
            if vy < -700 {
                // быстрый свайп вверх
                target = .expanded
            } else if vy > 700 {
                // быстрый свайп вниз
                target = .medium
            } else {
                // к ближайшему
                let dM = abs(currentHeight - mediumH)
                let dE = abs(currentHeight - expandedH)
                target = (dM <= dE) ? .medium : .expanded
            }
            applySheetState(target, animated: true)

        default:
            break
        }
    }

    private func applySheetState(_ state: SheetState, animated: Bool) {
        sheetState = state
        let targetHeight: CGFloat = (state == .medium) ? mediumH : expandedH
        
        let available = view.bounds.height - view.safeAreaInsets.top
        bottomPanelTop.constant = max(0, available - targetHeight)

        let animations: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }

        if animated {
            UIViewPropertyAnimator(duration: 0.28, dampingRatio: 0.95, animations: animations).startAnimation()
        } else {
            animations()
        }
    }

    // MARK: - Search UI
    private func wireSearchUI() {
        suggestTable.translatesAutoresizingMaskIntoConstraints = false
        suggestTable.isHidden = true
        suggestTable.backgroundColor = .clear
        suggestTable.clipsToBounds = true
        suggestTable.dataSource = self
        suggestTable.delegate = self
        suggestTable.keyboardDismissMode = .onDrag
        suggestTable.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        suggestTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        suggestTable.rowHeight = UITableView.automaticDimension
        suggestTable.estimatedRowHeight = 40

        // Реакция на ввод текста — дебаунс
        addressField.onTextChange = { [weak self] text in
            self?.debouncedForwardSearch(query: text ?? "")
        }
    }

    // MARK: - Location
    private func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.requestLocation()
    }
    
    private func heartbeatLocateButton(times: Int = 2) {
        // масштаб
        let scale = CAKeyframeAnimation(keyPath: "transform.scale")
        scale.values = [1.0, 1.2, 0.95, 1.0]          // заметнее на маленькой иконке
        scale.keyTimes = [0, 0.35, 0.7, 1]
        scale.duration = 0.6
        scale.repeatCount = Float(times)
        scale.isRemovedOnCompletion = true
        scale.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]

        // лёгкая «дышащая» тень вместе с пульсом
        locateButton.layer.shadowColor = UIColor.black.cgColor
        locateButton.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.28 : 0.18
        locateButton.layer.shadowRadius = 8
        locateButton.layer.shadowOffset = .init(width: 0, height: 2)

        locateButton.layer.add(scale, forKey: "pulse")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        moveCamera(to: loc.coordinate, animated: false)
        reverseGeocodeYandex(YMKPoint(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))

        if !didKickoffLocation {
            didKickoffLocation = true
            centerOnUser()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }

    // MARK: - Camera listener (реверс-геокод по остановке камеры)
    func onCameraPositionChanged(with map: YMKMap,
                                 cameraPosition: YMKCameraPosition,
                                 cameraUpdateReason: YMKCameraUpdateReason,
                                 finished: Bool) {
        if finished {
            let p = cameraPosition.target
            reverseGeocodeYandex(YMKPoint(latitude: p.latitude, longitude: p.longitude))
        }
    }

    // MARK: - Debounce + forward search
    private func debouncedForwardSearch(query: String) {
        searchWorkItem?.cancel()
        guard query.trimmingCharacters(in: .whitespaces).count >= 3 else {
            forwardSearchSession?.cancel()
            searchResults.removeAll()
            suggestTable.isHidden = true
            confirmButton.isEnabled = false
            return
        }
        let work = DispatchWorkItem { [weak self] in self?.forwardSearchYandex(query) }
        searchWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
    }

    private func forwardSearchYandex(_ query: String) {
        forwardSearchSession?.cancel()

        let opts = YMKSearchOptions()
        let visible = ymapView.mapWindow.map.visibleRegion
        let geometry = YMKVisibleRegionUtils.toPolygon(with: visible)

        if searchManager == nil {
            searchManager = YMKSearchFactory.instance().createSearchManager(with: .combined)
        }

        forwardSearchSession = searchManager.submit(
            withText: query,
            geometry: geometry,
            searchOptions: opts,
            responseHandler: { [weak self] (response, error) in
                guard let self else { return }

                if let _ = error {
                    DispatchQueue.main.async {
                        self.searchResults.removeAll()
                        self.suggestTable.isHidden = true
                        self.suggestTable.reloadData()
                    }
                    return
                }

                let children = response?.collection.children ?? []
                let results: [SearchResult] = children.compactMap { item in
                    guard let obj = item.obj,
                          let point = obj.geometry.first?.point else { return nil }

                    var subtitle: String?
                    if let meta = obj.metadataContainer
                        .getItemOf(YMKSearchToponymObjectMetadata.self) as? YMKSearchToponymObjectMetadata {
                        subtitle = meta.address.formattedAddress
                    }

                    let title = obj.name ?? subtitle ?? "Адрес"
                    return SearchResult(title: title, subtitle: subtitle, point: point)
                }

                DispatchQueue.main.async {
                    self.searchResults = results
                    self.suggestTable.isHidden = results.isEmpty
                    self.suggestTable.reloadData()
                }
            }
        )
    }

    // MARK: - Actions
    @objc private func centerOnUser() {
        if let cam = userLocationLayer.cameraPosition() {
            let anim = YMKAnimation(type: .smooth, duration: 0.3)
            ymapView.mapWindow.map.move(with: cam, animation: anim, cameraCallback: nil)
            reverseGeocodeYandex(cam.target)
            return
        }

        if let loc = locationManager.location {
            let c = loc.coordinate
            moveCamera(to: c, animated: true)
            reverseGeocodeYandex(YMKPoint(latitude: c.latitude, longitude: c.longitude))
        } else {
            locationManager.requestLocation()
        }
    }

    @objc private func confirm() {
        let line = addressField.text ?? ""
        let point = selectedPoint ?? ymapView.mapWindow.map.cameraPosition.target
        let lat = point.latitude
        let lng = point.longitude

        let vc = AddressDetailsViewController(addressLine: line)
        vc.onSubmit = { details in
            // POST /orders { address_text: line, lat, lng, + детали подъезда }
        }
        navigationItem.backButtonDisplayMode = .minimal
        navigationItem.backButtonTitle = ""
        (navigationController ?? parent?.navigationController)?.pushViewController(vc, animated: true)
    }

    // MARK: - Helpers
    private var selectedPoint: YMKPoint?

    private func moveCamera(to coord: CLLocationCoordinate2D, animated: Bool) {
        let target = YMKPoint(latitude: coord.latitude, longitude: coord.longitude)
        let pos = YMKCameraPosition(target: target, zoom: 15, azimuth: 0, tilt: 0)
        let anim = YMKAnimation(type: .smooth, duration: animated ? 0.3 : 0.0)
        ymapView.mapWindow.map.move(with: pos, animation: anim, cameraCallback: nil)
    }

    private func reverseGeocodeYandex(_ point: YMKPoint) {
        selectedPoint = point
        searchSession?.cancel()

        let opts = YMKSearchOptions()
        opts.searchTypes = .geo

        if searchManager == nil {
            searchManager = YMKSearchFactory.instance().createSearchManager(with: .combined)
        }

        searchSession = searchManager.submit(with: point, zoom: 16, searchOptions: opts) { [weak self] (response, error) in
            guard let self = self else { return }
            if let error = error {
                print("reverseGeocode error:", error.localizedDescription)
                self.addressField.setText("Адрес не определён")
                self.confirmButton.isEnabled = false
                return
            }

            guard let obj = response?.collection.children.first?.obj else {
                self.addressField.setText("Адрес не определён")
                self.confirmButton.isEnabled = false
                return
            }

            if let meta = obj.metadataContainer
                .getItemOf(YMKSearchToponymObjectMetadata.self) as? YMKSearchToponymObjectMetadata {

                let formatted = meta.address.formattedAddress
                self.addressField.setText(formatted)
                self.confirmButton.isEnabled = !formatted.isEmpty
            } else {
                self.addressField.setText("Адрес не определён")
                self.confirmButton.isEnabled = false
            }
        }
    }
}

// MARK: - UITableViewDataSource / Delegate
extension AddressPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { searchResults.count }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tv.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let r = searchResults[indexPath.row]

        var cfg = c.defaultContentConfiguration()

        // ИКОНКА СЛЕВА
        cfg.image = UIImage(named: "address")?.withRenderingMode(.alwaysTemplate)
        cfg.imageProperties.maximumSize = CGSize(width: 18, height: 18)
        cfg.imageProperties.reservedLayoutSize = CGSize(width: 18, height: 18) // фикс ширины под иконку
        cfg.imageToTextPadding = 8
        cfg.imageProperties.tintColor = .secondaryLabel
        c.tintColor = .secondaryLabel

        // ТЕКСТЫ
        cfg.text = r.subtitle ?? r.title
        cfg.secondaryText = (r.subtitle == nil) ? nil : r.title

        // МЕНЬШИЕ ШРИФТЫ
        cfg.textProperties.font = .systemFont(ofSize: 14, weight: .regular)
        cfg.secondaryTextProperties.font = .systemFont(ofSize: 12, weight: .regular)

        // Компактные отступы
        cfg.textProperties.numberOfLines = 2
        cfg.secondaryTextProperties.numberOfLines = 1
        cfg.directionalLayoutMargins = .init(top: 6, leading: 10, bottom: 6, trailing: 10)

        c.contentConfiguration = cfg
        if #available(iOS 14.0, *) {
            c.backgroundConfiguration = .clear()
        } else {
            c.backgroundColor = .clear
        }
        c.contentView.backgroundColor = .clear
        return c
    }


    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        let r = searchResults[indexPath.row]
        selectedPoint = r.point
        let pos = YMKCameraPosition(target: r.point, zoom: 17, azimuth: 0, tilt: 0)
        let anim = YMKAnimation(type: .smooth, duration: 0.25)
        ymapView.mapWindow.map.move(with: pos, animation: anim, cameraCallback: nil)

        addressField.setText(r.subtitle ?? r.title)
        confirmButton.isEnabled = true

        searchResults.removeAll()
        suggestTable.isHidden = true
    }
}

