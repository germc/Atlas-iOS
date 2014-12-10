//
//  LYRUIIncomingMessageCollectionViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIIncomingMessageCollectionViewCell.h"

@interface LYRUIIncomingMessageCollectionViewCell ()

@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *color;

@property (nonatomic) NSLayoutConstraint *bubbleWithAvatarLeftConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithoutAvatarLeftConstraint;

@end

@implementation LYRUIIncomingMessageCollectionViewCell

static CGFloat const LYRAvatarImageDiameter = 30.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.avatarImage.layer.cornerRadius = (LYRAvatarImageDiameter / 2);
        self.avatarImage.clipsToBounds = YES;
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:LYRAvatarImageDiameter]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.avatarImage
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:0]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1.0
                                                                      constant:10]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0
                                                                      constant:0]];

        self.bubbleWithAvatarLeftConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                           attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.avatarImage
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0
                                                                            constant:10];
        [self.contentView addConstraint:self.bubbleWithAvatarLeftConstraint];

        self.bubbleWithoutAvatarLeftConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                              attribute:NSLayoutAttributeLeft
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.avatarImage
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
        self.avatarImage.hidden = NO;
        if (participant.avatarImage) {
            [self.avatarImage setImage:participant.avatarImage];
        } else {
            [self.avatarImage setInitialsForName:participant.fullName];
        }
    } else {
        self.avatarImage.hidden = YES;
    }
}

@end
