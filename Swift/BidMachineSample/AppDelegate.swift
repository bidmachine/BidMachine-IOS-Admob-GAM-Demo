//
//  AppDelegate.swift
//  BidMachineSample
//
//  Created by Dzmitry on 19/09/2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        guard let scene = application.connectedScenes.first as? UIWindowScene else {
            return false
        }

        window = UIWindow(windowScene: scene)
        window?.rootViewController = AppModule.create(for: AdType.allCases)
        window?.makeKeyAndVisible()
        
        return true
    }
}

