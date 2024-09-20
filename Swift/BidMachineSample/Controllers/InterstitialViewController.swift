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
            if let error {
                self?.switchState(to: .idle)
                self?.showAlert(with: "Error occurred: \(error.localizedDescription)")
            } else {
                self?.bidmachineInterstitial = interstitial
                self?.bidmachineInterstitial?.controller = self
                self?.bidmachineInterstitial?.delegate = self
                self?.bidmachineInterstitial?.loadAd()
            }
        }
    }
    
    override func showAd() {
        switchState(to: .idle)

        guard let bidmachineInterstitial, bidmachineInterstitial.canShow else {
            showAlert(with: "No inter to show")
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
            if let error {
                self?.switchState(to: .idle)
                self?.showAlert(with: "Error occurred: \(error.localizedDescription)")
            } else {
                self?.googleInterstitial = interstitial
                self?.googleInterstitial?.appEventDelegate = self
            }
        }
    }

    func didFailLoadAd(_ ad: any BidMachine.BidMachineAdProtocol, _ error: any Error) {
        switchState(to: .idle)
        showAlert(with: "Error occurred: \(error.localizedDescription)")
    }
}

extension InterstitialViewController: GADAppEventDelegate {
    func interstitialAd(_ interstitialAd: GADInterstitialAd, didReceiveAppEvent name: String, withInfo info: String?) {
        switch name {
        case Constant.interstitialName:
            switchState(to: .loaded)
        default:
            switchState(to: .idle)

            // fallback to google interstitial
            showAlert(with: "Google ad loaded with name: \(name)")
        }
    }
}
