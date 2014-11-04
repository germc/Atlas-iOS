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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        self.avatarImageView = [[LYRUIAvatarImageView alloc] init];
        [self.avatarImageView setInitialViewBackgroundColor:LSLighGrayColor()];
        self.avatarImageView.layer.cornerRadius = LSSelectionIndicatorSize / 2;
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.avatarImageView.alpha = 0.0f;
        [self.contentView addSubview:self.avatarImageView];
        [self updateConstraints];
        
    }
    return self;
}

- (void)updateConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

- (void)presentParticipant:(id<LYRUIParticipant>)participant
{
    self.accessibilityLabel = [participant fullName];
    self.textLabel.text = participant.fullName;
    [self.avatarImageView setInitialsForName:participant.fullName];
}

- (void)shouldShowAvatarImage:(BOOL)shouldShowAvatarImage
{
    if (shouldShowAvatarImage) {
        self.imageView.backgroundColor = [UIColor redColor];
        self.imageView.image = [self imageWithColor:[UIColor whiteColor]];
        [self.imageView addSubview:self.avatarImageView];
        self.avatarImageView.alpha = 1.0f;
    }
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

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.textLabel.font = titleFont;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.textLabel.textColor = titleColor;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 30, 30);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
