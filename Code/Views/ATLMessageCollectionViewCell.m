//
//  ATLUIMessageCollectionViewCell.m
//  Atlas
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ATLMessageCollectionViewCell.h"
#import "ATLMessagingUtilities.h"
#import "ATLIncomingMessageCollectionViewCell.h"
#import "ATLOutgoingMessageCollectionViewCell.h"
#import <LayerKit/LayerKit.h> 

@interface ATLMessageCollectionViewCell ()

@property (nonatomic) BOOL messageSentState;
@property (nonatomic) LYRMessage *message;

@end

@implementation ATLMessageCollectionViewCell

CGFloat const ATLMessageCellMinimumHeight = 10;
CGFloat const ATLMessageCellHorizontalMargin = 16;

+ (ATLMessageCollectionViewCell *)sharedCell
{
    static ATLMessageCollectionViewCell *_sharedCell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCell = [ATLMessageCollectionViewCell new];
    });
    return _sharedCell;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (void)lyr_commonInit
{
    // Default UIAppearance
    _messageTextFont = [UIFont systemFontOfSize:17];
    _messageTextColor = [UIColor blackColor];
    _messageLinkTextColor = [UIColor blueColor];
    _bubbleViewColor = [UIColor grayColor];
    _bubbleViewCornerRadius = 17;
    
    _bubbleView = [[ATLMessageBubbleView alloc] init];
    _bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
    _bubbleView.layer.cornerRadius = _bubbleViewCornerRadius;
    _bubbleView.backgroundColor = _bubbleViewColor;
    [self.contentView addSubview:_bubbleView];
    
    _avatarImageView = [[ATLAvatarImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_avatarImageView];
    
    [self configureLayoutConstraints];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.bubbleView prepareForReuse];
}

- (void)presentMessage:(LYRMessage *)message;
{
    self.message = message;
    LYRMessagePart *messagePart = message.parts.firstObject;
    
    if ([self messageContainsTextContent]) {
        [self configureBubbleViewForTextContent];
    } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImageJPEG]) {
        [self configureBubbleViewForImageContent];
    }else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImagePNG]) {
        [self configureBubbleViewForImageContent];
    } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeLocation]) {
        [self configureBubbleViewForLocationContent];
    }
}

- (void)configureBubbleViewForTextContent
{
    LYRMessagePart *messagePart = self.message.parts.firstObject;
    NSString *text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    [self.bubbleView updateWithAttributedText:[self attributedStringForText:text]];
    self.accessibilityLabel = [NSString stringWithFormat:@"Message: %@", text];
}

- (void)configureBubbleViewForImageContent
{
    self.accessibilityLabel = [NSString stringWithFormat:@"Message: Photo"];
    
    UIImage *displayingImage;
    LYRMessagePart *imagePart = ATLMessagePartForMIMEType(self.message, ATLMIMETypeImageJPEGPreview);
    if (!imagePart) {
        // If no preview image part found, resort to the full-resolution image.
        imagePart = ATLMessagePartForMIMEType(self.message, ATLMIMETypeImageJPEG);
    }
    if (imagePart.fileURL) {
        displayingImage = [UIImage imageWithContentsOfFile:imagePart.fileURL.path];
    } else {
        displayingImage = [UIImage imageWithData:imagePart.data];
    }
    
    CGSize size = CGSizeZero;
    LYRMessagePart *sizePart = ATLMessagePartForMIMEType(self.message, ATLMIMETypeImageSize);
    if (sizePart) {
        size = ATLImageSizeForJSONData(sizePart.data);
        size = ATLConstrainImageSizeToCellSize(size);
    }
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        // Resort to image's size, if no dimensions metadata message parts found.
        size = ATLImageSizeForData(imagePart.data);
    }
    [self.bubbleView updateWithImage:displayingImage width:size.width];
}

- (void)configureBubbleViewForLocationContent
{
    LYRMessagePart *messagePart = self.message.parts.firstObject;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:messagePart.data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
    double lat = [dictionary[ATLLocationLatitudeKey] doubleValue];
    double lon = [dictionary[ATLLocationLongitudeKey] doubleValue];
    [self.bubbleView updateWithLocation:CLLocationCoordinate2DMake(lat, lon)];
}

