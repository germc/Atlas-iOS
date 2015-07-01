//
//  ATLUIMessageInputToolbar.m
//  Atlas
//
//  Created by Kevin Coleman on 9/18/14.
//  Copyright (c) 2015 Layer. All rights reserved.
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
#import "ATLMessageInputToolbar.h"
#import "ATLConstants.h"
#import "ATLMediaAttachment.h"
#import "ATLMessagingUtilities.h"

NSString *const ATLMessageInputToolbarDidChangeHeightNotification = @"ATLMessageInputToolbarDidChangeHeightNotification";

@interface ATLMessageInputToolbar () <UITextViewDelegate>

@property (nonatomic) NSArray *mediaAttachments;
@property (nonatomic, copy) NSAttributedString *attributedStringForMessageParts;
@property (nonatomic) UITextView *dummyTextView;
@property (nonatomic) CGFloat textViewMaxHeight;
@property (nonatomic) CGFloat buttonCenterY;
@property (nonatomic) BOOL firstAppearance;

@end

@implementation ATLMessageInputToolbar

NSString *const ATLMessageInputToolbarAccessibilityLabel = @"Message Input Toolbar";
NSString *const ATLMessageInputToolbarTextInputView = @"Message Input Toolbar Text Input View";
NSString *const ATLMessageInputToolbarCameraButton  = @"Message Input Toolbar Camera Button";
NSString *const ATLMessageInputToolbarLocationButton  = @"Message Input Toolbar Location Button";
NSString *const ATLMessageInputToolbarSendButton  = @"Message Input Toolbar Send Button";

// Compose View Margin Constants
static CGFloat const ATLLeftButtonHorizontalMargin = 6.0f;
static CGFloat const ATLRightButtonHorizontalMargin = 4.0f;
static CGFloat const ATLVerticalMargin = 7.0f;

// Compose View Button Constants
static CGFloat const ATLLeftAccessoryButtonWidth = 40.0f;
static CGFloat const ATLRightAccessoryButtonWidth = 46.0f;
static CGFloat const ATLButtonHeight = 28.0f;

