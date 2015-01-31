//
//  LYRUIIncomingMessageCollectionViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIIncomingMessageCollectionViewCell.h"

@interface LYRUIIncomingMessageCollectionViewCell ()

@property (nonatomic) NSLayoutConstraint *bubbleViewLeftConstraint;
@property (nonatomic) NSLayoutConstraint *avatarImageLeftConstraint;

@end

@implementation LYRUIIncomingMessageCollectionViewCell

+ (void)initialize
{
    LYRUIIncomingMessageCollectionViewCell *proxy = [self appearance];
    proxy.bubbleViewColor = LYRUILightGrayColor();
    proxy.messageLinkTextColor = LYRUIBlueColor();
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        self.avatarImageLeftConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        [self.contentView addConstraint:self.avatarImageLeftConstraint];
        self.bubbleViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        [self.contentView addConstraint:self.bubbleViewLeftConstraint];
    }
    return self;
}

- (void)shouldDisplayAvatarImage:(BOOL)shouldDisplayAvatarImage
{
    self.bubbleViewLeftConstraint.constant = shouldDisplayAvatarImage ? 0 : 0;
    self.avatarImageLeftConstraint.constant = shouldDisplayAvatarImage ? 0 : 0;
    [self setNeedsUpdateConstraints];
}

- (void)updateWithParticipant:(id<LYRUIParticipant>)participant
{
    if (participant) {
        self.avatarImageView.hidden = NO;
        if (participant.avatarImage) {
            [self.avatarImageView setImage:participant.avatarImage];
        } else {
            [self.avatarImageView setInitialsForFullName:participant.fullName];
        }
    } else {
        self.avatarImageView.hidden = YES;
    }
}

- (void)layoutSubviews
{
    
}

@end