- (void)setMessageTextFont:(UIFont *)messageTextFont
{
    _messageTextFont = messageTextFont;
    if ([self messageContainsTextContent]) [self configureBubbleViewForTextContent];
}

- (void)setMessageTextColor:(UIColor *)messageTextColor
{
    _messageTextColor = messageTextColor;
    if ([self messageContainsTextContent]) [self configureBubbleViewForTextContent];
}

- (void)setMessageLinkTextColor:(UIColor *)messageLinkTextColor
{
    _messageLinkTextColor = messageLinkTextColor;
    if ([self messageContainsTextContent]) [self configureBubbleViewForTextContent];
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

- (NSAttributedString *)attributedStringForText:(NSString *)text
{
    NSDictionary *attributes = @{NSFontAttributeName : self.messageTextFont, NSForegroundColorAttributeName : self.messageTextColor};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    NSArray *linkResults = ATLLinkResultsForText(text);
    for (NSTextCheckingResult *result in linkResults) {
        NSDictionary *linkAttributes = @{NSForegroundColorAttributeName : self.messageLinkTextColor,
                                         NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
        [attributedString addAttributes:linkAttributes range:result.range];
    }
    return attributedString;
}

- (BOOL)messageContainsTextContent
{
    LYRMessagePart *messagePart = self.message.parts.firstObject;
    return [messagePart.MIMEType isEqualToString:ATLMIMETypeTextPlain];
}

- (void)configureLayoutConstraints
{
    CGFloat maxBubbleWidth = ATLMaxCellWidth() + ATLMessageBubbleLabelHorizontalPadding * 2;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:maxBubbleWidth]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
}

- (void)updateWithSender:(id<ATLParticipant>)sender
{
    // Implemented by subclass
}

- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem
{
    // Implemented by subclass
}

#pragma mark - Cell Height Calculations 

+ (CGFloat)cellHeightForMessage:(LYRMessage *)message inView:(UIView *)view
{
    LYRMessagePart *part = message.parts.firstObject;

    CGFloat height = 0;
    if ([part.MIMEType isEqualToString:ATLMIMETypeTextPlain]) {
        height = [self cellHeightForTextMessage:message inView:view];
    } else if ([part.MIMEType isEqualToString:ATLMIMETypeImageJPEG] || [part.MIMEType isEqualToString:ATLMIMETypeImagePNG]) {
        height = [self cellHeightForImageMessage:message];
    } else if ([part.MIMEType isEqualToString:ATLMIMETypeLocation]) {
        height = ATLMessageBubbleMapHeight;
    }
    if (height < ATLMessageCellMinimumHeight) height = ATLMessageCellMinimumHeight;
    height = ceil(height);
    return height;
}

+ (CGFloat)cellHeightForTextMessage:(LYRMessage *)message inView:(id)view
{
    // Temporarily adding  the view to the hierarchy so that UIAppearance property values will be set based on containment.
    ATLMessageCollectionViewCell *cell = [self sharedCell];
    [view addSubview:cell];
    [cell removeFromSuperview];
    
    LYRMessagePart *part = message.parts.firstObject;
    NSString *text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
    UIFont *font = cell.messageTextFont;
    CGSize size = ATLTextPlainSize(text, font);
    return size.height + ATLMessageBubbleLabelVerticalPadding * 2;
}

+ (CGFloat)cellHeightForImageMessage:(LYRMessage *)message
{
    CGSize size = CGSizeZero;
    LYRMessagePart *sizePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImageSize);
    if (sizePart) {
        size = ATLImageSizeForJSONData(sizePart.data);
        size = ATLConstrainImageSizeToCellSize(size);
    }
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        LYRMessagePart *imagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImageJPEGPreview);
        if (!imagePart) {
            // If no preview image part found, resort to the full-resolution image.
            imagePart = ATLMessagePartForMIMEType(message, ATLMIMETypeImageJPEG);
        }
        // Resort to image's size, if no dimensions metadata message parts found.
        size = ATLImageSizeForData(imagePart.data);
    }
    return size.height;
}

@end
