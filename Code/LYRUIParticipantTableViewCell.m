//
//  LYRUIParticipantTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIParticipantTableViewCell.h"
#import "LYRUIConstants.h"
#import "LYRUIAvatarImageView.h"

@interface LYRUIParticipantTableViewCell ()

@property (nonatomic) UILabel *nameLabel;
@property (nonatomic) LYRUIAvatarImageView *avatarImageView;
@property (nonatomic) id<LYRUIParticipant> participant;
@property (nonatomic) LYRUIParticipantPickerSortType sortType;

@property (nonatomic) NSLayoutConstraint *nameWithAvatarLeftConstraint;
@property (nonatomic) NSLayoutConstraint *nameWithoutAvatarLeftConstraint;

@end

@implementation LYRUIParticipantTableViewCell

static CGFloat const LSSelectionIndicatorSize = 30;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // UIAppearance Defaults
        _boldTitleFont = [UIFont boldSystemFontOfSize:14];
        _titleFont = [UIFont systemFontOfSize:14];
        _titleColor =[UIColor blackColor];
        _subtitleFont = [UIFont systemFontOfSize:12];
        _subtitleColor = [UIColor grayColor];
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.nameLabel = [UILabel new];
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.nameLabel];

        self.avatarImageView = [[LYRUIAvatarImageView alloc] init];
        self.avatarImageView.backgroundColor = LYRUILightGrayColor();
        self.avatarImageView.layer.cornerRadius = LSSelectionIndicatorSize / 2;
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.avatarImageView];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:8]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-8]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10]];
        self.nameWithAvatarLeftConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:15];
        self.nameWithoutAvatarLeftConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:15];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:15]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    // We don't want the default behavior that changes image view backgrounds to transparent while highlighted.
    UIColor *preservedAvatarBackgroundColor = self.avatarImageView.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.avatarImageView.backgroundColor = preservedAvatarBackgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // We don't want the default behavior that changes image view backgrounds to transparent while selected.
    UIColor *preservedAvatarBackgroundColor = self.avatarImageView.backgroundColor;
    [super setSelected:selected animated:animated];
    self.avatarImageView.backgroundColor = preservedAvatarBackgroundColor;
}

- (void)presentParticipant:(id<LYRUIParticipant>)participant withSortType:(LYRUIParticipantPickerSortType)sortType shouldShowAvatarImage:(BOOL)shouldShowAvatarImage
{
    self.accessibilityLabel = [participant fullName];
    self.participant = participant;
    self.sortType = sortType;
    if (shouldShowAvatarImage) {
        [self removeConstraint:self.nameWithoutAvatarLeftConstraint];
        [self addConstraint:self.nameWithAvatarLeftConstraint];
        self.avatarImageView.hidden = NO;
    } else {
        [self removeConstraint:self.nameWithAvatarLeftConstraint];
        [self addConstraint:self.nameWithoutAvatarLeftConstraint];
        self.avatarImageView.hidden = YES;
    }
    [self.avatarImageView setInitialsForName:participant.fullName];
    [self configureNameLabel];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    [self configureNameLabel];
}

- (void)setBoldTitleFont:(UIFont *)boldTitleFont
{
    _boldTitleFont = boldTitleFont;
    [self configureNameLabel];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    [self configureNameLabel];
}

- (void)configureNameLabel
{
    if (self.participant.fullName.length == 0) {
        self.nameLabel.text = nil;
        return;
    }

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.participant.fullName attributes:@{NSFontAttributeName: self.titleFont}];

    NSRange rangeToBold = NSMakeRange(NSNotFound, 0);
    switch (self.sortType) {
        case LYRUIParticipantPickerControllerSortTypeFirst:
            if (self.participant.firstName.length != 0) {
                rangeToBold = [self.participant.fullName rangeOfString:self.participant.firstName];
            }
            break;
        case LYRUIParticipantPickerControllerSortTypeLast:
            if (self.participant.lastName.length != 0) {
                rangeToBold = [self.participant.fullName rangeOfString:self.participant.lastName options:NSBackwardsSearch];
            }
            break;
    }
    if (rangeToBold.location != NSNotFound) {
        [attributedString addAttributes:@{NSFontAttributeName: self.boldTitleFont} range:rangeToBold];
    }

    self.nameLabel.attributedText = attributedString;
    self.nameLabel.textColor = self.titleColor;
}

@end
