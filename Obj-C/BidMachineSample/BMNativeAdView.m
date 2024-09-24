//
//  BMNativeAdView.m
//  BidMachineSample
//
//  Created by Dzmitry on 20/09/2024.
//  Copyright © 2024 Appodeal. All rights reserved.
//

#import "BMNativeAdView.h"

@implementation BMNativeAdView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [UILabel new];
        _callToActionLabel = [UILabel new];
        _descriptionLabel = [UILabel new];
        _iconView = [UIImageView new];
        _mediaContainerView = [UIView new];
        _adChoiceView = [UILabel new];

        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self.adChoiceView setText:@"Ad"];
    [self.adChoiceView setTextColor:UIColor.lightGrayColor];

    [self addSubview:self.titleLabel];
    [self addSubview:self.callToActionLabel];
    [self addSubview:self.descriptionLabel];
    [self addSubview:self.iconView];
    [self addSubview:self.mediaContainerView];
    [self addSubview:self.adChoiceView];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.mediaContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.callToActionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.adChoiceView.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [self.iconView.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
        [self.iconView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [self.iconView.widthAnchor constraintEqualToConstant:70],
        [self.iconView.heightAnchor constraintEqualToConstant:70],

        [self.titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.iconView.trailingAnchor constant:10],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
        [self.titleLabel.heightAnchor constraintEqualToConstant:30],
   
        [self.descriptionLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:5],
        [self.descriptionLabel.leadingAnchor constraintEqualToAnchor:self.iconView.trailingAnchor constant:10],
        [self.descriptionLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
        [self.descriptionLabel.heightAnchor constraintEqualToConstant:30],
   
        [self.mediaContainerView.topAnchor constraintEqualToAnchor:self.descriptionLabel.bottomAnchor constant:10],
        [self.mediaContainerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [self.mediaContainerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
        [self.mediaContainerView.heightAnchor constraintEqualToAnchor:self.mediaContainerView.widthAnchor multiplier:(9.0/16.0)],
  
        [self.callToActionLabel.topAnchor constraintEqualToAnchor:self.mediaContainerView.bottomAnchor constant:10],
        [self.callToActionLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:10],
        [self.callToActionLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-10],
        [self.callToActionLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10],
        [self.callToActionLabel.heightAnchor constraintEqualToConstant:70],

        [self.adChoiceView.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
        [self.adChoiceView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-10]
    ]];
}

@end
