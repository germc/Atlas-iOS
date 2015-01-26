//
//  LYRUIIncomingMessageCollectionViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIIncomingMessageCollectionViewCell.h"

@interface LYRUIIncomingMessageCollectionViewCell ()

@property (nonatomic) NSLayoutConstraint *bubbleWithAvatarLeftConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithoutAvatarLeftConstraint;

@end

@implementation LYRUIIncomingMessageCollectionViewCell

static CGFloat const LYRAvatarImageDiameter = 30.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.avatarImageView.clipsToBounds = YES;
        self.messageTextColor = [UIColor blackColor];
        self.messageLinkTextColor = LYRUIBlueColor();
        self.bubbleViewColor = LYRUILightGrayColor();
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:LYRAvatarImageDiameter]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.avatarImageView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:0]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:10]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:0]];

        self.bubbleWithAvatarLeftConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                           attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.avatarImageView
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0
                                                                            constant:10];
        [self.contentView addConstraint:self.bubbleWithAvatarLeftConstraint];

        self.bubbleWithoutAvatarLeftConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                              attribute:NSLayoutAttributeLeft
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.avatarImageView
                                                                              attribute:NSLayoutAttributeLeft
                                                                             multiplier:1.0
                                                                               constant:0];
    }
    return self;
}

- (void)shouldDisplayAvatarImage:(BOOL)shouldDisplayAvatarImage
{
    NSArray *constraints = [self.contentView constraints];
    if (shouldDisplayAvatarImage) {
        if ([constraints containsObject:self.bubbleWithAvatarLeftConstraint]) return;
        [self.contentView removeConstraint:self.bubbleWithoutAvatarLeftConstraint];
        [self.contentView addConstraint:self.bubbleWithAvatarLeftConstraint];
    } else {
        if ([constraints containsObject:self.bubbleWithoutAvatarLeftConstraint]) return;
        [self.contentView removeConstraint:self.bubbleWithAvatarLeftConstraint];
        [self.contentView addConstraint:self.bubbleWithoutAvatarLeftConstraint];
    }
    [self setNeedsUpdateConstraints];
}

- (void)updateWithParticipant:(id<LYRUIParticipant>)participant
{
    if (participant) {
        self.avatarImageView.hidden = NO;
        if (participant.avatarImage) {
            [self.avatarImageView setImage:participant.avatarImage];
        } else {
            [self.avatarImageView setInitialsForName:participant.fullName];
        }
    } else {
        self.avatarImageView.hidden = YES;
    }
}

@end
