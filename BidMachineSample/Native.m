//
//  Native.m
//
//  Copyright © 2024 Appodeal. All rights reserved.
//

#import "Native.h"

#define UNIT_ID         "/91759738/bm_native"

@interface Native ()<BidMachineAdDelegate, GADNativeAdLoaderDelegate>

@property (nonatomic, strong) BidMachineNative *bidMachineNativeAd;
@property (nonatomic, strong) GADNativeAd *googleNativeAd;
@property (nonatomic, strong) GADAdLoader *adLoader;

@property (nonatomic, strong) UIView *adContainer;

@end

@implementation Native

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.adContainer = [UIView new];
    self.adContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.adContainer.backgroundColor = UIColor.redColor;
    
    [self.view addSubview:self.adContainer];
    [NSLayoutConstraint activateConstraints:
     @[
         [self.adContainer.topAnchor constraintEqualToAnchor:self.view.topAnchor],
         [self.adContainer.heightAnchor constraintEqualToConstant:300],
         [self.adContainer.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
         [self.adContainer.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
     ]];
}

- (void)loadAd:(id)sender {
    [self switchState:BSStateLoading];
    [self loadNative];
}

- (void)showAd:(id)sender {
    [self switchState:BSStateIdle];
    
    if (self.bidMachineNativeAd) {
        NativeAdView *adView = [NativeAdView new];
        NSError *error;
        
        [self.bidMachineNativeAd presentAd:self.adContainer :adView error:&error];
    } else if (self.googleNativeAd) {
        GADNativeAdView* googleView = [GADNativeAdView new];
        googleView.nativeAd = self.googleNativeAd;
        
        #warning populate with data and layout in container?
    }
}

#pragma mark - private

- (void)loadNative {
    __weak typeof(self) weakSelf = self;
    
    [BidMachineSdk.shared native:nil :^(BidMachineNative *native, NSError *error) {
        if (error) {
            [weakSelf switchState: BSStateIdle];
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
        googleRequest.customTargeting = @{
            @"bm_pf" : [self.formatter stringFromNumber:@(ad.auctionInfo.price)]
        };
    }

    self.adLoader = [
        [GADAdLoader alloc]
        initWithAdUnitID:@UNIT_ID
        rootViewController:nil
        adTypes:@[ GADAdLoaderAdTypeNative ]
        options:@[]
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
    #warning ask about winner and ecpm
    [BidMachineSdk.shared notifyMediationLoss:@"WINNER" ecpm:0.0 ad:self.bidMachineNativeAd];
    self.bidMachineNativeAd = nil;
}

#pragma mark - BidMachineAdDelegate

- (void)didLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    [self loadAdManagerNativeWith:ad];
}

- (void)didFailLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error {
    [self loadAdManagerNativeWith:nil];
}

#pragma mark - GADNativeAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    [self switchState:BSStateIdle];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    BOOL bidMachineWon = [nativeAd.advertiser isEqualToString:@"bidmachine"];
    
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