+ (void)initialize
{
    ATLMessageInputToolbar *proxy = [self appearance];
    proxy.rightAccessoryButtonActiveColor = ATLBlueColor();
    proxy.rightAccessoryButtonDisabledColor = [UIColor grayColor];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.accessibilityLabel = ATLMessageInputToolbarAccessibilityLabel;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.leftAccessoryImage = [UIImage imageNamed:@"AtlasResource.bundle/camera_dark"];
        self.rightAccessoryImage = [UIImage imageNamed:@"AtlasResource.bundle/location_dark"];
        self.displaysRightAccessoryImage = YES;
        self.firstAppearance = YES;
        
        self.leftAccessoryButton = [[UIButton alloc] init];
        self.leftAccessoryButton.accessibilityLabel = ATLMessageInputToolbarCameraButton;
        self.leftAccessoryButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.leftAccessoryButton setImage:self.leftAccessoryImage forState:UIControlStateNormal];
        [self.leftAccessoryButton addTarget:self action:@selector(leftAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftAccessoryButton];
        
        self.textInputView = [[ATLMessageComposeTextView alloc] init];
        self.textInputView.accessibilityLabel = ATLMessageInputToolbarTextInputView;
        self.textInputView.delegate = self;
        self.textInputView.layer.borderColor = ATLGrayColor().CGColor;
        self.textInputView.layer.borderWidth = 0.5;
        self.textInputView.layer.cornerRadius = 5.0f;
        [self addSubview:self.textInputView];
        
        self.rightAccessoryButton = [[UIButton alloc] init];
        [self.rightAccessoryButton addTarget:self action:@selector(rightAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightAccessoryButton];
        [self configureRightAccessoryButtonState];
        
        // Calling sizeThatFits: or contentSize on the displayed UITextView causes the cursor's position to momentarily appear out of place and prevent scrolling to the selected range. So we use another text view for height calculations.
        self.dummyTextView = [[ATLMessageComposeTextView alloc] init];
        self.maxNumberOfLines = 8;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.firstAppearance) {
        [self configureRightAccessoryButtonState];
        self.firstAppearance = NO;
    }
    
    // set the font for the dummy text view as well
    self.dummyTextView.font = self.textInputView.font;
    
    // We layout the views manually since using Auto Layout seems to cause issues in this context (i.e. an auto height resizing text view in an input accessory view) especially with iOS 7.1.
    CGRect frame = self.frame;
    CGRect leftButtonFrame = self.leftAccessoryButton.frame;
    CGRect rightButtonFrame = self.rightAccessoryButton.frame;
    CGRect textViewFrame = self.textInputView.frame;

    if (!self.leftAccessoryButton) {
        leftButtonFrame.size.width = 0;
    } else {
        leftButtonFrame.size.width = ATLLeftAccessoryButtonWidth;
    }
    
    leftButtonFrame.size.height = ATLButtonHeight;
    leftButtonFrame.origin.x = ATLLeftButtonHorizontalMargin;

    rightButtonFrame.size.width = ATLRightAccessoryButtonWidth;
    rightButtonFrame.size.height = ATLButtonHeight;
    rightButtonFrame.origin.x = CGRectGetWidth(frame) - CGRectGetWidth(rightButtonFrame) - ATLRightButtonHorizontalMargin;

    textViewFrame.origin.x = CGRectGetMaxX(leftButtonFrame) + ATLLeftButtonHorizontalMargin;
    textViewFrame.origin.y = ATLVerticalMargin;
    textViewFrame.size.width = CGRectGetMinX(rightButtonFrame) - CGRectGetMinX(textViewFrame) - ATLRightButtonHorizontalMargin;

    self.dummyTextView.attributedText = self.textInputView.attributedText;
    CGSize fittedTextViewSize = [self.dummyTextView sizeThatFits:CGSizeMake(CGRectGetWidth(textViewFrame), MAXFLOAT)];
    textViewFrame.size.height = ceil(MIN(fittedTextViewSize.height, self.textViewMaxHeight));

    frame.size.height = CGRectGetHeight(textViewFrame) + ATLVerticalMargin * 2;
    frame.origin.y -= frame.size.height - CGRectGetHeight(self.frame);
 
    // Only calculate button centerY once to anchor it to bottom of bar.
    if (!self.buttonCenterY) {
        self.buttonCenterY = (CGRectGetHeight(frame) - CGRectGetHeight(leftButtonFrame)) / 2;
    }
    leftButtonFrame.origin.y = frame.size.height - leftButtonFrame.size.height - self.buttonCenterY;
    rightButtonFrame.origin.y = frame.size.height - rightButtonFrame.size.height - self.buttonCenterY;
    
    BOOL heightChanged = CGRectGetHeight(textViewFrame) != CGRectGetHeight(self.textInputView.frame);

    self.leftAccessoryButton.frame = leftButtonFrame;
    self.rightAccessoryButton.frame = rightButtonFrame;
    self.textInputView.frame = textViewFrame;

    // Setting one's own frame like this is a no-no but seems to be the lesser of evils when working around the layout issues mentioned above.
    self.frame = frame;

    if (heightChanged) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ATLMessageInputToolbarDidChangeHeightNotification object:self];
    }
}

- (void)paste:(id)sender
{
    NSArray *images = [UIPasteboard generalPasteboard].images;
    if (images.count > 0) {
        for (UIImage *image in images) {
            ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithImage:image
                                                                                      metadata:nil
                                                                                 thumbnailSize:ATLDefaultThumbnailSize];
            [self insertMediaAttachment:mediaAttachment];
        }
        return;
    }
}

#pragma mark - Public Methods

- (void)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines
{
    _maxNumberOfLines = maxNumberOfLines;
    self.textViewMaxHeight = self.maxNumberOfLines * self.textInputView.font.lineHeight;
    [self setNeedsLayout];
}

