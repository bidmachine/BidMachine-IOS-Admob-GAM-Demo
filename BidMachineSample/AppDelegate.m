//
//  AppDelegate.m
//
//  Copyright © 2019 BidMachine. All rights reserved.
//

#import "AppDelegate.h"

#define APP_ID         "YOUR_APP_ID"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     [self startBidMachine:^{
         
     }];
    
    return YES;
}

- (void)startBidMachine:(void(^)(void))completion {
    BDMSdkConfiguration *config = [BDMSdkConfiguration new];
    config.targeting = BDMTargeting.new;
    config.targeting.storeId = @"12345";
    config.testMode = YES;
    [BDMSdk.sharedSdk startSessionWithSellerID:@"5"
                                 configuration:config
                                    completion:completion];
}

@end
