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
    [self switchState:BSStateLoading];
    [self loadNative];
}

- (void)showAd:(id)sender {
    [self switchState:BSStateIdle];

    if (self.bidMachineNativeAd) {
        if (self.bidMachineNativeAd.canShow) {
            [self layoutBidMachineNativeView];
        } else {
            NSLog(@"Bid Machine ad object can't be shown");
        }
    } else if (self.googleNativeAd) {
        [self layoutAdManagerNativeView];
    } else {
        NSLog(@"No ad to display");
    }
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
    NativeAdView *adView = [NativeAdView new];
    NSError *error;
    self.bidMachineNativeAd.controller = self;
    [self.bidMachineNativeAd presentAd:self.adContainer :adView error:&error];
    
    if (error) {
        return;
    }
    
    adView.translatesAutoresizingMaskIntoConstraints = false;
    [self.adContainer addSubview:adView];
    [NSLayoutConstraint activateConstraints:
     @[
        [adView.topAnchor constraintEqualToAnchor:self.adContainer.topAnchor],
        [adView.bottomAnchor constraintEqualToAnchor:self.adContainer.bottomAnchor],
        [adView.leadingAnchor constraintEqualToAnchor:self.adContainer.leadingAnchor],
        [adView.trailingAnchor constraintEqualToAnchor:self.adContainer.trailingAnchor],
    ]];
}

- (void)layoutAdManagerNativeView {
    GADNativeAdView* googleAdView = [GADNativeAdView new];
    googleAdView.nativeAd = self.googleNativeAd;

    // Set up GADNativeAdView following the instructions at: https://developers.google.com/ad-manager/mobile-ads-sdk/ios/native/advanced
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

- (void)loadNative {
    [self deleteLoadedAd];

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

- (void)loadAdManagerNativeWith:(id<BidMachineAdProtocol> _Nullable)ad {
    GAMRequest *googleRequest = [GAMRequest request];

    if (ad) {
        NSString *price = [self.formatter stringFromNumber:@(ad.auctionInfo.price)];
        googleRequest.customTargeting = @{ @"bm_pf" : price };
    }

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

- (void)onBidMachineWin {
    [BidMachineSdk.shared notifyMediationWin:self.bidMachineNativeAd];
    
    if (self.bidMachineNativeAd.canShow) {
        [self switchState:BSStateReady];
    }
}

- (void)onBidMachineLoss {
    [BidMachineSdk.shared notifyMediationLoss:@"unknown" ecpm:0.0 ad:self.bidMachineNativeAd];
    self.bidMachineNativeAd = nil;
}

- (BOOL)isBidMachineAd:(GADNativeAd *)nativeAd {
    if (!nativeAd.advertiser) {
        return NO;
    }
    return [nativeAd.advertiser isEqualToString:@ADVERTISER];
}

#pragma mark - BidMachineAdDelegate

- (void)didLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    [self loadAdManagerNativeWith:ad];
}

- (void)didFailLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error {
    [self loadAdManagerNativeWith:nil];
}

- (void)didDismissAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didDismissScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didExpired:(id<BidMachineAdProtocol> _Nonnull)ad {
    
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

- (void)willPresentScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

#pragma mark - GADNativeAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    [self switchState:BSStateIdle];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    BOOL bidMachineWon = [self isBidMachineAd:nativeAd];
    
    if (bidMachineWon) {
        [self onBidMachineWin];
    } else {
        self.googleNativeAd = nativeAd;
        [self onBidMachineLoss];
    }
}

- (void)adLoaderDidFinishLoading:(GADAdLoader *)adLoader {
}

@end
