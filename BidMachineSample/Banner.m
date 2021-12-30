//
//  Banner.m
//
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "Banner.h"

#define UNIT_ID         "/91759738/bm_banner"

@interface Banner ()<BDMBannerDelegate, BDMRequestDelegate, GADBannerViewDelegate, GADAppEventDelegate>

@property (nonatomic, strong) BDMBannerView *banner;
@property (nonatomic, strong) GAMBannerView *adMobBanner;
@property (nonatomic, strong) BDMBannerRequest *bannerRequest;

@property (weak,   nonatomic) IBOutlet UIView *container;

@end

@implementation Banner

- (void)loadAd:(id)sender {
    [self switchState:BSStateLoading];
    self.bannerRequest = [BDMBannerRequest new];
//    self.bannerRequest.adSize = BDMBannerAdSize320x50;
//    self.bannerRequest.adSize = BDMBannerAdSize300x250;
    [self.bannerRequest performWithDelegate:self];
}

- (void)showAd:(id)sender {
    [self switchState:BSStateIdle];
    [self addBanner:self.banner inContainer:self.container];
}

- (void)addBanner:(UIView *)banner inContainer:(UIView *)container {
    [banner removeFromSuperview];
    [container.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [container addSubview:banner];
    banner.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:
        @[
          [banner.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
          [banner.centerYAnchor constraintEqualToAnchor:container.centerYAnchor],
          [banner.widthAnchor constraintEqualToConstant: 320],
          [banner.heightAnchor constraintEqualToConstant:50]
          ]];
}

#pragma mark - BDMRequestDelegate

- (void)request:(BDMRequest *)request completeWithInfo:(BDMAuctionInfo *)info {
    GAMRequest *adMobRequest = [GAMRequest request];
    adMobRequest.customTargeting = request.info.customParams;
    
    self.adMobBanner = [[GAMBannerView alloc] initWithAdSize:GADAdSizeBanner];
    self.adMobBanner.delegate = self;
    self.adMobBanner.adUnitID = @UNIT_ID;
    self.adMobBanner.rootViewController = [[UIApplication.sharedApplication keyWindow] rootViewController];
    self.adMobBanner.appEventDelegate = self;

    [self.adMobBanner loadRequest:adMobRequest];
}

- (void)request:(BDMRequest *)request failedWithError:(NSError *)error {
    [self switchState:BSStateIdle];
}

- (void)requestDidExpire:(BDMRequest *)request {}

#pragma mark - BDMBannerDelegate

- (void)bannerViewReadyToPresent:(nonnull BDMBannerView *)bannerView {
    [self switchState:BSStateReady];
}

- (void)bannerView:(nonnull BDMBannerView *)bannerView failedWithError:(nonnull NSError *)error {
    [self switchState:BSStateIdle];
}

- (void)bannerViewRecieveUserInteraction:(nonnull BDMBannerView *)bannerView {
    
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
    if ([name isEqualToString:@"bidmachine-banner"]) {
        self.banner = [BDMBannerView new];
        self.banner.delegate = self;
        [self.banner populateWithRequest:self.bannerRequest];
    } else {
        [self switchState:BSStateIdle];
    }
}

@end
