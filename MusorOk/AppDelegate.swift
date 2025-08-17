//
//  AppDelegate.swift
//  MusorOk
//
//  Created by Elza Sadabaeva on 09.08.2025.
//

import UIKit
import YandexMapsMobile

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        YMKMapKit.setApiKey("049a4f37-0c85-47ef-8582-53afce109e31")
        YMKMapKit.setLocale("ru_RU")
        let mapkit = YMKMapKit.sharedInstance()
        mapkit.onStart()
        print("Bundle ID:", Bundle.main.bundleIdentifier ?? "nil")
        
        let app = UINavigationBarAppearance()
        app.configureWithTransparentBackground()
        app.backgroundEffect = nil
        app.backgroundColor = .clear
        app.shadowColor = .clear

        // скрываем текст "Back"
        let backTitle = UIBarButtonItemAppearance()
        let clearAttrs: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.clear]
        backTitle.normal.titleTextAttributes = clearAttrs
        backTitle.highlighted.titleTextAttributes = clearAttrs
        backTitle.disabled.titleTextAttributes = clearAttrs
        backTitle.focused.titleTextAttributes = clearAttrs
        app.backButtonAppearance = backTitle

        UINavigationBar.appearance().tintColor = .label
        UINavigationBar.appearance().standardAppearance = app
        UINavigationBar.appearance().scrollEdgeAppearance = app
        UINavigationBar.appearance().compactAppearance = app
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        YMKMapKit.sharedInstance().onStop()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


import UIKit

final class NavBackCoordinator: NSObject, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    private let imageName: String
    private let leftShift: CGFloat

    init(imageName: String = "nav_back", leftShift: CGFloat = -8) {
        self.imageName = imageName
        self.leftShift = leftShift
        super.init()
    }

    func attach(to nav: UINavigationController) {
        nav.delegate = self
        nav.interactivePopGestureRecognizer?.delegate = self
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        // Корневой контроллер без back
        guard navigationController.viewControllers.count > 1 else {
            viewController.navigationItem.hidesBackButton = true
            viewController.navigationItem.leftBarButtonItem = nil
            return
        }

        // Скрываем системный back (текст мы уже скрыли через Appearance)
        viewController.navigationItem.hidesBackButton = true

        // Кнопка с картинкой из ассетов в ОРИГИНАЛЬНОМ цвете
        let btn = UIButton(type: .system)
        if let img = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal) {
            // Если у ассета есть "воздух", компенсируем его:
            let adjusted = img.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: leftShift, bottom: 0, right: 0))
            btn.setImage(adjusted, for: .normal)
        }

        // Размер и зона нажатия
        btn.widthAnchor.constraint(equalToConstant: 28).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 28).isActive = true

        // Сдвиг ближе к левому краю; подстрой при необходимости (-6…-12)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 0)

        btn.addTarget(self, action: #selector(pop(_:)), for: .touchUpInside)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btn)
    }

    @objc private func pop(_ sender: Any?) {
        // Находим активный nav и делаем pop
        if let nav = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first(where: { $0.isKeyWindow })?.rootViewController as? UINavigationController {
            nav.popViewController(animated: true)
        } else {
            // Поддержка, если у тебя root = UITabBarController
            if let tab = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                .windows.first(where: { $0.isKeyWindow })?.rootViewController as? UITabBarController,
               let nav = tab.selectedViewController as? UINavigationController {
                nav.popViewController(animated: true)
            }
        }
    }

    // Жест "свайп-назад" должен работать
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}


