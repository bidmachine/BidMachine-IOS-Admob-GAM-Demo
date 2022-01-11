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

$BDMVersion = '~> 1.8.0.0'
$GAMVersion = '~> 8.13.0'

def bidmachine
  pod 'BDMIABAdapter', $BDMVersion
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

    BDMSdkConfiguration *config = [BDMSdkConfiguration new];
    config.testMode = YES;

    config.targeting = BDMTargeting.new;
    config.targeting.storeURL = [NSURL URLWithString:@"https://storeUrl"];
    config.targeting.storeId = @"12345";

    [BDMSdk.sharedSdk startSessionWithSellerID:@"5"
                                 configuration:config
                                    completion:nil];
```


### Banner implementation

First you need to load ad request from BidMachine

> **NOTE:_** MREC load requires a different size 

```objc

self.bannerRequest = [BDMBannerRequest new];
//    self.bannerRequest.adSize = BDMBannerAdSize320x50;
//    self.bannerRequest.adSize = BDMBannerAdSize300x250;
[self.bannerRequest performWithDelegate:self];

```

After loading the request, you need to load GAM ad with BidMachine request parameters.
> **_WARNING:_** Don't forget to install appEventDelegate


```objc

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

```

If the GAM Ad loads successfully, you need to listen events delegate. 
If the event name matches the registered event for BidMachine, then you need to load the ad via BidMachine. If it does not match, then show through GAM

```objc

- (void)bannerViewDidReceiveAd:(nonnull GADBannerView *)bannerView {
    // WAIT AD EVENT DELEGATE
}

- (void)bannerView:(nonnull GADBannerView *)bannerVie didFailToReceiveAdWithError:(nonnull NSError *)error {
    // FAIL LOAD
}

- (void)adView:(nonnull GADBannerView *)banner didReceiveAppEvent:(nonnull NSString *)name withInfo:(nullable NSString *)info {
    if ([name isEqualToString:@"bidmachine-banner"]) {
        self.banner = [BDMBannerView new];
        self.banner.delegate = self;
        [self.banner populateWithRequest:self.bannerRequest];
    } else {
        // SHOW GADBannerView
    }
}

```

For example:

```objc

#pragma mark - BDMBannerDelegate

- (void)bannerViewReadyToPresent:(nonnull BDMBannerView *)bannerView {
    [bannerView removeFromSuperview];
    [self.view addSubview: bannerView];
}

```

### Interstitial implementation

First you need to load ad request from BidMachine

```objc

self.interstitialRequest = [BDMInterstitialRequest new];
[self.interstitialRequest performWithDelegate:self];

```

After loading the request, you need to load GAM with BidMachine request parameters.
> **_WARNING:_** Don't forget to install appEventDelegate


```objc

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
            // FAIL LOAD
        } else {
            // WAIT AD EVENT DELEGATE
            weakSelf.adMobInterstitial = interstitialAd;
            weakSelf.adMobInterstitial.appEventDelegate = weakSelf;
        }
    }];
}

```

If the GAM Ad loads successfully, you need to listen events delegate. 
If the event name matches the registered event for BidMachine, then you need to load the ad via BidMachine. If it does not match, then show through GAM

```objc

#pragma mark - GADAppEventDelegate

- (void)interstitialAd:(nonnull GADInterstitialAd *)interstitialAd
    didReceiveAppEvent:(nonnull NSString *)name
              withInfo:(nullable NSString *)info {
    
    if ([name isEqualToString:@"bidmachine-interstitial"]) {
        self.interstitial = [BDMInterstitial new];
        self.interstitial.delegate = self;
        [self.interstitial populateWithRequest:self.interstitialRequest];
    } else {
        // SHOW GADInterstitialAd
    }
}

```

For example:

```objc

#pragma mark - BDMInterstitialDelegate

- (void)interstitialReadyToPresent:(nonnull BDMInterstitial *)interstitial {
    [interstitial presentFromRootViewController:self];
}

```

### Rewarded implementation

First you need to load ad request from BidMachine

```objc

self.rewardedRequest = [BDMRewardedRequest new];
[self.rewardedRequest performWithDelegate:self];

```

After loading the request, you need to load GAM ad with BidMachine request parameters.
> **_WARNING:_** Don't forget to install appEventDelegate


```objc

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
            // FAIL LOAD
        } else {
            // WAIT AD EVENT DELEGATE
            weakSelf.adMobRewarded = rewardedAd;
            weakSelf.adMobRewarded.adMetadataDelegate = weakSelf;
        }
    }];
}

```

If the GAM Ad loads successfully, you need to listen events delegate. 
If the event name matches the registered event for BidMachine, then you need to load the ad via BidMachine. If it does not match, then show through GAM

```objc

- (void)adMetadataDidChange:(nonnull id<GADAdMetadataProvider>)ad {
    if (![ad.adMetadata[@"AdTitle"] isEqual:@"bidmachine-rewarded"]) {
        // SHOW GADRewardedAd
    } else {
        self.rewarded = [BDMRewarded new];
        self.rewarded.delegate = self;
        [self.rewarded populateWithRequest:self.rewardedRequest];
    }
}

```

For example:

```objc

#pragma mark - BDMRewardedDelegate

- (void)rewardedReadyToPresent:(nonnull BDMRewarded *)rewarded {
    [rewarded presentFromRootViewController:self];
}

```