- (void)insertMediaAttachment:(ATLMediaAttachment *)mediaAttachment
{
    UITextView *textView = self.textInputView;

    NSMutableAttributedString *attributedString = [textView.attributedText mutableCopy];
    NSAttributedString *lineBreak = [[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName: self.textInputView.font}];
    if (attributedString.length > 0 && ![textView.text hasSuffix:@"\n"]) {
        [attributedString appendAttributedString:lineBreak];
    }

    NSMutableAttributedString *attachmentString = [[NSAttributedString attributedStringWithAttachment:mediaAttachment] mutableCopy];
    [attributedString appendAttributedString:attachmentString];
    [attributedString appendAttributedString:lineBreak];
    [attributedString addAttribute:NSFontAttributeName value:textView.font range:NSMakeRange(0, attributedString.length)];
    if (textView.textColor) {
        [attributedString addAttribute:NSForegroundColorAttributeName value:textView.textColor range:NSMakeRange(0, attributedString.length)];
    }
    textView.attributedText = attributedString;
    if ([self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidType:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidType:self];
    }
    [self setNeedsLayout];
    [self configureRightAccessoryButtonState];
}

- (NSArray *)mediaAttachments
{
    NSAttributedString *attributedString = self.textInputView.attributedText;
    if (!_mediaAttachments || ![attributedString isEqualToAttributedString:self.attributedStringForMessageParts]) {
        self.attributedStringForMessageParts = attributedString;
        _mediaAttachments = [self mediaAttachmentsFromAttributedString:attributedString];
    }
    return _mediaAttachments;
}

- (void)setLeftAccessoryImage:(UIImage *)leftAccessoryImage
{
    _leftAccessoryImage = leftAccessoryImage;
    [self.leftAccessoryButton setImage:leftAccessoryImage  forState:UIControlStateNormal];
}

- (void)setRightAccessoryImage:(UIImage *)rightAccessoryImage
{
    _rightAccessoryImage = rightAccessoryImage;
    [self.rightAccessoryButton setImage:rightAccessoryImage forState:UIControlStateNormal];
}

- (void)setRightAccessoryButtonActiveColor:(UIColor *)rightAccessoryButtonActiveColor
{
    _rightAccessoryButtonActiveColor = rightAccessoryButtonActiveColor;
    [self.rightAccessoryButton setTitleColor:rightAccessoryButtonActiveColor forState:UIControlStateNormal];
}

- (void)setRightAccessoryButtonDisabledColor:(UIColor *)rightAccessoryButtonDisabledColor
{
    _rightAccessoryButtonDisabledColor = rightAccessoryButtonDisabledColor;
    [self.rightAccessoryButton setTitleColor:rightAccessoryButtonDisabledColor forState:UIControlStateDisabled];
}

#pragma mark - Actions

- (void)leftAccessoryButtonTapped
{
    [self.inputToolBarDelegate messageInputToolbar:self didTapLeftAccessoryButton:self.leftAccessoryButton];
}

- (void)rightAccessoryButtonTapped
{
    [self acceptAutoCorrectionSuggestion];
    if ([self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidEndTyping:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidEndTyping:self];
    }
    [self.inputToolBarDelegate messageInputToolbar:self didTapRightAccessoryButton:self.rightAccessoryButton];
    self.textInputView.text = @"";
    [self setNeedsLayout];
    self.mediaAttachments = nil;
    self.attributedStringForMessageParts = nil;
    [self configureRightAccessoryButtonState];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.rightAccessoryButton.imageView) {
        [self configureRightAccessoryButtonState];
    }
    
    if (textView.text.length > 0 && [self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidType:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidType:self];
    } else if (textView.text.length == 0 && [self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidEndTyping:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidEndTyping:self];
    }

    [self setNeedsLayout];
    
    // Workaround for iOS 7.1 not scrolling bottom line into view when entering text. Note that in textViewDidChangeSelection: if the selection to the bottom line is due to entering text then the calculation of the bottom content offset won't be accurate since the content size hasn't yet been updated. Content size has been updated by the time this method is called so our calculation will work.
    NSRange end = NSMakeRange(textView.text.length, 0);
    if (NSEqualRanges(textView.selectedRange, end)) {
        CGPoint bottom = CGPointMake(0, textView.contentSize.height - CGRectGetHeight(textView.frame));
        [textView setContentOffset:bottom animated:NO];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    // Workaround for iOS 7.1 not scrolling bottom line into view. Note that this only works for a selection change not due to text entry (in other words e.g. when using an external keyboard's bottom arrow key). The workaround in textViewDidChange: handles selection changes due to text entry.
    NSRange end = NSMakeRange(textView.text.length, 0);
    if (NSEqualRanges(textView.selectedRange, end)) {
        CGPoint bottom = CGPointMake(0, textView.contentSize.height - CGRectGetHeight(textView.frame));
        [textView setContentOffset:bottom animated:NO];
        return;
    }

    // Workaround for automatic scrolling not occurring in some cases.
    [textView scrollRangeToVisible:textView.selectedRange];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    return YES;
}

