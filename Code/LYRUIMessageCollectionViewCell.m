//
//  LYRUIMessageCollectionViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIMessageCollectionViewCell.h"
#import "LYRUIMessagingUtilities.h"
#import "LYRUIIncomingMessageCollectionViewCell.h"
#import "LYRUIOutgoingMessageCollectionViewCell.h"

@interface LYRUIMessageCollectionViewCell ()

@property (nonatomic) BOOL messageSentState;
@property (nonatomic) NSLayoutConstraint *bubbleViewWidthConstraint;

@end

@implementation LYRUIMessageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bubbleView = [[LYRUIMessageBubbleView alloc] init];
        self.bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.bubbleView];
        
        self.avatarImage = [[LYRUIAvatarImageView alloc] init];
        [self.avatarImage setInitialViewBackgroundColor:LSLighGrayColor()];
        self.avatarImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.avatarImage];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:1.0
                                                                      constant:0]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.contentView
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0
                                                                      constant:0]];

        self.bubbleViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:0];
        [self.contentView addConstraint:self.bubbleViewWidthConstraint];
    }
    return self;
}

- (void)updateWithParticipant:(id<LYRUIParticipant>)participant
{
    NSLog(@"Implemented by subclass");
}

- (void)shouldDisplayAvatarImage:(BOOL)shouldDisplayAvatarImage
{
    NSLog(@"Implemented by subclass");
}

- (void)isGroupConversation:(BOOL)isGroupConversation
{
    NSLog(@"Implemented by subclass");
}

- (void)presentMessagePart:(LYRMessagePart *)messagePart
{
    if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
        NSString *text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
        [self.bubbleView updateWithText:text];
        self.accessibilityLabel = [NSString stringWithFormat:@"Message: %@", text];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [messagePart.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
        UIImage *image = [UIImage imageWithData:messagePart.data];
        [self.bubbleView updateWithImage:image];
        self.accessibilityLabel = [NSString stringWithFormat:@"Message: Photo"];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:messagePart.data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:nil];
        double lat = [dictionary[@"lat"] doubleValue];
        double lon = [dictionary[@"lon"] doubleValue];
        [self.bubbleView updateWithLocation:CLLocationCoordinate2DMake(lat, lon)];
    }
}

- (void)updateWithMessageSentState:(BOOL)messageSentState
{
    self.messageSentState = messageSentState;
}

- (void)updateWithBubbleViewWidth:(CGFloat)bubbleViewWidth
{
    self.bubbleViewWidthConstraint.constant = bubbleViewWidth + 26; // Adding 24px for bubble view horizontal padding + 2px for extra coverage.
}

- (void)setMessageTextFont:(UIFont *)messageTextFont
{
    _messageTextFont = messageTextFont;
    self.bubbleView.bubbleViewLabel.font = messageTextFont;
}

- (void)setMessageTextColor:(UIColor *)messageTextColor
{
    _messageTextColor = messageTextColor;
    self.bubbleView.bubbleViewLabel.textColor = messageTextColor;
}

- (void)setBubbleViewColor:(UIColor *)bubbleViewColor
{
    _bubbleViewColor = bubbleViewColor;
    if ([self isKindOfClass:[LYRUIOutgoingMessageCollectionViewCell class]] && self.messageSentState) {
        self.bubbleView.backgroundColor = bubbleViewColor;
    }
    if ([self isKindOfClass:[LYRUIIncomingMessageCollectionViewCell class]]) {
        self.bubbleView.backgroundColor = bubbleViewColor;
    }
}

- (void)setPendingBubbleViewColor:(UIColor *)pendingBubbleViewColor
{
    if ([self isKindOfClass:[LYRUIOutgoingMessageCollectionViewCell class]] && !self.messageSentState) {
        self.bubbleView.backgroundColor = pendingBubbleViewColor;
    }
}

@end
