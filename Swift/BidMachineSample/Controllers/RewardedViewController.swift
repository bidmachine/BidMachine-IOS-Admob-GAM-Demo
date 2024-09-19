//
//  RewardedViewController.swift
//  BidMachineSample
//
//  Created by Dzmitry on 19/09/2024.
//

import UIKit

final class RewardedViewController: AdLoadController {
    override var topTitle: String? {
        "Rewarded"
    }

    override func setupSubviews() {
        super.setupSubviews()
    }

    override func layoutContent() {
        super.layoutContent()
    }
    
    override func loadAd() {
        switchState(to: .loading)
    }
    
    override func showAd() {
        
    }
}