#pragma mark - Helpers

- (NSArray *)mediaAttachmentsFromAttributedString:(NSAttributedString *)attributedString
{
    NSMutableArray *mediaAttachments = [NSMutableArray new];
    [attributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id attachment, NSRange range, BOOL *stop) {
        if ([attachment isKindOfClass:[ATLMediaAttachment class]]) {
            ATLMediaAttachment *mediaAttachment = (ATLMediaAttachment *)attachment;
            [mediaAttachments addObject:mediaAttachment];
            return;
        }
        NSAttributedString *attributedSubstring = [attributedString attributedSubstringFromRange:range];
        NSString *substring = attributedSubstring.string;
        NSString *trimmedSubstring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmedSubstring.length == 0) {
            return;
        }
        ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithText:trimmedSubstring];
        [mediaAttachments addObject:mediaAttachment];
    }];
    return mediaAttachments;
}

- (void)acceptAutoCorrectionSuggestion
{
    // This is a workaround to accept the current auto correction suggestion while not resigning as first responder. From: http://stackoverflow.com/a/27865136
    [self.textInputView.inputDelegate selectionWillChange:self.textInputView];
    [self.textInputView.inputDelegate selectionDidChange:self.textInputView];
}

#pragma mark - Send Button Enablement

- (void)configureRightAccessoryButtonState
{
    if (self.textInputView.text.length) {
        [self configureRightAccessoryButtonForText];
        self.rightAccessoryButton.enabled = YES;
    } else {
        if (self.displaysRightAccessoryImage) {
            [self configureRightAccessoryButtonForImage];
            self.rightAccessoryButton.enabled = YES;
        } else {
            [self configureRightAccessoryButtonForText];
            self.rightAccessoryButton.enabled = NO;
        }
    }
}

- (void)configureRightAccessoryButtonForText
{
    self.rightAccessoryButton.accessibilityLabel = ATLMessageInputToolbarSendButton;
    [self.rightAccessoryButton setImage:nil forState:UIControlStateNormal];
    self.rightAccessoryButton.contentEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    self.rightAccessoryButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.rightAccessoryButton setTitle:@"Send" forState:UIControlStateNormal];
    [self.rightAccessoryButton setTitleColor:self.rightAccessoryButtonActiveColor forState:UIControlStateNormal];
    [self.rightAccessoryButton setTitleColor:self.rightAccessoryButtonDisabledColor forState:UIControlStateDisabled];
    if (!self.displaysRightAccessoryImage && !self.textInputView.text.length) {
        self.rightAccessoryButton.enabled = NO;
    } else {
        self.rightAccessoryButton.enabled = YES;
    }
}

- (void)configureRightAccessoryButtonForImage
{
    self.rightAccessoryButton.enabled = YES;
    self.rightAccessoryButton.accessibilityLabel = ATLMessageInputToolbarLocationButton;
    self.rightAccessoryButton.contentEdgeInsets = UIEdgeInsetsZero;
    [self.rightAccessoryButton setTitle:nil forState:UIControlStateNormal];
    [self.rightAccessoryButton setImage:self.rightAccessoryImage forState:UIControlStateNormal];
}


@end
