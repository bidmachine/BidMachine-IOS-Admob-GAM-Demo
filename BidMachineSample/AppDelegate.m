//
//  AppDelegate.m
//
//  Copyright © 2019 BidMachine. All rights reserved.
//
#import "AppDelegate.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ @"" ];
    
    [BidMachineSdk.shared populate:^(id<BidMachineInfoBuilderProtocol> builder) {
        [builder withTestMode:YES];
        [builder withLoggingMode:YES];
    }];
    
    [BidMachineSdk.shared.targetingInfo populate:^(id<BidMachineTargetingInfoBuilderProtocol> builder) {
        [builder withStoreId:@"12345"];
    }];
    
    [BidMachineSdk.shared initializeSdk:@"154"];
    
    return YES;
}

@end
