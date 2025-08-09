////
////  AddressPickerViewController.swift
////  MusorOk
////
////  Created by Elza Sadabaeva on 10.08.2025.
////
//
//import YandexMapsMobile
//import CoreLocation
//
//final class AddressPickerViewController: UIViewController, CLLocationManagerDelegate, YMKMapCameraListener {
//    
//    private let mapView = YMKMapView(frame: .zero)
//    
//    private var userLocationLayer: YMKUserLocationLayer!
//    private let locationManager = CLLocationManager()
//    
//    // 🔎 Yandex SearchKit
//    private var searchManager: YMKSearchManager!
//    private var searchSession: YMKSearchSession?
//    
//    // MARK: - UI
//    private let backButton: UIButton = {
//        let b = UIButton(type: .system)
//        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//        b.tintColor = .label
//        b.backgroundColor = .systemBackground
//        b.layer.cornerRadius = 12
//        b.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
//        b.translatesAutoresizingMaskIntoConstraints = false
//        return b
//    }()
//
//    private let locateButton: UIButton = {
//        let b = UIButton(type: .system)
//        b.setImage(UIImage(systemName: "location.fill"), for: .normal)
//        b.tintColor = .white
//        b.backgroundColor = .brandGreen
//        b.layer.cornerRadius = 24
//        b.translatesAutoresizingMaskIntoConstraints = false
//        b.widthAnchor.constraint(equalToConstant: 48).isActive = true
//        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
//        return b
//    }()
//
//    private let bottomPanel = UIView()
//    private let titleLabel: UILabel = {
//        let l = UILabel()
//        l.text = "Адрес, откуда заберем мусор"
//        l.font = .systemFont(ofSize: 18, weight: .semibold)
//        l.translatesAutoresizingMaskIntoConstraints = false
//        return l
//    }()
//
//    // Reuse твой FormInputView (НЕ телефон)
//    private let addressField = FormInputView(title: " ", placeholder: "", keyboard: .default, isSecure: false)
//
//    private let confirmButton: PrimaryButton = {
//        let b = PrimaryButton()
//        b.setTitle("Подтвердить адрес", for: .normal)
//        b.isEnabled = false
//        b.translatesAutoresizingMaskIntoConstraints = false
//        return b
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//
//        setupMap()
//        setupLayout()
//        setupLocation()
//
//        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
//        locateButton.addTarget(self, action: #selector(centerOnUser), for: .touchUpInside)
//        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
//    }
//
//    private func setupLayout() {
//        // карта на весь экран
//        NSLayoutConstraint.activate([
//            mapView.topAnchor.constraint(equalTo: view.topAnchor),
//            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//
//        // back
//        view.addSubview(backButton)
//        NSLayoutConstraint.activate([
//            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
//            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12)
//        ])
//
//        // locate (FAB)
//        view.addSubview(locateButton)
//        NSLayoutConstraint.activate([
//            locateButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
//            locateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120)
//        ])
//
//        // bottom sheet
//        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
//        bottomPanel.backgroundColor = .systemBackground
//        bottomPanel.layer.cornerRadius = 24
//        bottomPanel.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        view.addSubview(bottomPanel)
//
//        bottomPanel.addSubview(titleLabel)
//        bottomPanel.addSubview(addressField)
//        bottomPanel.addSubview(confirmButton)
//
//        NSLayoutConstraint.activate([
//            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            bottomPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            bottomPanel.heightAnchor.constraint(equalToConstant: 220),
//
//            titleLabel.topAnchor.constraint(equalTo: bottomPanel.topAnchor, constant: 18),
//            titleLabel.leadingAnchor.constraint(equalTo: bottomPanel.leadingAnchor, constant: 24),
//            titleLabel.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -24),
//
//            addressField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
//            addressField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            addressField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//
//            confirmButton.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: 16),
//            confirmButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            confirmButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//            confirmButton.heightAnchor.constraint(equalToConstant: 56)
//        ])
//    }
//
//    @objc private func didTapBack() { dismiss(animated: true) }
//
//    @objc private func confirm() {
//        let p = mapView.mapWindow.map.cameraPosition.target
//        print("CONFIRM: \(addressField.text ?? "") @ \(p.latitude), \(p.longitude)")
//        // сюда же делегат/closure, если нужно вернуть адрес
//    }
//
//    private func moveCamera(to coord: CLLocationCoordinate2D, animated: Bool) {
//        let target = YMKPoint(latitude: coord.latitude, longitude: coord.longitude)
//        let pos = YMKCameraPosition(target: target, zoom: 15, azimuth: 0, tilt: 0)
//        let anim = YMKAnimation(type: .smooth, duration: animated ? 0.3 : 0.0)
//        mapView.mapWindow.map.move(with: pos, animationType: anim, cameraCallback: nil)
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Location error:", error.localizedDescription)
//    }
//    
//    private func setupMap() {
//        mapView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(mapView)
//
//        // Все жесты активны, в т.ч. пинч-зум двумя пальцами
//        let map = mapView.mapWindow.map
//        map.isRotateGesturesEnabled = true
//        map.isScrollGesturesEnabled = true
//        map.isZoomGesturesEnabled = true
//        map.isTiltGesturesEnabled = true
//
//        // Слой геопозиции
//        userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)
//        userLocationLayer.isVisible = true
//        userLocationLayer.isHeadingEnabled = true
//
//        // Слушатель камеры
//        map.addCameraListener(with: self)
//
//        // 🔎 менеджер поиска Яндекса
//        searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
//    }
//    
//    func onCameraPositionChanged(with map: YMKMap,
//                                 cameraPosition: YMKCameraPosition,
//                                 cameraUpdateSource: YMKCameraUpdateSource,
//                                 finished: Bool) {
//        if finished {
//            let p = cameraPosition.target
//            reverseGeocodeYandex(YMKPoint(latitude: p.latitude, longitude: p.longitude))
//        }
//    }
//    
//    @objc private func centerOnUser() {
//        if let loc = locationManager.location {
//            let c = loc.coordinate
//            moveCamera(to: c, animated: true)
//            reverseGeocodeYandex(YMKPoint(latitude: c.latitude, longitude: c.longitude))
//        } else {
//            locationManager.requestLocation()
//        }
//    }
//    
//    private func reverseGeocodeYandex(_ point: YMKPoint) {
//        // отменим предыдущий запрос, чтобы не плодить ответы
//        searchSession?.cancel()
//
//        let opts = YMKSearchOptions()
//        // хотим именно адресные объекты
//        opts.searchTypes = YMKSearchType.geo.value
//
//        // ⚠️ сигнатура submit по точке:
//        searchSession = searchManager.submit(with: point,
//                                             zoom: 16,
//                                             searchOptions: opts) { [weak self] (response, error) in
//            guard let self = self else { return }
//            if let error = error {
//                print("reverseGeocode error: \(error.localizedDescription)")
//                self.addressField.setText("Адрес не определён")
//                self.confirmButton.isEnabled = false
//                return
//            }
//
//            // берём самый релевантный объект
//            guard let obj = response?.collection.children.first?.obj else {
//                self.addressField.setText("Адрес не определён")
//                self.confirmButton.isEnabled = false
//                return
//            }
//
//            // Достаём форматированный адрес из метаданных топонима
//            var addressText = obj.name // запасной вариант
//            if let meta = obj.metadataContainer.getItemOf(YMKToponymObjectMetadata.self) as? YMKToponymObjectMetadata {
//                // formattedAddress обычно самый «человеческий»
//                addressText = meta.address.formattedAddress
//            }
//
//            self.addressField.setText(addressText ?? "Адрес не определён")
//            self.confirmButton.isEnabled = !(addressText ?? "").isEmpty
//        }
//    }
//
//    private func setupLocation() {
//        locationManager.delegate = self
//        if CLLocationManager.authorizationStatus() == .notDetermined {
//            locationManager.requestWhenInUseAuthorization()
//        }
//        locationManager.requestLocation() // единоразово
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let loc = locations.last else { return }
//        moveCamera(to: loc.coordinate, animated: false)
//        reverseGeocodeYandex(YMKPoint(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
//    }
//}
