//
//  Copyright © 2024 Appodeal. All rights reserved.
//

import UIKit
import BidMachine
import GoogleMobileAds

private enum Constant {
    static let rewardedName = "bidmachine-rewarded"
    static let rewardedUnitID = "your unit id here"
}

final class RewardedViewController: AdLoadController {
    private var bidMachineRewarded: BidMachineRewarded?
    private var googleRewarded: GADRewardedAd?
    
    override var topTitle: String? {
        "Rewarded"
    }

    override func loadAd() {
        deleteLoadedAd()
        switchState(to: .loading)
        
        BidMachineSdk.shared.rewarded { [weak self] rewarded, error in
            guard let self else {
                return
            }
            guard let rewarded else {
                self.switchState(to: .idle)
                self.showAlert(with: "Error occurred: \(error?.localizedDescription ?? "")")
                return
            }
            self.bidMachineRewarded = rewarded
            rewarded.controller = self
            rewarded.delegate = self
            rewarded.loadAd()
        }
    }
    
    override func showAd() {
        switchState(to: .idle)
        
        guard let bidMachineRewarded, bidMachineRewarded.canShow else {
            showAlert(with: "No rewarded to show")
            // No BidMachine rewarded to show. Fallback to Google native ad or implement your own fallback logic.

            return
        }
        bidMachineRewarded.presentAd()
    }
    
    private func deleteLoadedAd() {
        bidMachineRewarded = nil
        googleRewarded = nil
    }
}

extension RewardedViewController: BidMachineAdDelegate {
    public func didLoadAd(_ ad: any BidMachine.BidMachineAdProtocol) {
        let request = GAMRequest.withBidMachineAdTargeting(ad)
        
        GADRewardedAd.load(
            withAdUnitID: Constant.rewardedUnitID,
            request: request
        ) { [weak self] rewarded, error in
            guard let self else {
                return
            }
            guard let rewarded else {
                self.switchState(to: .idle)
                self.showAlert(with: "Error occurred: \(error?.localizedDescription ?? "")")
                return
            }
            self.googleRewarded = rewarded
            rewarded.adMetadataDelegate = self
        }
    }
    
    public func didFailLoadAd(_ ad: any BidMachine.BidMachineAdProtocol, _ error: any Error) {
        switchState(to: .idle)
        bidMachineRewarded = nil
        
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
    
    func didTrackImpression(_ ad: any BidMachineAdProtocol) {

    }
    
    func didTrackInteraction(_ ad: any BidMachineAdProtocol) {

    }
    
    func didUserInteraction(_ ad: any BidMachineAdProtocol) {

    }
}

extension RewardedViewController: GADAdMetadataDelegate {
    func adMetadataDidChange(_ ad: any GADAdMetadataProvider) {
        let adTitle = ad.adMetadata?[GADAdMetadataKey(rawValue: "AdTitle")] as? String
        let bidMachineWon = adTitle == Constant.rewardedName

        if bidMachineWon {
            bidMachineRewarded.map { BidMachineSdk.shared.notifyMediationWin($0) }
            switchState(to: .loaded)
        } else {
            bidMachineRewarded.map { BidMachineSdk.shared.notifyMediationLoss("", 0.0, $0) }
            bidMachineRewarded = nil

            // BidMachine lost. Fallback to Google native ad or implement your own fallback logic.
            switchState(to: .idle)
            showAlert(with: "Google ad loaded with title: \(adTitle ?? "unknown")")
        }
    }
}
