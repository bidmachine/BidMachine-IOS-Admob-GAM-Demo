//
//  Base.h
//
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BSState) {
    BSStateIdle = 0,
    BSStateLoading,
    BSStateReady
};

@interface Base : UIViewController

- (IBAction)loadAd:(id)sender;
- (IBAction)showAd:(id)sender;

@end

@interface Base (Interface)

- (void)switchState:(BSState)state;

@end

NS_ASSUME_NONNULL_END
