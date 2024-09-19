//
//  Copyright © 2024 Appodeal. All rights reserved.
//

import UIKit
import BidMachine
import GoogleMobileAds

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
        
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [""]
        setupBidMachine()

        window = UIWindow(windowScene: scene)
        window?.rootViewController = AppModule.create(for: AdType.allCases)
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func setupBidMachine() {
        BidMachineSdk.shared.populate { builder in
            builder.withTestMode(true)
            builder.withLoggingMode(true)
        }
        BidMachineSdk.shared.targetingInfo.populate { builder in
            builder.withStoreId("12345")
        }
        BidMachineSdk.shared.initializeSdk("154")
    }
}

