//
//  LYRUIConversationCollectionViewMoreMessagesHeader.m
//  LayerUIKit
//
//  Created by Ben Blakley on 1/15/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationCollectionViewMoreMessagesHeader.h"

@interface LYRUIConversationCollectionViewMoreMessagesHeader ()

@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation LYRUIConversationCollectionViewMoreMessagesHeader

NSString *const LYRUIMoreMessagesHeaderIdentifier = @"LYRUIMoreMessagesHeaderIdentifier";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [_activityIndicatorView startAnimating];
        [self addSubview:_activityIndicatorView];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }
    return self;
}

@end
