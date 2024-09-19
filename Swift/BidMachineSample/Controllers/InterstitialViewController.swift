//
//  InterstitialViewController.swift
//  BidMachineSample
//
//  Created by Dzmitry on 19/09/2024.
//

import UIKit

final class InterstitialViewController: AdLoadController {
    override var topTitle: String? {
        "Interstitial"
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
