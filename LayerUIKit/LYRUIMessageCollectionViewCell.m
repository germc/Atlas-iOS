//
//  LYRUIMessageCollectionViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIMessageCollectionViewCell.h"
#import "LYRUIUtilities.h"
#import "LYRUIIncomingMessageCollectionViewCell.h"
#import "LYRUIOutgoingMessageCollectionViewCell.h"

@interface LYRUIMessageCollectionViewCell ()

@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) CGFloat bubbleViewWidth;
@property (nonatomic) CGFloat imageViewDiameter;

@property (nonatomic) NSLayoutConstraint *avatarImageWidthConstraint;
@property (nonatomic) NSLayoutConstraint *avatarImageHeightConstraint;
@property (nonatomic) NSLayoutConstraint *avatarImageBottomConstraint;

@property (nonatomic) NSLayoutConstraint *bubbleViewHeightConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleViewTopConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleViewWidthConstraint;

@property (nonatomic) NSLayoutConstraint *dateLabelLeftConstraint;
@property (nonatomic) NSLayoutConstraint *dateLabelCenterYConstraint;

@end

@implementation LYRUIMessageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.bubbleView = [[LYRUIMessageBubbleView alloc] init];
        self.bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.bubbleView];
        
        self.avatarImage = [[UIImageView alloc] init];
        self.avatarImage.backgroundColor = LSGrayColor();
        self.avatarImage.layer.cornerRadius = 10;
        self.avatarImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.avatarImage];
       
        self.dateLabel  = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont systemFontOfSize:10];
        self.dateLabel.textColor = [UIColor lightGrayColor];
        self.dateLabel.text = @"10:36AM";
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.dateLabel sizeToFit];
        [self.contentView addSubview:self.dateLabel];
        
        if ([self isKindOfClass:[LYRUIIncomingMessageCollectionViewCell class]]) {
            self.imageViewDiameter = 24;
        } else {
            self.imageViewDiameter = 0;
        }
    }
    [self updateMessageCellConstraints];
    return self;
}

- (void)setMessageTextColor:(UIColor *)messageTextColor
{
    self.bubbleView.bubbleTextView.textColor = messageTextColor;
}

- (void)setMessageTextFont:(UIFont *)messageTextFont
{
    self.bubbleView.bubbleTextView.font = messageTextFont;
}

- (void)setBubbleViewColor:(UIColor *)bubbleViewColor
{
    self.bubbleView.backgroundColor = bubbleViewColor;
}

- (void)presentMessagePart:(LYRMessagePart *)messagePart
{
    if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
        NSString *text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
        [self.bubbleView updateWithText:text];
        self.accessibilityLabel = [NSString stringWithFormat:@"Message: %@", text];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG]) {
        UIImage *image = [UIImage imageWithData:messagePart.data];
        [self.bubbleView updateWithImage:image];
        self.accessibilityLabel = [NSString stringWithFormat:@"Message: Photo"];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
        //
    }
}

- (void)updateBubbleViewWidth:(CGFloat)width
{
    if ([[self.contentView constraints] containsObject:self.bubbleViewWidthConstraint]) {
        [self.contentView removeConstraint:self.bubbleViewWidthConstraint];
    }
    self.bubbleViewWidth = width + 25; //Adding 24px for bubble view horizontal padding + 1px for extra coverage
    self.bubbleViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:self.bubbleViewWidth];
     [self.contentView addConstraint:self.bubbleViewWidthConstraint];
}

- (void)updateMessageCellConstraints
{
    //***************Avatar Image Constraints***************//
    self.avatarImageBottomConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImage
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
    
    self.avatarImageWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0
                                                                    constant:0];
    //***************Bubble View Constraints***************//
    self.bubbleViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:1.0
                                                                     constant:0];
    
    self.bubbleViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.contentView
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0];
    //***************Date Label Constraints***************//
    self.dateLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.contentView
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1.0
                                                                 constant:2];
    
    self.dateLabelCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0];
    
    [self.contentView addConstraint:self.avatarImageHeightConstraint];
    [self.contentView addConstraint:self.avatarImageBottomConstraint];
    [self.contentView addConstraint:self.avatarImageWidthConstraint];
    
    [self.contentView addConstraint:self.bubbleViewHeightConstraint];
    [self.contentView addConstraint:self.bubbleViewTopConstraint];
    
    [self.contentView addConstraint:self.dateLabelLeftConstraint];
    [self.contentView addConstraint:self.dateLabelCenterYConstraint];
}

@end
