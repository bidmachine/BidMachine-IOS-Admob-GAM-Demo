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
            if let error {
                self?.switchState(to: .idle)
                self?.showAlert(with: error.localizedDescription)
            } else {
                self?.bidMachineRewarded = rewarded
                self?.bidMachineRewarded?.controller = self
                self?.bidMachineRewarded?.delegate = self
                self?.bidMachineRewarded?.loadAd()
            }
        }
    }
    
    override func showAd() {
        switchState(to: .idle)
        
        guard let bidMachineRewarded, bidMachineRewarded.canShow else {
            showAlert(with: "No rewarded to show")
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
            if let error {
                self?.switchState(to: .idle)
                self?.showAlert(with: "Error occurred: \(error.localizedDescription)")
            } else {
                self?.googleRewarded = rewarded
                self?.googleRewarded?.adMetadataDelegate = self
            }
        }
    }
    
    public func didFailLoadAd(_ ad: any BidMachine.BidMachineAdProtocol, _ error: any Error) {
        switchState(to: .idle)
        showAlert(with: "Error occurred: \(error.localizedDescription)")
    }
}

extension RewardedViewController: GADAdMetadataDelegate {
    func adMetadataDidChange(_ ad: any GADAdMetadataProvider) {
        guard let adTitle = ad.adMetadata?[GADAdMetadataKey(rawValue: "AdTitle")] as? String else {
            switchState(to: .idle)
            return
        }
        switch adTitle {
        case Constant.rewardedName:
            switchState(to: .loaded)
        default:
            switchState(to: .idle)

            // fallback to google rewarded
            showAlert(with: "Google ad loaded with title: \(adTitle)")
        }
    }
}
