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
        // UIAppearance Defaults
        _messageTextFont = [UIFont systemFontOfSize:14];
        _bubbleView.layer.cornerRadius = 12;
        _avatarImageView.layer.cornerRadius = LYRUIAvatarImageDiameter / 2;
        
        _bubbleView = [[LYRUIMessageBubbleView alloc] init];
        _bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
        _bubbleView.bubbleViewLabel.font = _messageTextFont;
        _bubbleView.layer.cornerRadius = _bubbleViewCornerRadius;
        [self.contentView addSubview:_bubbleView];
        
        _avatarImageView = [[LYRUIAvatarImageView alloc] init];
        _avatarImageView.backgroundColor = LYRUILightGrayColor();
        _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _avatarImageView.layer.cornerRadius = _avatarImageViewCornerRadius;
        [self.contentView addSubview:_avatarImageView];

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

}

- (void)shouldDisplayAvatarImage:(BOOL)shouldDisplayAvatarImage
{

}

- (void)isGroupConversation:(BOOL)isGroupConversation
{

}

- (void)presentMessage:(LYRMessage *)message
{
    LYRMessagePart *messagePart = message.parts.firstObject;
    if (!messagePart.isDownloaded) {
        [self.bubbleView displayDownloadActivityIndicator];
        return;
    }
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
    self.bubbleView.backgroundColor = bubbleViewColor;
}

- (void)setBubbleViewCornerRadius:(CGFloat)bubbleViewCornerRadius
{
    _bubbleViewCornerRadius = bubbleViewCornerRadius;
    self.bubbleView.layer.cornerRadius = bubbleViewCornerRadius;
}

- (void)setAvatarImageViewCornerRadius:(CGFloat)avatarImageViewCornerRadius
{
    _avatarImageViewCornerRadius = avatarImageViewCornerRadius;
    self.avatarImageView.layer.cornerRadius = avatarImageViewCornerRadius;
}
	
@end
