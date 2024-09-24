//
//  Rewarded.m
//
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "Rewarded.h"

#define UNIT_ID         "your unit ID here"

@interface Rewarded ()<BidMachineAdDelegate, GADAdMetadataDelegate>

@property (nonatomic, strong) BidMachineRewarded *bidMachineRewarded;
@property (nonatomic, strong) GADRewardedAd *googleRewarded;

@end

@implementation Rewarded

- (void)loadAd:(id)sender {
    [self deleteLoadedAd];
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
    
    if (self.bidMachineRewarded && self.bidMachineRewarded.canShow) {
        [self.bidMachineRewarded presentAd];
        return;
    }
    
    // No BidMachine rewarded to show. Fallback to Google native ad or implement your own fallback logic.
}

- (void)deleteLoadedAd {
    self.bidMachineRewarded = nil;
    self.googleRewarded = nil;
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
    self.bidMachineRewarded = nil;
    
    // Unable to load BidMachine ad, fallback to Google Ad manager request or handle error accordingly
}

- (void)didDismissAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    
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

- (void)willPresentScreen:(id<BidMachineAdProtocol> _Nonnull)ad {
    
}

#pragma mark - GADAdMetadataDelegate

- (void)adMetadataDidChange:(nonnull id<GADAdMetadataProvider>)ad {
    BOOL bidMachineWon = [ad.adMetadata[@"AdTitle"] isEqual:@"bidmachine-rewarded"];

    if (bidMachineWon) {
        [BidMachineSdk.shared notifyMediationWin:self.bidMachineRewarded];
        [self switchState:BSStateReady];
    } else {
        [BidMachineSdk.shared notifyMediationLoss:@"" ecpm:0.0 ad:self.bidMachineRewarded];
        self.bidMachineRewarded = nil;

        // BidMachine lost. Fallback to Google native ad or implement your own fallback logic.
        [self switchState:BSStateIdle];
    }
}

@end
