//
//  Copyright © 2024 Appodeal. All rights reserved.
//

import UIKit
import BidMachine
import GoogleMobileAds

private enum Constant {
    static let bmBannerName = "bidmachine-banner"
    static let bannerUnitID = "your unit id here"
}

final class BannerViewController: AdLoadController {
    override var topTitle: String? {
        "Banner"
    }

    private let bannerContainer = UIView()
    
    private var bidmachineBanner: BidMachineBanner?
    private var googleBanner: GAMBannerView?

    override func layoutContent() {
        super.layoutContent()
        
        bannerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerContainer)
        
        NSLayoutConstraint.activate([
            bannerContainer.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor),
            bannerContainer.widthAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.widthAnchor),
            bannerContainer.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor, constant: -20),
            bannerContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
    }

    override func loadAd() {
        deleteLoadedAd()
        switchState(to: .loading)

        BidMachineSdk.shared.banner { [weak self] (banner, error) in
            guard let self else {
                return
            }
            guard let banner else {
                self.switchState(to: .idle)
                self.showAlert(with: "Error occurred: \(error?.localizedDescription ?? "")")
                return
            }
            self.bidmachineBanner = banner
            banner.controller = self
            banner.delegate = self
            banner.loadAd()
        }
    }
    
    override func showAd() {
        switchState(to: .idle)

        guard let bidmachineBanner, bidmachineBanner.canShow else {
            showAlert(with: "No banner to show")
            // No BidMachine banner to show. Fallback to Google native ad or implement your own fallback logic.

            return
        }

        bannerContainer.addSubview(bidmachineBanner)
        bidmachineBanner.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bidmachineBanner.topAnchor.constraint(equalTo: bannerContainer.topAnchor),
            bidmachineBanner.leftAnchor.constraint(equalTo: bannerContainer.leftAnchor),
            bidmachineBanner.bottomAnchor.constraint(equalTo: bannerContainer.bottomAnchor),
            bidmachineBanner.rightAnchor.constraint(equalTo: bannerContainer.rightAnchor),
            bidmachineBanner.heightAnchor.constraint(equalToConstant: 50),
            bidmachineBanner.widthAnchor.constraint(equalToConstant: 320)
        ])
    }

    private func deleteLoadedAd() {
        bannerContainer.subviews.forEach { $0.removeFromSuperview() }
        bidmachineBanner = nil
        googleBanner = nil
    }
}

extension BannerViewController: BidMachineAdDelegate {
    func didLoadAd(_ ad: any BidMachine.BidMachineAdProtocol) {
        let banner = GAMBannerView(adSize: GADAdSizeBanner)

        self.googleBanner = banner
        banner.adUnitID = Constant.bannerUnitID
        banner.delegate = self
        banner.appEventDelegate = self
        banner.rootViewController = self
        
        let request = GAMRequest.withBidMachineAdTargeting(ad)
        
        banner.load(request)
    }
    
    func didFailLoadAd(_ ad: any BidMachine.BidMachineAdProtocol, _ error: any Error) {
        switchState(to: .idle)
        bidmachineBanner = nil
        
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

extension BannerViewController: GADAppEventDelegate {
    func adView(_ banner: GADBannerView, didReceiveAppEvent name: String, withInfo info: String?) {
        let bidMachineWon = name == Constant.bmBannerName
        
        if bidMachineWon {
            bidmachineBanner.map { BidMachineSdk.shared.notifyMediationWin($0) }
            switchState(to: .loaded)
        } else {
            bidmachineBanner.map { BidMachineSdk.shared.notifyMediationLoss("", 0.0, $0) }
            bidmachineBanner = nil

            // BidMachine lost. Fallback to Google native ad or implement your own fallback logic.
            switchState(to: .idle)
            showAlert(with: "Google ad loaded with name: \(name)")
        }
    }
}

extension BannerViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {

    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: any Error) {
        switchState(to: .idle)
        showAlert(with: "Error occurred: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {

    }
}
