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
            guard let self else {
                return
            }
            if let error {
                self.switchState(to: .idle)
                self.showAlert(with: "Error occurred: \(error.localizedDescription)")
            } else {
                self.bidMachineNativeAd = nativeAd
                self.bidMachineNativeAd?.controller = self
                self.bidMachineNativeAd?.delegate = self
                self.bidMachineNativeAd?.loadAd()
            }
        }
    }
    
    override func showAd() {
        switchState(to: .idle)

        guard let bidMachineNativeAd, bidMachineNativeAd.canShow else {
            showAlert(with: "No native ad to show, show google ad if possible")
            // No BidMachine native to show. Fallback to Google native ad or implement your own fallback logic.

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
            // Unable to display the BidMachine ad. Implement your fallback logic here.

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
        
        let loader = GADAdLoader(
            adUnitID: Constant.nativeUnitID,
            rootViewController: self,
            adTypes: [.native],
            options: nil
        )
        self.googleLoader = loader

        loader.delegate = self
        loader.load(request)
    }
    
    func didFailLoadAd(_ ad: any BidMachine.BidMachineAdProtocol, _ error: any Error) {
        switchState(to: .idle)
        bidMachineNativeAd = nil
        
        // Unable to load BidMachine ad, fallback to Google Ad manager request or handle error accordingly
        showAlert(with: "Error occurred: \(error.localizedDescription)")
    }
    
    func didDismissAd(_ ad: any BidMachineAdProtocol) {

    }

    func willPresentScreen(_ ad: any BidMachineAdProtocol) {
    
    }

    func didDismissScreen(_ ad: any BidMachineAdProtocol) {
        
    }
    
    func didExpired(_ ad: any BidMachineAdProtocol) {
        deleteLoadedAd()
        switchState(to: .idle)
        
        // BidMachine ad has expired. Restart the ad loading process.
    }
    
    func didFailPresentAd(_ ad: any BidMachineAdProtocol, _ error: any Error) {
        
    }
    
    func didPresentAd(_ ad: any BidMachineAdProtocol) {
        
    }
    
    func didTrackImpression(_ ad: any BidMachineAdProtocol) {
        
    }
    
    func didTrackInteraction(_ ad: any BidMachineAdProtocol) {
        
    }
    
    func didUserInteraction(_ ad: any BidMachineAdProtocol) {
        
    }
}

extension NativeViewController: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        let bidMachineWon = nativeAd.advertiser == Constant.advertiser
        
        if bidMachineWon {
            bidMachineNativeAd.map { BidMachineSdk.shared.notifyMediationWin($0) }
            switchState(to: .loaded)

        } else {
            bidMachineNativeAd.map { BidMachineSdk.shared.notifyMediationLoss("", 0.0, $0) }
            bidMachineNativeAd = nil

            // BidMachine lost. Fallback to Google native ad or implement your own fallback logic.
            googleNativeAd = nativeAd
            switchState(to: .idle)
            showAlert(with: "Google ad loaded. Advertiser: \(nativeAd.advertiser ?? "unknown")")
        }
    }

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        switchState(to: .idle)
        
        // Unable to load Google ad, implement fallback logic.
        showAlert(with: "Error occurred: \(error.localizedDescription)")
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {

    }
}
