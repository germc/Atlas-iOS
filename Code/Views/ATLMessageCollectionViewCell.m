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
#import "ATLUIImageHelper.h"
#import "ATLIncomingMessageCollectionViewCell.h"
#import "ATLOutgoingMessageCollectionViewCell.h"
#import <LayerKit/LayerKit.h>

NSString *const ATLGIFAccessibilityLabel = @"Message: GIF";
NSString *const ATLImageAccessibilityLabel = @"Message: Image";
static char const ATLMessageCollectionViewCellImageProcessingConcurrentQueue[] = "com.layer.Atlas.ATLMessageCollectionViewCell.imageProcessingConcurrentQueue";

CGFloat const ATLMessageCellMinimumHeight = 10.0f;
CGFloat const ATLMessageCellHorizontalMargin = 16.0f;
CGFloat const ATLAvatarImageLeadPadding = 12.0f;
CGFloat const ATLAvatarImageTailPadding = 7.0f;

@interface ATLMessageCollectionViewCell () <LYRProgressDelegate>

@property (nonatomic) BOOL messageSentState;
@property (nonatomic) LYRProgress *progress;
@property (nonatomic) NSUInteger lastProgressFractionCompleted;
@property (nonatomic) NSLayoutConstraint *bubbleWithAvatarLeadConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithoutAvatarLeadConstraint;
@property (nonatomic) dispatch_queue_t imageProcessingConcurrentQueue;

@end

@implementation ATLMessageCollectionViewCell

+ (ATLMessageCollectionViewCell *)sharedCell
{
    static ATLMessageCollectionViewCell *_sharedCell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCell = [[self class] new];
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
    _imageProcessingConcurrentQueue = dispatch_queue_create(ATLMessageCollectionViewCellImageProcessingConcurrentQueue, DISPATCH_QUEUE_CONCURRENT);
    
    // Default UIAppearance
    _messageTextFont = [UIFont systemFontOfSize:17];
    _messageTextColor = [UIColor blackColor];
    _messageLinkTextColor = [UIColor whiteColor];
    _messageTextCheckingTypes = NSTextCheckingTypeLink;
    _bubbleViewColor = ATLBlueColor();
    _bubbleViewCornerRadius = 17.0f;
    
    _bubbleView = [[ATLMessageBubbleView alloc] init];
    _bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
    _bubbleView.layer.cornerRadius = _bubbleViewCornerRadius;
    _bubbleView.backgroundColor = _bubbleViewColor;
    [self.contentView addSubview:_bubbleView];
    
    _avatarImageView = [[ATLAvatarImageView alloc] init];
    _avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_avatarImageView];
    
    [self.bubbleView updateProgressIndicatorWithProgress:0.0 visible:NO animated:NO];
    
    [self configureLayoutConstraints];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    // Remove self from any previously assigned LYRProgress instance.
    self.progress.delegate = nil;
    self.lastProgressFractionCompleted = 0;
    [self.avatarImageView resetView];
    [self.bubbleView prepareForReuse];
}

- (void)presentMessage:(LYRMessage *)message
{
    self.message = message;
    LYRMessagePart *messagePart = message.parts.firstObject;
    
    if ([self messageContainsTextContent]) {
        [self configureBubbleViewForTextContent];
    } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImageJPEG]) {
        [self configureBubbleViewForImageContent];
    }else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImagePNG]) {
        [self configureBubbleViewForImageContent];
    } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImageGIF]){
        [self configureBubbleViewForGIFContent];
    } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeLocation]) {
        [self configureBubbleViewForLocationContent];
    }
}

- (void)configureBubbleViewForTextContent
{
    LYRMessagePart *messagePart = self.message.parts.firstObject;
    NSString *text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    [self.bubbleView updateWithAttributedText:[self attributedStringForText:text]];
    [self.bubbleView updateProgressIndicatorWithProgress:0.0 visible:NO animated:NO];
    self.accessibilityLabel = [NSString stringWithFormat:@"Message: %@", text];
}

