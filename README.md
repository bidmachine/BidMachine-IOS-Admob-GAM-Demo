![BidMachine iOS](https://appodeal-ios.s3-us-west-1.amazonaws.com/docs/bidmachine.png)

# BidMachine-IOS-GAM-Demo

- [Getting Started](#user-content-getting-started)
- [Initialize sdk](#user-content-initialize-sdk)
- [Banner implementation](#user-content-banner-implementation)
- [Interstitial implementation](#user-content-interstitial-implementation)
- [Rewarded implementation](#user-content-rewarded-implementation)

## Getting Started

##### Add following lines into your project Podfile

```ruby

$BDMVersion = '~> 2.0.0.0'
$GAMVersion = '~> 9.14.0'

def bidmachine
  pod 'BidMachine', $BDMVersion
end

def google
  pod 'Google-Mobile-Ads-SDK', $GAMVersion
end

target 'Sample' do
  bidmachine
  google
end
```

### Initialize sdk

> **_NOTE:_** **storeURL** and **storeId** - are required parameters


```objc

   [BidMachineSdk.shared populate:^(id<BidMachineInfoBuilderProtocol> builder) {
        [builder withTestMode:YES];
    }];
    
    [BidMachineSdk.shared.targetingInfo populate:^(id<BidMachineTargetingInfoBuilderProtocol> builder) {
        [builder withStoreId:@"12345"];
    }];
    
    [BidMachineSdk.shared initializeSdk:@"5"];
```


### Banner implementation

First you need to load ad from BidMachine

> **NOTE:_** [MREC load requires a different size](https://docs.bidmachine.io/docs/ad-request#create-request-configuration)

```objc

    __weak typeof(self) weakSelf = self;
    [BidMachineSdk.shared banner:nil :^(BidMachineBanner *banner, NSError *error) {
        if (error) {
            return;
        }
        weakSelf.bidmachineBanner = banner;
        weakSelf.bidmachineBanner.controller = weakSelf;
        weakSelf.bidmachineBanner.delegate = weakSelf;
        [weakSelf.bidmachineBanner loadAd];
    }];

```

After loading the ad, you need to load GAM ad with BidMachine ad parameters.
> **_WARNING:_** Don't forget to install appEventDelegate

> **_WARNING:_** GAM request params should contains price with x.xx format


```objc

- (NSNumberFormatter *)formatter {
    static NSNumberFormatter *roundingFormater = nil;
    if (!roundingFormater) {
        roundingFormater = [NSNumberFormatter new];
        roundingFormater.numberStyle = NSNumberFormatterDecimalStyle;
        roundingFormater.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        roundingFormater.roundingMode = NSNumberFormatterRoundCeiling;
        roundingFormater.positiveFormat = @"0.00";
    }
    return roundingFormater;
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

```

If the GAM Ad loads successfully, you need to listen events delegate. 
If the event name matches the registered event for BidMachine, then you need to present the ad via BidMachine. If it does not match, then show through GAM

```objc

- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView {
    // WAIT AD EVENT DELEGATE
}

- (void)bannerView:(nonnull GADBannerView *)bannerVie didFailToReceiveAdWithError:(nonnull NSError *)error {
    // FAIL LOAD
}

- (void)adView:(nonnull GADBannerView *)banner didReceiveAppEvent:(nonnull NSString *)name withInfo:(nullable NSString *)info {
    if ([name isEqualToString:@"bidmachine-banner"]) {
        // SHOW BidMachine
    } else {
        // SHOW GADBannerView
    }
}

```

### Interstitial implementation

First you need to load ad from BidMachine

```objc

    __weak typeof(self) weakSelf = self;
    [BidMachineSdk.shared interstitial:nil :^(BidMachineInterstitial *interstitial, NSError *error) {
        if (error) {
            return;
        }
        weakSelf.bidmachineInterstitial = interstitial;
        weakSelf.bidmachineInterstitial.controller = weakSelf;
        weakSelf.bidmachineInterstitial.delegate = weakSelf;
        [weakSelf.bidmachineInterstitial loadAd];
    }];

```

After loading the ad, you need to load GAM with BidMachine ad parameters.
> **_WARNING:_** Don't forget to install appEventDelegate

> **_WARNING:_** GAM request params should contains price with x.xx format


```objc

- (NSNumberFormatter *)formatter {
    static NSNumberFormatter *roundingFormater = nil;
    if (!roundingFormater) {
        roundingFormater = [NSNumberFormatter new];
        roundingFormater.numberStyle = NSNumberFormatterDecimalStyle;
        roundingFormater.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        roundingFormater.roundingMode = NSNumberFormatterRoundCeiling;
        roundingFormater.positiveFormat = @"0.00";
    }
    return roundingFormater;
}

#pragma mark - BidMachineAdDelegate

- (void)didLoadAd:(id<BidMachineAdProtocol> _Nonnull)ad {
    GAMRequest *googleRequest = [GAMRequest request];
    googleRequest.customTargeting = @{
        @"bm_pf" : [self.formatter stringFromNumber:@(ad.auctionInfo.price)]
    };
    
    __weak typeof(self) weakSelf = self;
    [GAMInterstitialAd loadWithAdManagerAdUnitID:@UNIT_ID
                                         request:googleRequest
                               completionHandler:^(GAMInterstitialAd * _Nullable interstitialAd,
                                                   NSError * _Nullable error) {
        if (error) {
            // FAIL LOAD
        } else {
            // WAIT AD EVENT DELEGATE
            weakSelf.googleInterstitial = interstitialAd;
            weakSelf.googleInterstitial.appEventDelegate = weakSelf;
        }
    }];
}

```

If the GAM Ad loads successfully, you need to listen events delegate. 
If the event name matches the registered event for BidMachine, then you need to show the ad via BidMachine. If it does not match, then show through GAM

```objc

#pragma mark - GADAppEventDelegate

- (void)interstitialAd:(nonnull GADInterstitialAd *)interstitialAd
    didReceiveAppEvent:(nonnull NSString *)name
              withInfo:(nullable NSString *)info {
    
    if ([name isEqualToString:@"bidmachine-interstitial"]) {
         // SHOW BidMachine
    } else {
        // SHOW GADInterstitialAd
    }
}

```

### Rewarded implementation

First you need to load ad from BidMachine

```objc

    __weak typeof(self) weakSelf = self;
    [BidMachineSdk.shared rewarded:nil :^(BidMachineRewarded *rewarded, NSError *error) {
        if (error) {
            return;
        }
        weakSelf.bidMachineRewarded = rewarded;
        weakSelf.bidMachineRewarded.controller = weakSelf;
        weakSelf.bidMachineRewarded.delegate = weakSelf;
        [weakSelf.bidMachineRewarded loadAd];
    }];

```

After loading the request, you need to load GAM ad with BidMachine request parameters.
> **_WARNING:_** Don't forget to install appEventDelegate

> **_WARNING:_** GAM request params should contains price with x.xx format


```objc

- (NSNumberFormatter *)formatter {
    static NSNumberFormatter *roundingFormater = nil;
    if (!roundingFormater) {
        roundingFormater = [NSNumberFormatter new];
        roundingFormater.numberStyle = NSNumberFormatterDecimalStyle;
        roundingFormater.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        roundingFormater.roundingMode = NSNumberFormatterRoundCeiling;
        roundingFormater.positiveFormat = @"0.00";
    }
    return roundingFormater;
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
             // FAIL LOAD
        } else {
            // WAIT AD EVENT DELEGATE
            weakSelf.googleRewarded = rewardedAd;
            weakSelf.googleRewarded.adMetadataDelegate = weakSelf;
        }
    }];
}

```

If the GAM Ad loads successfully, you need to listen events delegate. 
If the event name matches the registered event for BidMachine, then you need to show the ad via BidMachine. If it does not match, then show through GAM

```objc

- (void)adMetadataDidChange:(nonnull id<GADAdMetadataProvider>)ad {
    if (![ad.adMetadata[@"AdTitle"] isEqual:@"bidmachine-rewarded"]) {
        // SHOW GADRewardedAd
    } else {
        // SHOW BidMachine
    }
}

```
