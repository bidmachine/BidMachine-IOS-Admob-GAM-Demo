//
//  Base.m
//
//  Copyright © 2019 bidmachine. All rights reserved.
//

#import "Base.h"

@interface Base ()

@property (weak, nonatomic) UIButton *loadButton;
@property (weak, nonatomic) UIButton *showButton;

@end

@implementation Base

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *view = [[NSBundle mainBundle] loadNibNamed:@"BaseView" owner:nil options:nil].firstObject;
    if (view) {
        self.loadButton = [view viewWithTag:1];
        self.showButton = [view viewWithTag:2];
        [self switchState:BSStateIdle];
        
        [self.view addSubview:view];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [NSLayoutConstraint activateConstraints:@[[view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
                                                  [view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
                                                  [view.safeAreaLayoutGuide.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
                                                  [view.heightAnchor constraintEqualToConstant:100]]];
    }
}

- (void)loadAd:(id)sender {
    // no-op
}

- (void)showAd:(id)sender {
    // no-op
}

@end

@implementation Base (Interface)

- (void)switchState:(BSState)state {
    switch (state) {
        case BSStateIdle: {
            self.loadButton.enabled = YES;
            self.showButton.enabled = NO;
        } break;
        case BSStateLoading: {
            self.loadButton.enabled = NO;
            self.showButton.enabled = NO;
        } break;
        case BSStateReady: {
            self.loadButton.enabled = NO;
            self.showButton.enabled = YES;
        } break;
        default:
            break;
    }
}

@end

@implementation Base (Rounding)

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

@end
