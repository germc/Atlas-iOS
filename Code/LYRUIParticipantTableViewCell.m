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
@property (nonatomic) LYRUIParticipantPickerSortType sortType;

@end

@implementation LYRUIParticipantTableViewCell

static CGFloat const LSSelectionIndicatorSize = 30;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        // UIAppearance Defaults
        _boldTitleFont = [UIFont boldSystemFontOfSize:14];
        _titleFont = [UIFont systemFontOfSize:14];
        _titleColor =[UIColor blackColor];
        _subtitleFont = [UIFont systemFontOfSize:12];
        _subtitleColor = [UIColor grayColor];
        
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        self.avatarImageView = [[LYRUIAvatarImageView alloc] init];
        self.avatarImageView.backgroundColor = LYRUILightGrayColor();
        self.avatarImageView.layer.cornerRadius = LSSelectionIndicatorSize / 2;
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.avatarImageView.alpha = 0.0f;
        [self.contentView addSubview:self.avatarImageView];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.imageView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }
    return self;
}

- (void)presentParticipant:(id<LYRUIParticipant>)participant
{
    self.accessibilityLabel = [participant fullName];
    self.textLabel.text = participant.fullName;
    [self.avatarImageView setInitialsForName:participant.fullName];
}

- (void)updateWithSortType:(LYRUIParticipantPickerSortType)sortType
{
    _sortType = sortType;
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

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
}

- (void)setBoldTitleFont:(UIFont *)boldTitleFont
{
    _boldTitleFont = boldTitleFont;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.titleFont) {
        return;
    }
    
    switch (self.sortType) {
            
        case LYRUIParticipantPickerControllerSortTypeFirst: {
            NSMutableAttributedString *attributedString = [self.textLabel.attributedText mutableCopy];
            NSRange rangeOfString = [self.textLabel.text rangeOfString:@" "];
            NSString *regularString = [self.textLabel.text substringFromIndex:rangeOfString.location];
            NSRange rangeToBold = NSMakeRange(0, rangeOfString.location);
            [attributedString addAttributes:@{NSFontAttributeName: self.boldTitleFont} range:rangeToBold];
            [attributedString addAttributes:@{NSFontAttributeName: self.titleFont} range:NSMakeRange(rangeOfString.location, regularString.length)];
            self.textLabel.attributedText = attributedString;
        }
            break;
            
        case LYRUIParticipantPickerControllerSortTypeLast: {
            NSMutableAttributedString *attributedString = [self.textLabel.attributedText mutableCopy];
            NSRange rangeOfString = [self.textLabel.text rangeOfString:@" "];
            NSString *stringToBold = [self.textLabel.text substringFromIndex:rangeOfString.location];
            NSRange rangeToBold = NSMakeRange(rangeOfString.location, stringToBold.length);
            [attributedString addAttributes:@{NSFontAttributeName: self.titleFont} range:NSMakeRange(0, rangeOfString.location)];
            [attributedString addAttributes:@{NSFontAttributeName: self.boldTitleFont} range:rangeToBold];
            self.textLabel.attributedText = attributedString;
        }
            break;
        default:
            break;
    }
    self.textLabel.textColor = self.titleColor;
    [self.textLabel sizeToFit];
}

@end
