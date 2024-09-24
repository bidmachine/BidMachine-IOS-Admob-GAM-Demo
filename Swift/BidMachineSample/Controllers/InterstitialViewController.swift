//
//  Copyright © 2024 Appodeal. All rights reserved.
//

import UIKit
import GoogleMobileAds
import BidMachine

private enum Constant {
    static let interstitialName = "bidmachine-interstitial"
    static let interstitialUnitID = "your unit id here"
}

final class InterstitialViewController: AdLoadController {
    private var bidmachineInterstitial: BidMachineInterstitial?
    private var googleInterstitial: GAMInterstitialAd?

    override var topTitle: String? {
        "Interstitial"
    }

    override func loadAd() {
        deleteLoadedAd()
        switchState(to: .loading)
        
        BidMachineSdk.shared.interstitial { [weak self] interstitial, error in
            guard let self else {
                return
            }
            if let error {
                self.switchState(to: .idle)
                self.showAlert(with: "Error occurred: \(error.localizedDescription)")
            } else {
                self.bidmachineInterstitial = interstitial
                self.bidmachineInterstitial?.controller = self
                self.bidmachineInterstitial?.delegate = self
                self.bidmachineInterstitial?.loadAd()
            }
        }
    }
    
    override func showAd() {
        switchState(to: .idle)

        guard let bidmachineInterstitial, bidmachineInterstitial.canShow else {
            showAlert(with: "No inter to show")
            // No BidMachine interstitial to show. Fallback to Google native ad or implement your own fallback logic.

            return
        }
        bidmachineInterstitial.presentAd()
    }
    
    private func deleteLoadedAd() {
        bidmachineInterstitial = nil
        googleInterstitial = nil
    }
}

extension InterstitialViewController: BidMachineAdDelegate {
    func didLoadAd(_ ad: any BidMachineAdProtocol) {
        let request = GAMRequest.withBidMachineAdTargeting(ad)
        
        GAMInterstitialAd.load(
            withAdManagerAdUnitID: Constant.interstitialUnitID,
            request: request
        ) { [weak self] interstitial, error in
            guard let self else {
                return
            }

            if let error {
                self.switchState(to: .idle)
                self.showAlert(with: "Error occurred: \(error.localizedDescription)")
            } else {
                self.googleInterstitial = interstitial
                self.googleInterstitial?.appEventDelegate = self
            }
        }
    }

    func didFailLoadAd(_ ad: any BidMachine.BidMachineAdProtocol, _ error: any Error) {
        switchState(to: .idle)
        bidmachineInterstitial = nil
        
        // Unable to load BidMachine ad, fallback to Google Ad manager request or handle error accordingly
        showAlert(with: "Error occurred: \(error.localizedDescription)")
    }

    func didDismissAd(_ ad: any BidMachineAdProtocol) {

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
    
    func didTrackImpression(_ ad: any BidMachineAdProtocol) {

    }
    
    func didTrackInteraction(_ ad: any BidMachineAdProtocol) {

    }
    
    func didUserInteraction(_ ad: any BidMachineAdProtocol) {

    }
    
    func willPresentScreen(_ ad: any BidMachineAdProtocol) {

    }
}

extension InterstitialViewController: GADAppEventDelegate {
    func interstitialAd(_ interstitialAd: GADInterstitialAd, didReceiveAppEvent name: String, withInfo info: String?) {
        let bidMachineWon = name == Constant.interstitialName

        if bidMachineWon {
            bidmachineInterstitial.map { BidMachineSdk.shared.notifyMediationWin($0) }
            switchState(to: .loaded)
        } else {
            bidmachineInterstitial.map { BidMachineSdk.shared.notifyMediationLoss("", 0.0, $0) }
            bidmachineInterstitial = nil

            // BidMachine lost. Fallback to Google native ad or implement your own fallback logic.
            switchState(to: .idle)
            showAlert(with: "Google ad loaded with name: \(name)")
        }
    }
}
