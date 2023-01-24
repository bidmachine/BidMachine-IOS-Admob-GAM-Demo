//
//  Rewarded.m
//
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "Rewarded.h"

#define UNIT_ID         "/91759738/bm_rewarded"

@interface Rewarded ()<BidMachineAdDelegate, GADAdMetadataDelegate>

@property (nonatomic, strong) BidMachineRewarded *bidMachineRewarded;
@property (nonatomic, strong) GADRewardedAd *googleRewarded;

@end

@implementation Rewarded

- (void)loadAd:(id)sender {
    [self switchState:BSStateLoading];
    
    __weak typeof(self) weakSelf = self;
    [BidMachineSdk.shared rewarded:nil :^(BidMachineRewarded *rewarded, NSError *error) {
        if (error) {
            [weakSelf switchState: BSStateIdle];
            return;
        }
        weakSelf.bidMachineRewarded = rewarded;
        weakSelf.bidMachineRewarded.controller = weakSelf;
        weakSelf.bidMachineRewarded.delegate = weakSelf;
        [weakSelf.bidMachineRewarded loadAd];
    }];
}

- (void)showAd:(id)sender {
    [self switchState:BSStateIdle];
    [self.bidMachineRewarded presentAd];
}

#pragma mark - BidMachineAdDelegate

- (void)didLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    GAMRequest *googleRequest = [GAMRequest request];
    googleRequest.customTargeting = @{
        @"bm_pf" : [self.formatter stringFromNumber:@(ad.auctionInfo.price)]
    };
    
    __weak typeof(self) weakSelf = self;
    [GADRewardedAd loadWithAdUnitID:@UNIT_ID
                            request:googleRequest
                  completionHandler:^(GADRewardedAd * _Nullable rewardedAd,
                                      NSError * _Nullable error) {
        if (error) {
            [weakSelf switchState:BSStateIdle];
        } else {
            weakSelf.googleRewarded = rewardedAd;
            weakSelf.googleRewarded.adMetadataDelegate = weakSelf;
        }
    }];
}

- (void)didFailLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad :(NSError * _Nonnull)error {
    [self switchState:BSStateIdle];
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

#pragma mark - GADAdMetadataDelegate

- (void)adMetadataDidChange:(nonnull id<GADAdMetadataProvider>)ad {
    if (![ad.adMetadata[@"AdTitle"] isEqual:@"bidmachine-rewarded"]) {
        [self switchState:BSStateIdle];
    } else {
        [self switchState:BSStateReady];
    }
}

@end
