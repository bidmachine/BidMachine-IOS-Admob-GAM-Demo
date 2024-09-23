//
//  Banner.m
//
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "Banner.h"

#define UNIT_ID         "your unit ID here"

@interface Banner ()<BidMachineAdDelegate, GADBannerViewDelegate, GADAppEventDelegate>

@property (nonatomic, strong) BidMachineBanner *bidmachineBanner;
@property (nonatomic, strong) GAMBannerView *googleBanner;

@property (weak,   nonatomic) IBOutlet UIView *container;

@end

@implementation Banner

- (void)loadAd:(id)sender {
    [self deleteLoadedAd];
    [self switchState:BSStateLoading];
    
    __weak typeof(self) weakSelf = self;
    [BidMachineSdk.shared banner:nil :^(BidMachineBanner *banner, NSError *error) {
        if (error) {
            [weakSelf switchState: BSStateIdle];
            return;
        }
        weakSelf.bidmachineBanner = banner;
        weakSelf.bidmachineBanner.controller = weakSelf;
        weakSelf.bidmachineBanner.delegate = weakSelf;
        [weakSelf.bidmachineBanner loadAd];
    }];
}

- (void)showAd:(id)sender {
    [self switchState:BSStateIdle];
    
    if (self.bidmachineBanner && self.bidmachineBanner.canShow) {
        [self addBanner:self.bidmachineBanner inContainer:self.container];
        return;
    }
    // No BidMachine banner to show. Fallback to Google native ad or implement your own fallback logic.
}

- (void)addBanner:(UIView *)banner inContainer:(UIView *)container {
    [banner removeFromSuperview];
    [container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [container addSubview:banner];
    banner.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [banner.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [banner.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
        [banner.widthAnchor constraintEqualToConstant: 320],
        [banner.heightAnchor constraintEqualToConstant:50]
    ]];
}

- (void)deleteLoadedAd {
    self.bidmachineBanner = nil;
    self.googleBanner = nil;
    [self.container.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        [subview removeFromSuperview];
    }];
}

#pragma mark - BidMachineAdDelegate

- (void)didLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    GAMRequest *googleRequest = [GAMRequest request];
    googleRequest.customTargeting = @{
        @"bm_pf" : [self.formatter stringFromNumber:@(ad.auctionInfo.price)]
    };
    
    self.googleBanner = [[GAMBannerView alloc] initWithAdSize:GADAdSizeBanner];
    self.googleBanner.delegate = self;
    self.googleBanner.adUnitID = @UNIT_ID;
    self.googleBanner.rootViewController = self;
    self.googleBanner.appEventDelegate = self;

    [self.googleBanner loadRequest:googleRequest];
}

- (void)didFailLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error {
    [self switchState:BSStateIdle];
    self.bidmachineBanner = nil;
    
    // Unable to load BidMachine ad, fallback to Google Ad manager request or handle error accordingly
}

- (void)didDismissAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didDismissScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

- (void)didExpired:(id<BidMachineAdProtocol> _Nonnull)ad {
    [self deleteLoadedAd];
    [self switchState:BSStateIdle];
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

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView {
    
}

- (void)bannerView:(nonnull GADBannerView *)bannerVie didFailToReceiveAdWithError:(nonnull NSError *)error {
    [self switchState:BSStateIdle];
}

- (void)bannerViewDidRecordImpression:(nonnull GADBannerView *)bannerView {
    
}

- (void)adView:(nonnull GADBannerView *)banner didReceiveAppEvent:(nonnull NSString *)name withInfo:(nullable NSString *)info {
    BOOL bidMachineWon = [name isEqualToString:@"bidmachine-banner"];

    if (bidMachineWon) {
        [BidMachineSdk.shared notifyMediationWin:self.bidmachineBanner];
        [self switchState:BSStateReady];
        self.googleBanner = nil;
    } else {
        [BidMachineSdk.shared notifyMediationLoss:@"" ecpm:0.0 ad:self.bidmachineBanner];
        self.bidmachineBanner = nil;

        // BidMachine lost. Fallback to Google native ad or implement your own fallback logic.
        [self switchState:BSStateIdle];
    }
}

@end
