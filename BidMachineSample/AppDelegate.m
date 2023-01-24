//
//  AppDelegate.m
//
//  Copyright © 2019 BidMachine. All rights reserved.
//

#import "AppDelegate.h"

#define APP_ID  "YOUR_APP_ID"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ GADSimulatorID ];
    
    [BidMachineSdk.shared populate:^(id<BidMachineInfoBuilderProtocol> builder) {
        [builder withTestMode:YES];
    }];
    
    [BidMachineSdk.shared.targetingInfo populate:^(id<BidMachineTargetingInfoBuilderProtocol> builder) {
        [builder withStoreId:@"12345"];
    }];
    
    [BidMachineSdk.shared initializeSdk:@"5"];
    
    return YES;
}

@end
