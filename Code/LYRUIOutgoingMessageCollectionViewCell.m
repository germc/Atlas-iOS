//
//  LYRUIOutgoingMessageCollectionViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIOutgoingMessageCollectionViewCell.h"

@implementation LYRUIOutgoingMessageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)shouldDisplayAvatarImage:(BOOL)shouldDisplayAvatarImage
{
    self.avatarImage.hidden = YES;
}

- (void)updateWithParticipant:(id<LYRUIParticipant>)participant
{
    //
}

- (void)updateConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-10]];
    [super updateConstraints];
}

@end
