//
//  InterstitialViewController.swift
//  BidMachineSample
//
//  Created by Dzmitry on 19/09/2024.
//

import UIKit
import BidMachine
import GoogleMobileAds

private enum Constant {
    static let nativeName = "bidmachine"
    static let nativeUnitID = "/22897248656/bidmachine_test/native" // "your unit id here"
}


final class NativeViewController: AdLoadController {
    private let nativeViewContainer = UIView()
    
    private var bidMachineNativeAd: BidMachineNative?
    private var googleNativeAd: GADNativeAd?
    private var googleLoader: GADAdLoader?

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
        deleteLoadedAd()
        switchState(to: .loading)
        
        BidMachineSdk.shared.native { [weak self] nativeAd, error in
            if let error {
                self?.switchState(to: .idle)
                self?.showAlert(with: "Error ocured: \(error.localizedDescription)")
            } else {
                self?.bidMachineNativeAd = nativeAd
                self?.bidMachineNativeAd?.controller = self
                self?.bidMachineNativeAd?.delegate = self
                self?.bidMachineNativeAd?.loadAd()
            }
        }
    }
    
    override func showAd() {
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
        showAlert(with: "Error ocured: \(error.localizedDescription)")
    }
}

extension NativeViewController: GADAdLoaderDelegate {
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        let bidMachineWon = ad
    }

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        <#code#>
    }
}
