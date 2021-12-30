//
//  Interstitial.m
//
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "Interstitial.h"

#define UNIT_ID         "/91759738/bm_interstitial"

@interface Interstitial ()<BDMInterstitialDelegate, BDMRequestDelegate, GADAppEventDelegate>

@property (nonatomic, strong) BDMInterstitial *interstitial;
@property (nonatomic, strong) GAMInterstitialAd *adMobInterstitial;
@property (nonatomic, strong) BDMInterstitialRequest *interstitialRequest;

@end

@implementation Interstitial

- (void)loadAd:(id)sender {
    [self switchState:BSStateLoading];
    
    self.interstitialRequest = [BDMInterstitialRequest new];
    [self.interstitialRequest performWithDelegate:self];
}

- (void)showAd:(id)sender {
    [self switchState:BSStateIdle];
    [self.interstitial presentFromRootViewController:self];
}

#pragma mark - BDMRequestDelegate

- (void)request:(BDMRequest *)request completeWithInfo:(BDMAuctionInfo *)info {
    __weak __typeof__(self) weakSelf = self;
    
    GAMRequest *adMobRequest = [GAMRequest request];
    adMobRequest.customTargeting = request.info.customParams;
    
    [GAMInterstitialAd loadWithAdManagerAdUnitID:@UNIT_ID
                                         request:adMobRequest
                               completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd,
                                                   NSError * _Nullable error) {
        if (error) {
            [weakSelf switchState: BSStateIdle];
        } else {
            weakSelf.adMobInterstitial = interstitialAd;
            weakSelf.adMobInterstitial.appEventDelegate = weakSelf;
        }
    }];
}

- (void)request:(BDMRequest *)request failedWithError:(NSError *)error {
    [self switchState: BSStateIdle];
}

- (void)requestDidExpire:(BDMRequest *)request {}

#pragma mark - BDMInterstitialDelegate

- (void)interstitialReadyToPresent:(nonnull BDMInterstitial *)interstitial {
    [self switchState:BSStateReady];
}

- (void)interstitial:(nonnull BDMInterstitial *)interstitial failedWithError:(nonnull NSError *)error {
    [self switchState:BSStateIdle];
}

- (void)interstitial:(nonnull BDMInterstitial *)interstitial failedToPresentWithError:(nonnull NSError *)error {
    
}

- (void)interstitialWillPresent:(nonnull BDMInterstitial *)interstitial {
    
}

- (void)interstitialDidDismiss:(nonnull BDMInterstitial *)interstitial {
    
}

- (void)interstitialRecieveUserInteraction:(nonnull BDMInterstitial *)interstitial {
    
}

#pragma mark - GADAppEventDelegate

- (void)interstitialAd:(nonnull GADInterstitialAd *)interstitialAd
    didReceiveAppEvent:(nonnull NSString *)name
              withInfo:(nullable NSString *)info {
    
    if ([name isEqualToString:@"bidmachine-interstitial"]) {
        self.interstitial = [BDMInterstitial new];
        self.interstitial.delegate = self;
        [self.interstitial populateWithRequest:self.interstitialRequest];
    } else {
        [self switchState:BSStateIdle];
    }
}

@end
