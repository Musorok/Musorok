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
//        YMKMapKit.setApiKey("049a4f37-0c85-47ef-8582-53afce109e31")
//        let mapkit = YMKMapKit.sharedInstance()
//        mapkit.onStart()
        YMKMapKit.setApiKey("<049a4f37-0c85-47ef-8582-53afce109e31>")
        YMKMapKit.setLocale("ru_RU") // необязательно
        let mapkit = YMKMapKit.sharedInstance()
        mapkit.onStart()
        print("Bundle ID:", Bundle.main.bundleIdentifier ?? "nil")
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

