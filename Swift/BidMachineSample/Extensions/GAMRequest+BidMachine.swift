//
//  Copyright © 2024 Appodeal. All rights reserved.
//

import Foundation
import GoogleMobileAds
import BidMachine

extension GAMRequest {
    static func withBidMachineAdTargeting(_ ad: BidMachineAdProtocol) -> GAMRequest {
        let request = GAMRequest()
        let price = NumberFormatter.bidMachinePrice.string(
            from: NSNumber(value: ad.auctionInfo.price)
        )!
        request.customTargeting = ["bm_pf": price]
        
        return request
    }
}
