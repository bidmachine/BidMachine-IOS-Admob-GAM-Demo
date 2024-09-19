//
//  BanneViewController.swift
//  BidMachineSample
//
//  Created by Dzmitry on 19/09/2024.
//

import UIKit

final class BannerViewController: AdLoadController {
    override var topTitle: String? {
        "Banner"
    }

    private let bannerContainer = UIView()

    override func setupSubviews() {
        super.setupSubviews()
    }

    override func layoutContent() {
        super.layoutContent()
        
        bannerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerContainer)
        
        NSLayoutConstraint.activate([
            bannerContainer.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor),
            bannerContainer.widthAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.widthAnchor),
            bannerContainer.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            bannerContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }
    
    override func loadAd() {
        switchState(to: .loading)
    }
    
    override func showAd() {
        
    }
}
