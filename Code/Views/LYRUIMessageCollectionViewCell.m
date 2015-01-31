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
@property (nonatomic) LYRMessage *message;

@end

@implementation LYRUIMessageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Default UIAppearance
        _messageTextFont = [UIFont systemFontOfSize:17];
        _messageTextColor = [UIColor blackColor];
        _messageLinkTextColor = [UIColor blueColor];
        _bubbleViewColor = [UIColor grayColor];
        _bubbleViewCornerRadius = 12;
        
        _bubbleView = [[LYRUIMessageBubbleView alloc] init];
        _bubbleView.layer.cornerRadius = _bubbleViewCornerRadius;
        _bubbleView.backgroundColor = _bubbleViewColor;
        [self.contentView addSubview:_bubbleView];
        
        _avatarImageView = [[LYRUIAvatarImageView alloc] init];
        [self.contentView addSubview:_avatarImageView];

        [self configureLayoutConstraints];
    }
    return self;
}

- (void)presentMessage:(LYRMessage *)message
{
    LYRMessagePart *messagePart = message.parts.firstObject;
    if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
        [self configureBubbleViewTextWithMessagePart:messagePart];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG]) {
        [self configureBubbleViewImageWithMessagePart:messagePart];
    }else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
        [self configureBubbleViewImageWithMessagePart:messagePart];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
        [self configureBubbleViewLocationWithMessagePart:messagePart];
    }
    _message = message;
}

- (void)configureBubbleViewTextWithMessagePart:(LYRMessagePart *)messagePart
{
    NSString *text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    [self.bubbleView updateWithAttributedText:[self attributedStringForText:text]];
    self.accessibilityLabel = [NSString stringWithFormat:@"Message: %@", text];
}

- (void)configureBubbleViewImageWithMessagePart:(LYRMessagePart *)messagePart
{
    UIImage *image = [UIImage imageWithData:messagePart.data];
    [self.bubbleView updateWithImage:image];
    self.accessibilityLabel = [NSString stringWithFormat:@"Message: Photo"];
}

- (void)configureBubbleViewLocationWithMessagePart:(LYRMessagePart *)messagePart
{
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:messagePart.data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
    double lat = [dictionary[@"lat"] doubleValue];
    double lon = [dictionary[@"lon"] doubleValue];
    [self.bubbleView updateWithLocation:CLLocationCoordinate2DMake(lat, lon)];
}

- (NSAttributedString *)attributedStringForText:(NSString *)text
{
    NSDictionary *attributes = @{NSFontAttributeName : self.messageTextFont, NSForegroundColorAttributeName : self.messageTextColor};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    NSArray *linkResults = LYRUILinkResultsForText(text);
    for (NSTextCheckingResult *result in linkResults) {
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName : self.messageLinkTextColor,
                                         NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
        [attributedString addAttributes:linkAttributes range:result.range];
    }
    return attributedString;
}

- (void)setMessageTextFont:(UIFont *)messageTextFont
{
    _messageTextFont = messageTextFont;
    if ([self hasTextContent]) [self configureTextContent];
}

- (void)setMessageTextColor:(UIColor *)messageTextColor
{
    _messageTextColor = messageTextColor;
    if ([self hasTextContent]) [self configureTextContent];
}

- (void)setMessageLinkTextColor:(UIColor *)messageLinkTextColor
{
    _messageLinkTextColor = messageLinkTextColor;
    if ([self hasTextContent]) [self configureTextContent];
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

#pragma mark - Helpers

- (BOOL)hasTextContent
{
    LYRMessagePart *messagePart = self.message.parts.firstObject;
    return [messagePart.MIMEType isEqualToString:LYRUIMIMETypeTextPlain];
}

- (void)configureTextContent
{
    LYRMessagePart *messagePart = self.message.parts.firstObject;
    NSString *text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    [self.bubbleView updateWithAttributedText:[self attributedStringForText:text]];
    self.accessibilityLabel = [NSString stringWithFormat:@"Message: %@", text];
}

- (NSAttributedString *)attributedStringForText:(NSString *)text
- (void)configureLayoutConstraints
{
    NSDictionary *attributes = @{NSFontAttributeName : self.messageTextFont, NSForegroundColorAttributeName : self.messageTextColor};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    NSArray *linkResults = LYRUILinkResultsForText(text);
    for (NSTextCheckingResult *result in linkResults) {
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName : self.messageLinkTextColor,
                                         NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
        [attributedString addAttributes:linkAttributes range:result.range];
    }
    return attributedString;
    CGFloat maxBubbleWidth = LYRUIMaxCellWidth() + LYRUIMessageBubbleLabelHorizontalPadding * 2;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:maxBubbleWidth]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
}

- (void)updateWithParticipant:(id<LYRUIParticipant>)participant
{
    // Implemented by subclass
}

- (void)shouldDisplayAvatarImage:(BOOL)shouldDisplayAvatarImage
{
    // Implemented by subclass
}

@end
