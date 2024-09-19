//
//  Copyright © 2024 Appodeal. All rights reserved.
//

import UIKit

enum AdType: CaseIterable {
    case interstitial
    case rewarded
    case banner
    case native
}

extension AdType {
    var associatedControllerType: UIViewController.Type {
        switch self {
        case .interstitial:
            InterstitialViewController.self
        case .rewarded:
            RewardedViewController.self
        case .banner:
            BannerViewController.self
        case .native:
            NativeViewController.self
        }
    }
    
    var barItem: UITabBarItem {
        let name = switch self {
        case .interstitial:
            "Interstitial"
        case .rewarded:
            "Rewarded"
        case .banner:
            "Banner"
        case .native:
            "Native"
        }
        return UITabBarItem(title: name, image: nil, selectedImage: nil)
    }
}
