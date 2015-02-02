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
    
    if ([self hasTextContent]) {
        [self configureTextContent];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG]) {
        [self configureImageContent];
    }else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
        [self configureImageContent];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
        [self configureLocationContent];
    }
}

- (void)configureTextContent
{
    LYRMessagePart *messagePart = self.message.parts.firstObject;
    NSString *text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    [self.bubbleView updateWithAttributedText:[self attributedStringForText:text]];
    self.accessibilityLabel = [NSString stringWithFormat:@"Message: %@", text];
}

- (void)configureImageContent
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
        id objectContext = [imagePart performSelector:@selector(objectContext) withObject:nil];
        id layerClient = [objectContext performSelector:@selector(delegate) withObject:nil];
        id tranfserProgressManager = [layerClient performSelector:@selector(externalContentProgressManager) withObject:nil];
        LYRProgress *progress = [tranfserProgressManager performSelector:@selector(downloadProgressForMessagePart:) withObject:imagePart];
        progress.userInfo = @{ @"cell" : self };
        progress.delegate = self;
        if (progress.fractionCompleted == 0.0) {
            [self.bubbleView updateActivityIndicatorWithProgress:progress.fractionCompleted options:LYRUIProgressViewOptionShowProgress | LYRUIProgressViewOptionButtonStyleDownload];
        } else if (progress.fractionCompleted < 1.0f) {
            [self.bubbleView updateActivityIndicatorWithProgress:progress.fractionCompleted options:LYRUIProgressViewOptionShowProgress];
        }
    }
    
    LYRMessagePart *previewPart;
    if (self.message.parts.count > 1) previewPart = self.message.parts[1];
    if (previewPart.isDownloaded) {
        [self.bubbleView updateWithImage:[UIImage imageWithData:previewPart.data] width:size.width];
        return;
    }
}

- (void)configureLocationContent
{
    LYRMessagePart *messagePart = self.message.parts.firstObject;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:messagePart.data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
    double lat = [dictionary[@"lat"] doubleValue];
    double lon = [dictionary[@"lon"] doubleValue];
    [self.bubbleView updateWithLocation:CLLocationCoordinate2DMake(lat, lon)];
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

- (BOOL)hasTextContent
{
    LYRMessagePart *messagePart = self.message.parts.firstObject;
    return [messagePart.MIMEType isEqualToString:LYRUIMIMETypeTextPlain];
}

- (void)downloadContentForMessagePart:(LYRMessagePart *)part
{
    NSError *error;
    self.progress = [part downloadContent:&error];
    if (error) {
        NSLog(@"Download failed with error: %@", error);
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
