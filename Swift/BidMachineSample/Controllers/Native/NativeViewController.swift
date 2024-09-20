//
//  Copyright © 2024 Appodeal. All rights reserved.
//

import UIKit
import BidMachine
import GoogleMobileAds

private enum Constant {
    static let advertiser = "bidmachine"
    static let nativeUnitID = "your unit id here"
}

final class NativeViewController: AdLoadController {
    private let nativeViewContainer = UIView()
    
    private var bidMachineNativeAd: BidMachineNative?
    private var googleNativeAd: GADNativeAd?
    private var googleLoader: GADAdLoader?

    override var topTitle: String? {
        "Native"
    }

    override func layoutContent() {
        super.layoutContent()
        
        nativeViewContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nativeViewContainer)
        
        NSLayoutConstraint.activate([
            nativeViewContainer.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor, constant: 5.0),
            nativeViewContainer.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor, constant: -5.0),
            nativeViewContainer.heightAnchor.constraint(equalToConstant: 400),
            nativeViewContainer.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor)
        ])
    }
    
    override func loadAd() {
        deleteLoadedAd()
        switchState(to: .loading)
        
        BidMachineSdk.shared.native { [weak self] nativeAd, error in
            if let error {
                self?.switchState(to: .idle)
                self?.showAlert(with: "Error occurred: \(error.localizedDescription)")
            } else {
                self?.bidMachineNativeAd = nativeAd
                self?.bidMachineNativeAd?.controller = self
                self?.bidMachineNativeAd?.delegate = self
                self?.bidMachineNativeAd?.loadAd()
            }
        }
    }
    
    override func showAd() {
        switchState(to: .idle)

        guard let bidMachineNativeAd, bidMachineNativeAd.canShow else {
            showAlert(with: "No native ad to show, show google ad if possible")
            return
        }
        let adView = NativeAdView()
        
        bidMachineNativeAd.controller = self
        do {
            try bidMachineNativeAd.presentAd(nativeViewContainer, adView)
            adView.translatesAutoresizingMaskIntoConstraints = false
            nativeViewContainer.addSubview(adView)
            
            NSLayoutConstraint.activate([
                adView.topAnchor.constraint(equalTo: nativeViewContainer.topAnchor),
                adView.bottomAnchor.constraint(equalTo: nativeViewContainer.bottomAnchor),
                adView.leadingAnchor.constraint(equalTo: nativeViewContainer.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: nativeViewContainer.trailingAnchor)
            ])
        } catch let error {
            switchState(to: .idle)
            showAlert(with: "Error occurred: \(error.localizedDescription)")
        }
    }
    
    private func deleteLoadedAd() {
        bidMachineNativeAd?.unregisterView()

        bidMachineNativeAd = nil
        googleNativeAd = nil
        googleLoader = nil
        nativeViewContainer.subviews.forEach { $0.removeFromSuperview() }
    }
}

extension NativeViewController: BidMachineAdDelegate {
    func didLoadAd(_ ad: any BidMachine.BidMachineAdProtocol) {
        let request = GAMRequest.withBidMachineAdTargeting(ad)
        
        googleLoader = GADAdLoader(
            adUnitID: Constant.nativeUnitID,
            rootViewController: self,
            adTypes: [.native],
            options: nil
        )
        googleLoader?.delegate = self
        googleLoader?.load(request)
    }
    
    func didFailLoadAd(_ ad: any BidMachine.BidMachineAdProtocol, _ error: any Error) {
        switchState(to: .idle)
        showAlert(with: "Error occurred: \(error.localizedDescription)")
    }
}

extension NativeViewController: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        let bidMachineWon = nativeAd.advertiser == Constant.advertiser
        
        if bidMachineWon {
            BidMachineSdk.shared.notifyMediationWin(bidMachineNativeAd!)
            switchState(to: .loaded)
        } else {
            BidMachineSdk.shared.notifyMediationLoss("", 0.0, bidMachineNativeAd!)
            bidMachineNativeAd = nil

            // fallback to google native ad
            switchState(to: .idle)
            showAlert(with: "Google ad loaded. Advertiser: \(nativeAd.advertiser ?? "none")")
        }
    }

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        switchState(to: .idle)
        showAlert(with: "Error occurred: \(error.localizedDescription)")
    }
}
