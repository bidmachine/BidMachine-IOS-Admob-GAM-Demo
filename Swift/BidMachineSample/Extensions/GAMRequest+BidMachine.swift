//
//  GAMRequest+BidMachine.swift
//  BidMachineSample
//
//  Created by Dzmitry on 19/09/2024.
//

import Foundation
import GoogleMobileAds
import BidMachine

extension GAMRequest {
    static func withBidMachineAdTargeting(_ ad: BidMachineAdProtocol) -> GAMRequest {
        var targeting = [String: String]()
        let price = NumberFormatter.bidMachinePrice.string(
            from: NSNumber(value: ad.auctionInfo.price)
        )
        targeting["bm_pf"] = "1.00" // price
        
        let request = GAMRequest()
        request.customTargeting = targeting
        
        return request
    }
}
