//
//  InterstitialViewController.swift
//  BidMachineSample
//
//  Created by Dzmitry on 19/09/2024.
//

import UIKit

final class NativeViewController: AdLoadController {
    private let nativeViewContainer = UIView()

    override var topTitle: String? {
        "Native"
    }

    override func setupSubviews() {
        super.setupSubviews()
    }

    override func layoutContent() {
        super.layoutContent()
        
        nativeViewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nativeViewContainer)
        
        NSLayoutConstraint.activate([
            nativeViewContainer.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor),
            nativeViewContainer.widthAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.widthAnchor),
            nativeViewContainer.heightAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.heightAnchor),
            nativeViewContainer.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor)
        ])
    }
    
    override func loadAd() {
        switchState(to: .loading)
    }
    
    override func showAd() {
    }
}
