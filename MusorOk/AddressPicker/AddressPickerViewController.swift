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

    // Карта как IUO, чтобы обращаться без "?"
    private var ymapView: YMKMapView!
    private var didKickoffLocation = false

    private var userLocationLayer: YMKUserLocationLayer!
    private let locationManager = CLLocationManager()

    // Yandex SearchKit
    private var searchManager: YMKSearchManager!
    private var searchSession: YMKSearchSession?

    // MARK: - UI
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .label
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 12
        b.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let locateButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "location.fill"), for: .normal)
        b.tintColor = .white
        b.backgroundColor = .brandGreen
        b.layer.cornerRadius = 24
        b.translatesAutoresizingMaskIntoConstraints = false
        b.widthAnchor.constraint(equalToConstant: 48).isActive = true
        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return b
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
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Адрес, откуда заберем мусор"
        l.font = .systemFont(ofSize: 18, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // Переиспользуем твой текстовый инпут (НЕ телефон)
    private let addressField = FormInputView(title: " ", placeholder: "", keyboard: .default, isSecure: false)

    private let confirmButton: PrimaryButton = {
        let b = PrimaryButton()
        b.setTitle("Подтвердить адрес", for: .normal)
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.tintColor = .label

        setupMap()       // создать карту и слои
        setupLayout()    // констрейнты и панель
        setupLocation()  // запрос прав и первая локация

        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        locateButton.addTarget(self, action: #selector(centerOnUser), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
    }

    // MARK: - Map / Search
    private func setupMap() {
        // 1) Карта
        ymapView = YMKMapView(frame: .zero)
        ymapView.translatesAutoresizingMaskIntoConstraints = false
        ymapView.isOpaque = true
        ymapView.backgroundColor = .systemBackground

        // 2) Жесты
        let map = ymapView.mapWindow.map
        map.isRotateGesturesEnabled = true
        map.isScrollGesturesEnabled = true
        map.isZoomGesturesEnabled = true   // пинч-зум
        map.isTiltGesturesEnabled = true

        // 3) Слой юзер-локации
        userLocationLayer = YMKMapKit.sharedInstance()
            .createUserLocationLayer(with: ymapView.mapWindow)
        userLocationLayer.setVisibleWithOn(true)       // в твоей версии SDK это метод
        userLocationLayer.isHeadingModeActive = true   // ObjC getter=isHeadingModeActive → Swift свойство

        // 4) Подписка на камеру
        map.addCameraListener(with: self)

        // 5) SearchKit: менеджер поиска
        // В актуальной MapKit используется фабрика Search:
        // Если у тебя другой минор — можно заменить на YMKSearch.sharedInstance().createSearchManager(...)
        searchManager = YMKSearchFactory.instance().createSearchManager(with: YMKSearchManagerType.combined)
    }

    // MARK: - Layout
    private func setupLayout() {
        // карта
        view.addSubview(ymapView)
        NSLayoutConstraint.activate([
            ymapView.topAnchor.constraint(equalTo: view.topAnchor),
            ymapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ymapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ymapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // ❗️СНАЧАЛА добавляем bottomPanel
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.backgroundColor = .systemBackground
        bottomPanel.layer.cornerRadius = 24
        bottomPanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(bottomPanel)
        NSLayoutConstraint.activate([
            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor), // ← БЕЗ сдвига
            bottomPanel.heightAnchor.constraint(equalToConstant: 240)        // ← было 220, +5 pt
        ])

        view.addSubview(locateButton)
        NSLayoutConstraint.activate([
            locateButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            // ✅ теперь можно привязать к панели
            locateButton.bottomAnchor.constraint(equalTo: bottomPanel.topAnchor, constant: -12)
        ])
        view.bringSubviewToFront(locateButton) // чтобы кнопка была поверх панели

        // пин в центре
        view.addSubview(centerPin)
        NSLayoutConstraint.activate([
            centerPin.centerXAnchor.constraint(equalTo: ymapView.centerXAnchor),
            centerPin.centerYAnchor.constraint(equalTo: ymapView.centerYAnchor, constant: -12)
        ])

        // контент панели
        bottomPanel.addSubview(titleLabel)
        bottomPanel.addSubview(addressField)
        bottomPanel.addSubview(confirmButton)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: bottomPanel.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -24),

            addressField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            addressField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            addressField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            confirmButton.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: 16),
            confirmButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        view.layoutIfNeeded()
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
            print("Camera finished at:", p.latitude, p.longitude)
            reverseGeocodeYandex(YMKPoint(latitude: p.latitude, longitude: p.longitude))
        }
    }

    // MARK: - Actions
    @objc private func didTapBack() { dismiss(animated: true) }

    @objc private func centerOnUser() {
        // 1) Попытка от Яндекс-слоя
        if let cam = userLocationLayer.cameraPosition() {
            let anim = YMKAnimation(type: .smooth, duration: 0.3)
            ymapView.mapWindow.map.move(with: cam, animation: anim, cameraCallback: nil)
            reverseGeocodeYandex(cam.target)
            return
        }

        // 2) Fallback: CoreLocation
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
        let vc = AddressDetailsViewController(addressLine: line)
        vc.onSubmit = { details in
            // здесь потом вызовешь создание заказа
            // print("ORDER:", details)
        }
        let nav = navigationController ?? (parent?.navigationController)
        nav?.pushViewController(vc, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse, !didKickoffLocation {
            didKickoffLocation = true
            centerOnUser()
        }
    }

    // MARK: - Helpers
    private func moveCamera(to coord: CLLocationCoordinate2D, animated: Bool) {
        let target = YMKPoint(latitude: coord.latitude, longitude: coord.longitude)
        let pos = YMKCameraPosition(target: target, zoom: 15, azimuth: 0, tilt: 0)
        let anim = YMKAnimation(type: .smooth, duration: animated ? 0.3 : 0.0)

        // В разных минорных версиях параметр называется по-разному:
        if ymapView.mapWindow.map.responds(to: #selector(YMKMap.move(with:animation:cameraCallback:))) {
            ymapView.mapWindow.map.move(with: pos, animation: anim, cameraCallback: nil)
        } else {
            ymapView.mapWindow.map.move(with: pos, animation: anim, cameraCallback: nil)
        }
    }

    // MARK: - Reverse geocode (Yandex SearchKit)
    private func reverseGeocodeYandex(_ point: YMKPoint) {
        searchSession?.cancel()

        let opts = YMKSearchOptions()
            opts.searchTypes = .geo

        // Менеджер поиска создаём через фабрику (как в MapKit 4.x)
        if searchManager == nil {
            searchManager = YMKSearchFactory.instance().createSearchManager(with: YMKSearchManagerType.combined)
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

            var addressText = obj.name
            if let meta = obj.metadataContainer
                .getItemOf(YMKSearchToponymObjectMetadata.self) as? YMKSearchToponymObjectMetadata {

                let address = meta.address
                let formatted = address.formattedAddress
                self.addressField.setText(formatted)
                self.confirmButton.isEnabled = !formatted.isEmpty
            } else {
                self.addressField.setText("Адрес не определён")
                self.confirmButton.isEnabled = false
            }
        }
    }
}