- (void)configureBubbleViewForImageContent
{
    self.accessibilityLabel = ATLImageAccessibilityLabel;
    
    LYRMessagePart *fullResImagePart = ATLMessagePartForMIMEType(self.message, ATLMIMETypeImageJPEG);
    if (!fullResImagePart) {
        fullResImagePart = ATLMessagePartForMIMEType(self.message, ATLMIMETypeImagePNG);
    }

    if (fullResImagePart && ((fullResImagePart.transferStatus == LYRContentTransferAwaitingUpload) ||
                             (fullResImagePart.transferStatus == LYRContentTransferUploading))) {
        // Set self for delegation, if full resolution message part
        // hasn't been uploaded yet, or is still uploading.
        LYRProgress *progress = fullResImagePart.progress;
        [progress setDelegate:self];
        self.progress = progress;
        [self.bubbleView updateProgressIndicatorWithProgress:progress.fractionCompleted visible:YES animated:NO];
    } else {
        [self.bubbleView updateProgressIndicatorWithProgress:1.0 visible:NO animated:YES];
    }
    
    __block UIImage *displayingImage;
    LYRMessagePart *previewImagePart = ATLMessagePartForMIMEType(self.message, ATLMIMETypeImageJPEGPreview);
    
    if (!previewImagePart) {
        // If no preview image part found, resort to the full-resolution image.
        previewImagePart = fullResImagePart;
    }
    
    __weak typeof(self) weakSelf = self;
    __block LYRMessage *previousMessage = weakSelf.message;
    
    dispatch_async(self.imageProcessingConcurrentQueue, ^{
        if (previewImagePart.fileURL) {
            displayingImage = [UIImage imageWithContentsOfFile:previewImagePart.fileURL.path];
        } else {
            displayingImage = [UIImage imageWithData:previewImagePart.data];
        }
        
        CGSize size = CGSizeZero;
        LYRMessagePart *sizePart = ATLMessagePartForMIMEType(self.message, ATLMIMETypeImageSize);
        if (sizePart) {
            size = ATLImageSizeForJSONData(sizePart.data);
            size = ATLConstrainImageSizeToCellSize(size);
        }
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            // Resort to image's size, if no dimensions metadata message parts found.
            size = ATLImageSizeForData(fullResImagePart.data);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // Fall-back to programatically requesting for a content download of
            // single message part messages (Android compatibillity).
            if ([[weakSelf.message valueForKeyPath:@"parts.MIMEType"] isEqual:@[ATLMIMETypeImageJPEG]]) {
                if (fullResImagePart && (fullResImagePart.transferStatus == LYRContentTransferReadyForDownload)) {
                    NSError *error;
                    LYRProgress *progress = [fullResImagePart downloadContent:&error];
                    if (!progress) {
                        NSLog(@"failed to request for a content download from the UI with error=%@", error);
                    }
                    [weakSelf.bubbleView updateProgressIndicatorWithProgress:0.0 visible:NO animated:NO];
                } else if (fullResImagePart && (fullResImagePart.transferStatus == LYRContentTransferDownloading)) {
                    // Set self for delegation, if single image message part message
                    // hasn't been downloaded yet, or is still downloading.
                    LYRProgress *progress = fullResImagePart.progress;
                    [progress setDelegate:weakSelf];
                    weakSelf.progress = progress;
                    [weakSelf.bubbleView updateProgressIndicatorWithProgress:progress.fractionCompleted visible:YES animated:NO];
                } else {
                    [weakSelf.bubbleView updateProgressIndicatorWithProgress:1.0 visible:NO animated:YES];
                }
            }
            if (weakSelf.message != previousMessage) {
                return;
            }
            [weakSelf.bubbleView updateWithImage:displayingImage width:size.width];
        });
    });
}

- (void)configureBubbleViewForGIFContent
{
    self.accessibilityLabel = ATLGIFAccessibilityLabel;
    
    LYRMessagePart *fullResImagePart = ATLMessagePartForMIMEType(self.message, ATLMIMETypeImageGIF);

    if (fullResImagePart && ((fullResImagePart.transferStatus == LYRContentTransferAwaitingUpload) ||
                             (fullResImagePart.transferStatus == LYRContentTransferUploading))) {
        // Set self for delegation, if full resolution message part
        // hasn't been uploaded yet, or is still uploading.
        LYRProgress *progress = fullResImagePart.progress;
        [progress setDelegate:self];
        self.progress = progress;
        [self.bubbleView updateProgressIndicatorWithProgress:progress.fractionCompleted visible:YES animated:NO];
    } else {
        [self.bubbleView updateProgressIndicatorWithProgress:1.0 visible:NO animated:YES];
    }
    
    __block UIImage *displayingImage;
    LYRMessagePart *previewImagePart = ATLMessagePartForMIMEType(self.message, ATLMIMETypeImageGIFPreview);
    
    if (!previewImagePart) {
        // If no preview image part found, resort to the full-resolution image.
        previewImagePart = fullResImagePart;
    }
    __weak typeof(self) weakSelf = self;
    __block LYRMessage *previousMessage = weakSelf.message;
    
    dispatch_async(self.imageProcessingConcurrentQueue, ^{
        if (previewImagePart.fileURL) {
            displayingImage = ATLAnimatedImageWithAnimatedGIFURL(previewImagePart.fileURL);
        } else if (previewImagePart.data) {
            displayingImage = ATLAnimatedImageWithAnimatedGIFData(previewImagePart.data);
        }
        
        CGSize size = CGSizeZero;
        LYRMessagePart *sizePart = ATLMessagePartForMIMEType(self.message, ATLMIMETypeImageSize);
        if (sizePart) {
            size = ATLImageSizeForJSONData(sizePart.data);
            size = ATLConstrainImageSizeToCellSize(size);
        }
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            // Resort to image's size, if no dimensions metadata message parts found.
            size = ATLImageSizeForData(fullResImagePart.data);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // For GIFs we only download full resolution parts when rendered in the UI
            // Low res GIFs are autodownloaded but blurry
            if ([fullResImagePart.MIMEType isEqualToString:ATLMIMETypeImageGIF]) {
                if (fullResImagePart.transferStatus == LYRContentTransferReadyForDownload) {
                    NSError *error;
                    LYRProgress *progress = [fullResImagePart downloadContent:&error];
                    if (!progress) {
                        NSLog(@"failed to request for a content download from the UI with error=%@", error);
                    }
                    [weakSelf.bubbleView updateProgressIndicatorWithProgress:0.0 visible:NO animated:NO];
                    [weakSelf.bubbleView updateWithImage:displayingImage width:size.width];
                } else if (fullResImagePart.transferStatus == LYRContentTransferDownloading) {
                    LYRProgress *progress = fullResImagePart.progress;
                    [progress setDelegate:weakSelf];
                    weakSelf.progress = progress;
                    [weakSelf.bubbleView updateProgressIndicatorWithProgress:progress.fractionCompleted visible:YES animated:NO];
                    [weakSelf.bubbleView updateWithImage:displayingImage width:size.width];
                } else {
                    dispatch_async(weakSelf.imageProcessingConcurrentQueue, ^{
                        displayingImage = ATLAnimatedImageWithAnimatedGIFData(fullResImagePart.data);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (weakSelf.message != previousMessage) {
                                return;
                            }
                            [weakSelf.bubbleView updateProgressIndicatorWithProgress:1.0 visible:NO animated:YES];
                            [weakSelf.bubbleView updateWithImage:displayingImage width:size.width];
                        });
                    });
                }
            }
        });
    });
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
    [self.bubbleView updateProgressIndicatorWithProgress:0.0 visible:NO animated:NO];
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

