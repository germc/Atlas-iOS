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

+ (LYRUIMessageCollectionViewCell *)sharedCell
{
    static LYRUIMessageCollectionViewCell *_sharedCell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCell = [LYRUIMessageCollectionViewCell new];
    });
    return _sharedCell;
}

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
        _bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
        _bubbleView.layer.cornerRadius = _bubbleViewCornerRadius;
        _bubbleView.backgroundColor = _bubbleViewColor;
        [self.contentView addSubview:_bubbleView];
        
        _avatarImageView = [[LYRUIAvatarImageView alloc] init];
        _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_avatarImageView];

        [self configureLayoutConstraints];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.bubbleView prepareForReuse];
    self.progress = nil;
}

- (void)presentMessage:(LYRMessage *)message;
{
    self.message = message;
    LYRMessagePart *messagePart = message.parts.firstObject;
    
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
        LYRMessagePart *imagePart = self.message.parts.firstObject;
        CGSize size = LYRUIImageSizeForData(imagePart.data);
        [self.bubbleView updateWithImage:[UIImage imageWithData:imagePart.data] width:size.width];
        [self.bubbleView updateActivityIndicatorWithProgress:1.0f style:LYRUIProgressViewIconStyleNone];
        return;
    }
    
    CGSize size;
    LYRMessagePart *dimensionPart = self.message.parts[2];
    if ([dimensionPart.MIMEType isEqualToString:LYRUIMIMETypeImageSize]) {
        size = LYRUIImageSizeForJSONData(dimensionPart.data);
    }
   
    LYRMessagePart *imagePart = self.message.parts.firstObject;
    if (imagePart.transferStatus == LYRContentTransferAwaitingUpload ||
        imagePart.transferStatus == LYRContentTransferUploading) {
        // Is uploading
        [self trackProgressForMessagePart:imagePart];
    } else if (imagePart.transferStatus == LYRContentTransferReadyForDownload ||
               imagePart.transferStatus == LYRContentTransferDownloading) {
        // Is downloading
        [self trackProgressForMessagePart:imagePart];
    } else {
        // Image already uploaded or downloaded
        [self.bubbleView updateActivityIndicatorWithProgress:1.0f style:LYRUIProgressViewIconStyleNone];
    }
    
    LYRMessagePart *previewPart = self.message.parts[1];
    if (![previewPart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEGPreview]) return;
    if (previewPart.transferStatus == LYRContentTransferComplete ||
        previewPart.transferStatus == LYRContentTransferAwaitingUpload ||
        previewPart.transferStatus == LYRContentTransferUploading) {
        // Always displaying the preview image.
        [self.bubbleView updateWithImage:[UIImage imageWithData:previewPart.data] width:size.width];
        return;
    } else if (previewPart.transferStatus ){
        [self.bubbleView updateWithImage:[[UIImage alloc] init] width:size.width];
    }
}

- (void)configureBubbleViewForLocationContent
{
    LYRMessagePart *messagePart = self.message.parts.firstObject;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:messagePart.data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:nil];
    double lat = [dictionary[LYRUILocationLatitudeKey] doubleValue];
    double lon = [dictionary[LYRUILocationLongitudeKey] doubleValue];
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

- (void)trackProgressForMessagePart:(LYRMessagePart *)messagePart
{
    self.progress = [messagePart progress];
    self.progress.delegate = self;
    if (messagePart.transferStatus == LYRContentTransferAwaitingUpload ||
        messagePart.transferStatus == LYRContentTransferUploading) {
        self.progress.userInfo = @{ @"transferType": @(LYRContentTransferTypeUpload) };
    } else {
        self.progress.userInfo = @{ @"transferType": @(LYRContentTransferTypeDownload) };
    }
    [self progressDidChange:self.progress];
}

- (void)progressDidChange:(LYRProgress *)progress
{
    void (^progressUpdateUIBlock)(void) = ^{
        if (progress.fractionCompleted < 1.00f) {
            LYRContentTransferType transferType = [progress.userInfo[@"transferType"] integerValue];
            [self.bubbleView updateActivityIndicatorWithProgress:self.progress.fractionCompleted style:transferType == LYRContentTransferTypeDownload ? LYRUIProgressViewIconStyleDownload : LYRUIProgressViewIconStyleUpload];
            return;
        } else {
            [self.bubbleView updateActivityIndicatorWithProgress:self.progress.fractionCompleted style:LYRUIProgressViewIconStyleNone];
            progress.delegate = nil;
        }
    };
    if ([NSThread isMainThread]) {
        // Make sure not to cause a dead-lock, so we don't dispatching_sync
        // onto the main queue while already in main queue.
        progressUpdateUIBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), progressUpdateUIBlock);
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

+ (CGFloat)cellHeightForMessage:(LYRMessage *)message inView:(UIView *)view
{
    LYRMessagePart *part = message.parts.firstObject;

    if (!part.data.length) return 48;
    CGFloat height;
    if ([part.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
        LYRUIMessageCollectionViewCell *cell = [self sharedCell];
        [view addSubview:cell];
        [cell removeFromSuperview];
        NSString *text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        UIFont *font = cell.messageTextFont;
        CGSize size = LYRUITextPlainSize(text, font);
        height = size.height + LYRUIMessageBubbleLabelVerticalPadding * 2;
    } else if ([part.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [part.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
        if (part.isDownloaded) {
            UIImage *image = [UIImage imageWithData:part.data];
            CGSize size = LYRUIImageSize(image);
            height = size.height;
        } else {
            LYRMessagePart *dimensionPart = message.parts[2];
            if ([dimensionPart.MIMEType isEqualToString:LYRUIMIMETypeImageSize]) {
                CGSize size = LYRUIImageSizeForJSONData(dimensionPart.data);
                height = size.height;
            } else {
                height = 0;
            }
        }
    } else if ([part.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
        height = LYRUIMessageBubbleMapHeight;
    } else {
        height = 10;
    }
    height = ceil(height);
    
    return height;
}

@end
