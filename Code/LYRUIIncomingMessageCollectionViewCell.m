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
@property (nonatomic) CGFloat imageViewDiameter;
@property (nonatomic) BOOL avatarConstraintsAreSet;

@property (nonatomic) NSLayoutConstraint *avatarImageWidthConstraint;
@property (nonatomic) NSLayoutConstraint *avatarImageHeightConstraint;
@property (nonatomic) NSLayoutConstraint *avatarImageBottomConstraint;
@property (nonatomic) NSLayoutConstraint *avatarImageLeftConstraint;

@end

@implementation LYRUIIncomingMessageCollectionViewCell

static CGFloat const LYRAvatarImageDiameter = 30.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.avatarImage.layer.cornerRadius = (LYRAvatarImageDiameter / 2);
        self.avatarConstraintsAreSet = NO;
        
        [self updateAvatarImageConstraints];
        
    }
    return self;
}

- (void)shouldDisplayAvatarImage:(BOOL)shouldDisplayAvatarImage
{
    if (shouldDisplayAvatarImage) {
        self.avatarImageLeftConstraint.constant = 10;
        self.avatarImageWidthConstraint.constant = LYRAvatarImageDiameter;
        self.avatarImageHeightConstraint.constant = LYRAvatarImageDiameter;
    } else {
        self.avatarImageLeftConstraint.constant = 0;
        self.avatarImageWidthConstraint.constant = 0;
        self.avatarImageHeightConstraint.constant = 0;
    }
}

- (void)updateWithParticipant:(id<LYRUIParticipant>)participant
{
    if (participant) {
        self.avatarImage.alpha = 1.0f;
        self.avatarImage.clipsToBounds = YES;
        if (participant.avatarImage) {
            [self.avatarImage setImage:participant.avatarImage];
        } else {
            [self.avatarImage setInitialsForName:participant.fullName];
        }
    } else {
        self.avatarImage.alpha = 0.0f;
    }
}

- (void)updateAvatarImageConstraints
{
    //***************Avatar Image Constraints***************//
    self.avatarImageWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:self.imageViewDiameter];
    
    self.avatarImageHeightConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1.0
                                                                     constant:self.imageViewDiameter];
    
    self.avatarImageBottomConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                    attribute:NSLayoutAttributeBottom
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1.0
                                                                     constant:0];
    
    self.avatarImageLeftConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:0];
    // Add avatar constraints
    [self.contentView addConstraint:self.avatarImageWidthConstraint];
    [self.contentView addConstraint:self.avatarImageHeightConstraint];
    [self.contentView addConstraint:self.avatarImageBottomConstraint];
    [self.contentView addConstraint:self.avatarImageLeftConstraint];

    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImage
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:10]];
}

@end
