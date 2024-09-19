//
//  BanneViewController.swift
//  BidMachineSample
//
//  Created by Dzmitry on 19/09/2024.
//

import UIKit
import BidMachine
import GoogleMobileAds

private enum Constant {
    static let bmBannerName = "bidmachine-banner"
    static let bannerUnitID = "/22897248656/bidmachine_test/banner" // "your unit id here"
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
            guard error == nil else {
                self?.switchState(to: .idle)
                self?.showAlert(with: "Error ocured: \(error?.localizedDescription ?? "")")
                return
            }
            
            self?.bidmachineBanner = banner
            self?.bidmachineBanner?.controller = self
            self?.bidmachineBanner?.delegate = self
            self?.bidmachineBanner?.loadAd()
        }
    }
    
    override func showAd() {
        switchState(to: .idle)

        guard let bidmachineBanner, bidmachineBanner.canShow else {
            showAlert(with: "No banner to show")
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
        self.googleBanner = GAMBannerView(adSize: GADAdSizeBanner)
        self.googleBanner?.adUnitID = Constant.bannerUnitID
        self.googleBanner?.delegate = self
        self.googleBanner?.appEventDelegate = self
        self.googleBanner?.rootViewController = self
        
        let request = GAMRequest.withBidMachineAdTargeting(ad)
        
        self.googleBanner?.load(request)
    }
    
    func didFailLoadAd(_ ad: any BidMachine.BidMachineAdProtocol, _ error: any Error) {
        switchState(to: .idle)
        showAlert(with: "Error ocured: \(error.localizedDescription)")
    }
}

extension BannerViewController: GADAppEventDelegate {
    func adView(_ banner: GADBannerView, didReceiveAppEvent name: String, withInfo info: String?) {
        switch name {
        case Constant.bmBannerName:
            switchState(to: .loaded)
        default:
            switchState(to: .idle)

            // fallback to google interstitial
            showAlert(with: "Google ad loaded with name: \(name)")
        }
    }
}

extension BannerViewController: GADBannerViewDelegate {
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: any Error) {
        switchState(to: .idle)
        showAlert(with: "Error ocured: \(error.localizedDescription)")
    }
}