- (void)setMessageTextCheckingTypes:(NSTextCheckingType)messageLinkTypes
{
    _messageTextCheckingTypes = messageLinkTypes;
    self.bubbleView.textCheckingTypes = messageLinkTypes;
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

#pragma mark - LYRProgress Delegate Implementation

- (void)progressDidChange:(LYRProgress *)progress
{
    // Queue UI updates onto the main thread, since LYRProgress performs
    // delegate callbacks from a background thread.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (progress.delegate == nil) {
            // Do not do any UI changes, if receiver has been removed.
            return;
        }
        BOOL progressCompleted = progress.fractionCompleted == 1.0f;
        [self.bubbleView updateProgressIndicatorWithProgress:progress.fractionCompleted visible:progressCompleted ? NO : YES animated:YES];
        // After transfer completes, remove self for delegation.
        if (progressCompleted) {
            progress.delegate = nil;
        }
    });
}

#pragma mark - Helpers

- (NSAttributedString *)attributedStringForText:(NSString *)text
{
    NSDictionary *attributes = @{NSFontAttributeName : self.messageTextFont, NSForegroundColorAttributeName : self.messageTextColor};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    NSArray *linkResults = ATLTextCheckingResultsForText(text, self.messageTextCheckingTypes);
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
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}

- (void)updateWithSender:(id<ATLParticipant>)sender
{
    if (sender) {
        self.avatarImageView.hidden = NO;
        self.avatarImageView.avatarItem = sender;
    } else {
        self.avatarImageView.hidden = YES;
    }
}

- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem
{
    NSArray *constraints = [self.contentView constraints];
    if (shouldDisplayAvatarItem) {
        if ([constraints containsObject:self.bubbleWithAvatarLeadConstraint]) return;
        [self.contentView removeConstraint:self.bubbleWithoutAvatarLeadConstraint];
        [self.contentView addConstraint:self.bubbleWithAvatarLeadConstraint];
    } else {
        if ([constraints containsObject:self.bubbleWithoutAvatarLeadConstraint]) return;
        [self.contentView removeConstraint:self.bubbleWithAvatarLeadConstraint];
        [self.contentView addConstraint:self.bubbleWithoutAvatarLeadConstraint];
    }
    [self setNeedsUpdateConstraints];
}

#pragma mark - Cell Height Calculations

+ (CGFloat)cellHeightForMessage:(LYRMessage *)message inView:(UIView *)view
{
    LYRMessagePart *part = message.parts.firstObject;

    CGFloat height = 0;
    if ([part.MIMEType isEqualToString:ATLMIMETypeTextPlain]) {
        height = [self cellHeightForTextMessage:message inView:view];
    } else if ([part.MIMEType isEqualToString:ATLMIMETypeImageJPEG] || [part.MIMEType isEqualToString:ATLMIMETypeImagePNG] || [part.MIMEType isEqualToString:ATLMIMETypeImageGIF]) {
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
    UIFont *font = [[[self class] appearance] messageTextFont];
    if (!font) {
        font = cell.messageTextFont;
    }
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
        if ((imagePart.transferStatus == LYRContentTransferComplete) ||
            (imagePart.transferStatus == LYRContentTransferAwaitingUpload) ||
            (imagePart.transferStatus == LYRContentTransferUploading)) {
            size = ATLImageSizeForData(imagePart.data);
        } else {
            // We don't have the image data yet, making cell think there's
            // an image with 3:4 aspect ration (portrait photo).
            size = ATLConstrainImageSizeToCellSize(CGSizeMake(3000, 4000));
        }
    }
    return size.height;
}

@end
