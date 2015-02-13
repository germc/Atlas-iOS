//
//  LYRUIConversationCollectionViewMoreMessagesHeader.m
//  Atlas
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

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)  {
        [self lyr_commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (void)lyr_commonInit
{
    _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [_activityIndicatorView startAnimating];
    [self addSubview:_activityIndicatorView];
    
    [self configureActivityIndicatorViewConstraints];
}

- (void)configureActivityIndicatorViewConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_activityIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

@end
