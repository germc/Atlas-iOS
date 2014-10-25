//
//  LYRUIParticipantTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIParticipantTableViewCell.h"
#import "LYRUIConstants.h"
#import "LYRUISelectionIndicator.h"
#import "LYRUIAvatarImageView.h"

@interface LYRUIParticipantTableViewCell ()

@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) UIControl *selectionIndicator;
@property (nonatomic) LYRUIAvatarImageView *avatarImageView;
@property (nonatomic) BOOL isSelected;

@end

@implementation LYRUIParticipantTableViewCell

static CGFloat const LSSelectionIndicatorSize = 30;
static CGFloat const LSSelectionIndicatorRightMargin = -20;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.nameLabel];
        
        self.selectionIndicator = [LYRUISelectionIndicator initWithDiameter:LSSelectionIndicatorSize];
        self.selectionIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.selectionIndicator];
        
        self.avatarImageView = [[LYRUIAvatarImageView alloc] init];
        [self.avatarImageView setInitialViewBackgroundColor:LSLighGrayColor()];
        self.avatarImageView.layer.cornerRadius = LSSelectionIndicatorSize / 2;
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.avatarImageView.alpha = 0.0f;
        [self.contentView addSubview:self.avatarImageView];
        
        [self updateSelectionIndicatorConstraints];
    }
    return self;
}

- (void)presentParticipant:(id<LYRUIParticipant>)participant
{
    self.accessibilityLabel = [participant fullName];
    
    self.nameLabel.text = [participant fullName];
    [self.nameLabel sizeToFit];

    [self.avatarImageView setInitialsForName:participant.fullName];
    [self updateConstraints];
}

- (void)shouldDisplaySelectionIndicator:(BOOL)shouldDisplaySelectionIndicator
{
    if (shouldDisplaySelectionIndicator) {
        self.selectionIndicator.alpha = 1.0;
    } else {
        self.selectionIndicator.alpha = 0.0;
    }
}

- (void)shouldShowAvatarImage:(BOOL)shouldShowAvatarImage
{
    if (shouldShowAvatarImage) {
        [self updateAvatarImageConstraints];
        self.avatarImageView.alpha = 1.0f;
    }
}

- (void)updateSelectionIndicatorConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:16]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionIndicator
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSSelectionIndicatorSize]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionIndicator
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSSelectionIndicatorSize]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectionIndicator
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:LSSelectionIndicatorRightMargin]];
    
    [super updateConstraints];
}


- (void)updateAvatarImageConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSSelectionIndicatorSize]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LSSelectionIndicatorSize]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:10]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self.selectionIndicator setHighlighted:selected];
    if (self.selectionIndicator.highlighted) {
        self.selectionIndicator.accessibilityLabel = [NSString stringWithFormat:@"%@ selected", self.accessibilityLabel];
    } else {
        self.selectionIndicator.accessibilityLabel = @"";
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // Configure UI Appearance Proxy
    if (self.nameLabel.font != self.titleFont) {
        self.nameLabel.font = self.titleFont;
    }
    if (self.nameLabel.textColor != self.titleColor) {
        self.nameLabel.textColor = self.titleColor;
    }
}

@end
