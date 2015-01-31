//
//  LYRUIOutgoingMessageCollectionViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIOutgoingMessageCollectionViewCell.h"

@implementation LYRUIOutgoingMessageCollectionViewCell

+ (void)initialize
{
    LYRUIOutgoingMessageCollectionViewCell *proxy = [self appearance];
    proxy.bubbleViewColor = LYRUIBlueColor();
    proxy.messageTextColor = [UIColor whiteColor];
    proxy.messageLinkTextColor = [UIColor whiteColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.avatarImageView.hidden = YES;
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView  attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10]];
    }
    return self;
}

@end
