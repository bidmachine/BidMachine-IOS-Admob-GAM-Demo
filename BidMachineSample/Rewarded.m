//
//  Rewarded.m
//
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "Rewarded.h"

#define UNIT_ID         "/91759738/bm_rewarded"

@interface Rewarded ()<BDMRewardedDelegate, BDMRequestDelegate, GADAdMetadataDelegate>

@property (nonatomic, strong) BDMRewarded *rewarded;
@property (nonatomic, strong) GADRewardedAd *adMobRewarded;
@property (nonatomic, strong) BDMRewardedRequest *rewardedRequest;

@end

@implementation Rewarded

- (void)loadAd:(id)sender {
    [self switchState:BSStateLoading];
    
    self.rewardedRequest = [BDMRewardedRequest new];
    [self.rewardedRequest performWithDelegate:self];
}

- (void)showAd:(id)sender {
    [self switchState:BSStateIdle];
    [self.rewarded presentFromRootViewController:self];
}

#pragma mark - BDMRequestDelegate

- (void)request:(BDMRequest *)request completeWithInfo:(BDMAuctionInfo *)info {
    __weak __typeof__(self) weakSelf = self;
    
    GAMRequest *adMobRequest = [GAMRequest request];
    adMobRequest.customTargeting = request.info.customParams;
    
    [GADRewardedAd loadWithAdUnitID:@UNIT_ID
                            request:adMobRequest
                  completionHandler:^(GADRewardedAd * _Nullable rewardedAd,
                                      NSError * _Nullable error) {
        if (error) {
            [weakSelf switchState:BSStateIdle];
        } else {
            weakSelf.adMobRewarded = rewardedAd;
            weakSelf.adMobRewarded.adMetadataDelegate = weakSelf;
        }
    }];
}

- (void)request:(BDMRequest *)request failedWithError:(NSError *)error {
    [self switchState:BSStateIdle];
}

- (void)requestDidExpire:(BDMRequest *)request {}

#pragma mark - BDMRewardedDelegate

- (void)rewardedReadyToPresent:(nonnull BDMRewarded *)rewarded {
    [self switchState:BSStateReady];
}

- (void)rewarded:(nonnull BDMRewarded *)rewarded failedWithError:(nonnull NSError *)error {
    [self switchState:BSStateIdle];
}

- (void)rewarded:(nonnull BDMRewarded *)rewarded failedToPresentWithError:(nonnull NSError *)error {
    
}

- (void)rewardedWillPresent:(nonnull BDMRewarded *)rewarded {
    
}

- (void)rewardedDidDismiss:(nonnull BDMRewarded *)rewarded {
    
}

- (void)rewardedRecieveUserInteraction:(nonnull BDMRewarded *)rewarded {
    
}

- (void)rewardedFinishRewardAction:(nonnull BDMRewarded *)rewarded {
    
}

- (void)adMetadataDidChange:(nonnull id<GADAdMetadataProvider>)ad {
    if (![ad.adMetadata[@"AdTitle"] isEqual:@"bidmachine-rewarded"]) {
        [self switchState:BSStateIdle];
    } else {
        self.rewarded = [BDMRewarded new];
        self.rewarded.delegate = self;
        [self.rewarded populateWithRequest:self.rewardedRequest];
    }
}

@end
