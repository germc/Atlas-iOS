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
#import <LayerKit/LayerKit.h> 

@interface LYRUIMessageCollectionViewCell () <LYRProgressDelegate>

@property (nonatomic) BOOL messageSentState;
@property (nonatomic) LYRMessage *message;
@property (nonatomic) LYRProgress *progress;

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

- (void)presentMessage:(LYRMessage *)message;
{
    self.message = message;
    LYRMessagePart *messagePart = message.parts[0];
    
    if ([self messageContainsTextContent]) {
        [self configureBubbleViewForTextContent];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG]) {
        [self configureBubbleViewForImageContent];
    }else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
        [self configureBubbleViewForImageContent];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
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
    
    if (self.message.parts.count == 1) {
        LYRMessagePart *imagePart = self.message.parts[0];
        CGSize size = LYRUIImageSizeForData(imagePart.data);
        [self.bubbleView updateWithImage:[UIImage imageWithData:imagePart.data] width:size.width];
        [self.bubbleView updateActivityIndicatorWithProgress:1.0f options:LYRUIProgressViewOptionButtonStyleNone];
        return;
    }
    
    LYRMessagePart *dimensionPart = self.message.parts[2];
    CGSize size = LYRUIImageSizeForJSONData(dimensionPart.data);
    
    LYRMessagePart *imagePart = self.message.parts[0];
    if (imagePart.isDownloaded) {
        [self.bubbleView updateWithImage:[UIImage imageWithData:imagePart.data] width:size.width];
        [self.bubbleView updateActivityIndicatorWithProgress:1.00 options:LYRUIProgressViewOptionButtonStyleNone | LYRUIProgressViewOptionAnimated];
        return;
    } else {
        [self downloadContentForMessagePart:imagePart trackProgress:YES];
    }
    
    LYRMessagePart *previewPart = self.message.parts[1];
    if (previewPart.isDownloaded) {
        [self.bubbleView updateWithImage:[UIImage imageWithData:previewPart.data] width:size.width];
        return;
    } else {
        [self downloadContentForMessagePart:imagePart trackProgress:NO];
    }
}

- (void)configureBubbleViewForLocationContent
{
    LYRMessagePart *messagePart = self.message.parts.firstObject;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:messagePart.data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
    double lat = [dictionary[@"lat"] doubleValue];
    double lon = [dictionary[@"lon"] doubleValue];
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
    NSArray *linkResults = LYRUILinkResultsForText(text);
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
    return [messagePart.MIMEType isEqualToString:LYRUIMIMETypeTextPlain];
}

- (void)downloadContentForMessagePart:(LYRMessagePart *)part trackProgress:(BOOL)trackProgress
{
    NSError *error;
    self.progress = [part downloadContent:&error];
    if (error) {
        NSLog(@"Download failed with error: %@", error);
        return;
    }
    if (trackProgress) {
        self.progress.userInfo = @{ @"cell" : self };
        self.progress.delegate = self;
        if (self.progress.fractionCompleted == 0.0) {
            [self.bubbleView updateActivityIndicatorWithProgress:self.progress.fractionCompleted options:LYRUIProgressViewOptionShowProgress | LYRUIProgressViewOptionButtonStyleDownload];
        } else if (self.progress.fractionCompleted < 1.0f) {
            [self.bubbleView updateActivityIndicatorWithProgress:self.progress.fractionCompleted options:LYRUIProgressViewOptionShowProgress];
        }
    }
}

- (void)progressDidChange:(LYRProgress *)progress
{
    LYRUIMessageCollectionViewCell *cell = progress.userInfo[@"cell"];
    if (cell) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (progress.fractionCompleted < 1.00f && progress.fractionCompleted > 0.00f) {
                [cell.bubbleView updateActivityIndicatorWithProgress:progress.fractionCompleted options:LYRUIProgressViewOptionShowProgress | LYRUIProgressViewOptionButtonStyleNone | LYRUIProgressViewOptionAnimated];
                return;
            }
            if (progress.fractionCompleted == 1.0f) {
                [cell.bubbleView updateActivityIndicatorWithProgress:1.00 options:LYRUIProgressViewOptionButtonStyleNone | LYRUIProgressViewOptionAnimated];
                progress.userInfo = nil;
                progress.delegate = nil;
            }
        });
    }
}


- (void)configureLayoutConstraints
{
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
