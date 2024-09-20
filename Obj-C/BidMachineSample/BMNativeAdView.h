//
//  BMNativeAdView.h
//  BidMachineSample
//
//  Created by Dzmitry on 20/09/2024.
//  Copyright © 2024 Appodeal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BidMachine/BidMachine.h"

@interface BMNativeAdView : UIView<BidMachineNativeAdRendering>

@property (nonatomic, strong, readonly) UILabel * _Nullable titleLabel;
@property (nonatomic, strong, readonly) UILabel * _Nullable callToActionLabel;
@property (nonatomic, strong, readonly) UILabel * _Nullable descriptionLabel;
@property (nonatomic, strong, readonly) UIImageView * _Nullable iconView;
@property (nonatomic, strong, readonly) UIView * _Nullable mediaContainerView;
@property (nonatomic, strong, readonly) UILabel * _Nullable adChoiceView;

@end
