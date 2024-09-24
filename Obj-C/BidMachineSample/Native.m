//
//  Native.m
//
//  Copyright © 2024 Appodeal. All rights reserved.
//

#import "Native.h"

#define UNIT_ID         "your unit ID here"
#define ADVERTISER      "bidmachine"

@interface Native ()<BidMachineAdDelegate, GADNativeAdLoaderDelegate>

@property (nonatomic, strong) BidMachineNative *bidMachineNativeAd;
@property (nonatomic, strong) GADNativeAd *googleNativeAd;
@property (nonatomic, strong) GADAdLoader *adLoader;

@property (nonatomic, strong) UIView *adContainer;

@end

@implementation Native

- (void)loadAd:(id)sender {
    [self deleteLoadedAd];
    [self switchState:BSStateLoading];
    
    __weak typeof(self) weakSelf = self;
    [BidMachineSdk.shared native:nil :^(BidMachineNative *native, NSError *error) {
        if (error) {
            [weakSelf switchState: BSStateIdle];
            NSLog(@"Native ad request finished with error %@",error.localizedDescription);
            return;
        }
        weakSelf.bidMachineNativeAd = native;
        weakSelf.bidMachineNativeAd.controller = weakSelf;
        weakSelf.bidMachineNativeAd.delegate = weakSelf;
        [weakSelf.bidMachineNativeAd loadAd];
    }];
}

- (void)showAd:(id)sender {
    [self switchState:BSStateIdle];

    if (self.bidMachineNativeAd && self.bidMachineNativeAd.canShow) {
        [self layoutBidMachineNativeView];
        return;
    }
    // No BidMachine native to show. Fallback to Google native ad or implement your own fallback logic.
    // Google native ad instructions: https://developers.google.com/ad-manager/mobile-ads-sdk/ios/native/advanced)
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutAdContainer];
}

#pragma mark - private

- (void)layoutAdContainer {
    self.adContainer = [UIView new];
    self.adContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.adContainer.layer.borderColor = UIColor.grayColor.CGColor;
    self.adContainer.layer.borderWidth = 1.0;
    
    [self.view addSubview:self.adContainer];
    [NSLayoutConstraint activateConstraints:
     @[
         [self.adContainer.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
         [self.adContainer.heightAnchor constraintGreaterThanOrEqualToConstant:0],
         [self.adContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10],
         [self.adContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10],
     ]];
}

- (void)layoutBidMachineNativeView {
    BMNativeAdView *adView = [BMNativeAdView new];
    NSError *error;

    self.bidMachineNativeAd.controller = self;
    [self.bidMachineNativeAd presentAd:self.adContainer :adView error:&error];
    
    if (error) {
        [self switchState: BSStateIdle];
        // Unable to display the BidMachine ad. Implement your fallback logic here.
        return;
    }
    
    [self.adContainer addSubview:adView];
    adView.translatesAutoresizingMaskIntoConstraints = false;
    [NSLayoutConstraint activateConstraints:
     @[
        [adView.topAnchor constraintEqualToAnchor:self.adContainer.topAnchor],
        [adView.bottomAnchor constraintEqualToAnchor:self.adContainer.bottomAnchor],
        [adView.leadingAnchor constraintEqualToAnchor:self.adContainer.leadingAnchor],
        [adView.trailingAnchor constraintEqualToAnchor:self.adContainer.trailingAnchor],
    ]];
}

- (void)deleteLoadedAd {
    [self.bidMachineNativeAd unregisterView];

    self.bidMachineNativeAd = nil;
    self.googleNativeAd = nil;
    self.adLoader = nil;
    [self.adContainer.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
}

#pragma mark - BidMachineAdDelegate

- (void)didLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    GAMRequest *googleRequest = [GAMRequest request];

    NSString *price = [self.formatter stringFromNumber:@(ad.auctionInfo.price)];
    googleRequest.customTargeting = @{ @"bm_pf" : price };

    self.adLoader = [
        [GADAdLoader alloc]
        initWithAdUnitID:@UNIT_ID
        rootViewController:self
        adTypes:@[ GADAdLoaderAdTypeNative ]
        options:nil
    ];

    self.adLoader.delegate = self;
    [self.adLoader loadRequest:googleRequest];
}

- (void)didFailLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error {
    [self switchState: BSStateIdle];
    self.bidMachineNativeAd = nil;

    // Unable to load BidMachine ad, fallback to Google Ad manager request or handle error accordingly
}

- (void)didDismissAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)willPresentScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didDismissScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didExpired:(id<BidMachineAdProtocol> _Nonnull)ad {
    [self switchState: BSStateIdle];
    [self deleteLoadedAd];
    
    // BidMachine ad has expired. Restart the ad loading process.
}

- (void)didFailPresentAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error {
    
}

- (void)didPresentAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didTrackImpression:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didTrackInteraction:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didUserInteraction:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

#pragma mark - GADNativeAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    [self switchState:BSStateIdle];
    // Unable to load Google ad, implement fallback logic.
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    BOOL bidMachineWon = [nativeAd.advertiser isEqualToString:@ADVERTISER];

    if (bidMachineWon) {
        [BidMachineSdk.shared notifyMediationWin:self.bidMachineNativeAd];
        [self switchState:BSStateReady];
    } else {
        [BidMachineSdk.shared notifyMediationLoss:@"" ecpm:0.0 ad:self.bidMachineNativeAd];
        self.bidMachineNativeAd = nil;
        
        // BidMachine lost. Fallback to Google native ad or implement your own fallback logic.
        self.googleNativeAd = nativeAd;
        [self switchState:BSStateIdle];
    }
}

- (void)adLoaderDidFinishLoading:(GADAdLoader *)adLoader {
}

@end
