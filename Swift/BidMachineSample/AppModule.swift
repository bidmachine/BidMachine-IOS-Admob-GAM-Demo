//
//  Copyright © 2024 Appodeal. All rights reserved.
//

import UIKit

enum AppModule {
    static func create(for adTypes: [AdType]) -> UIViewController {
        let tabController = UITabBarController()
        
        tabController.viewControllers = adTypes.map {
            let instance = $0.associatedControllerType.init(nibName: nil, bundle: Bundle.main)
            instance.tabBarItem = $0.barItem
            return instance
        }
        
        return tabController
    }
}
