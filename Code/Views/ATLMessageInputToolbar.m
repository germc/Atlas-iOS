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

@property (nonatomic) NSArray *messageParts;
@property (nonatomic, copy) NSAttributedString *attributedStringForMessageParts;
@property (nonatomic) UITextView *dummyTextView;
@property (nonatomic) CGFloat textViewMaxHeight;
@property (nonatomic) UIBarButtonItem *item;
@property (nonatomic) CGFloat buttonCenterY;

@end

@implementation ATLMessageInputToolbar

NSString *const ATLMessageInputToolbarAccessibilityLabel = @"Message Input Toolbar";

// Compose View Margin Constants
static CGFloat const ATLLeftButtonHorizontalMargin = 6;
static CGFloat const ATLRightButtonHorizontalMargin = 4;
static CGFloat const ATLVerticalMargin = 7;

// Compose View Button Constants
static CGFloat const ATLLeftAccessoryButtonWidth = 40;
static CGFloat const ATLRightAccessoryButtonWidth = 46;
static CGFloat const ATLButtonHeight = 28;

- (id)init
{
    self = [super init];
    if (self) {
        self.accessibilityLabel = ATLMessageInputToolbarAccessibilityLabel;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        self.leftAccessoryButton = [[UIButton alloc] init];
        self.leftAccessoryButton.accessibilityLabel = @"Camera Button";
        self.leftAccessoryButton.contentMode = UIViewContentModeScaleAspectFit;
        [self.leftAccessoryButton setImage:[UIImage imageNamed:@"AtlasResource.bundle/camera_dark"] forState:UIControlStateNormal];
        [self.leftAccessoryButton addTarget:self action:@selector(leftAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftAccessoryButton];
        
        self.textInputView = [[ATLMessageComposeTextView alloc] init];
        self.textInputView.delegate = self;
        self.textInputView.layer.borderColor = ATLGrayColor().CGColor;
        self.textInputView.layer.borderWidth = 0.5;
        self.textInputView.layer.cornerRadius = 5.0f;
        self.textInputView.accessibilityLabel = @"Text Input View";
        [self addSubview:self.textInputView];
        
        self.rightAccessoryButton = [[UIButton alloc] init];
        [self.rightAccessoryButton addTarget:self action:@selector(rightAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightAccessoryButton];
        [self configureRightAccessoryButtonState];
        [self configureButtonEnablement];

        // Calling sizeThatFits: or contentSize on the displayed UITextView causes the cursor's position to momentarily appear out of place and prevent scrolling to the selected range. So we use another text view for height calculations.
        self.dummyTextView = [[ATLMessageComposeTextView alloc] init];

        self.maxNumberOfLines = 8;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // We layout the views manually since using Auto Layout seems to cause issues in this context (i.e. an auto height resizing text view in an input accessory view) especially with iOS 7.1.
    CGRect frame = self.frame;
    CGRect leftButtonFrame = self.leftAccessoryButton.frame;
    CGRect rightButtonFrame = self.rightAccessoryButton.frame;
    CGRect textViewFrame = self.textInputView.frame;

    leftButtonFrame.size.width = ATLLeftAccessoryButtonWidth;
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
            [self insertImage:image];
        }
        return;
    }
    [super paste:sender];
}

#pragma mark - Public Methods

- (void)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines
{
    _maxNumberOfLines = maxNumberOfLines;
    self.textViewMaxHeight = self.maxNumberOfLines * self.textInputView.font.lineHeight;
    [self setNeedsLayout];
}

- (void)insertImage:(UIImage *)image
{
    UITextView *textView = self.textInputView;

    NSMutableAttributedString *attributedString = [textView.attributedText mutableCopy];
    NSAttributedString *lineBreak = [[NSAttributedString alloc] initWithString:@"\n" attributes:@{NSFontAttributeName: self.textInputView.font}];
    if (attributedString.length > 0 && ![textView.text hasSuffix:@"\n"]) {
        [attributedString appendAttributedString:lineBreak];
    }

    ATLMediaAttachment *textAttachment = [ATLMediaAttachment new];
    textAttachment.image = image;
    NSMutableAttributedString *attachmentString = [[NSAttributedString attributedStringWithAttachment:textAttachment] mutableCopy];
    [attachmentString addAttribute:NSFontAttributeName value:textView.font range:NSMakeRange(0, attachmentString.length)];
    [attributedString appendAttributedString:attachmentString];

    [attributedString appendAttributedString:lineBreak];

    textView.attributedText = attributedString;
    if ([self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidType:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidType:self];
    }
    [self setNeedsLayout];
    [self configureRightAccessoryButtonState];
}

- (NSArray *)messageParts
{
    NSAttributedString *attributedString = self.textInputView.attributedText;
    if (!_messageParts || ![attributedString isEqualToAttributedString:self.attributedStringForMessageParts]) {
        self.attributedStringForMessageParts = attributedString;
        self.messageParts = [self messagePartsFromAttributedString:attributedString];
    }
    return _messageParts;
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
    self.messageParts = nil;
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
    [self configureButtonEnablement];
    
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

- (NSArray *)messagePartsFromAttributedString:(NSAttributedString *)attributedString
{
    NSMutableArray *messageParts = [NSMutableArray new];
    [attributedString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id attachment, NSRange range, BOOL *stop) {
        if ([attachment isKindOfClass:[ATLMediaAttachment class]]) {
            ATLMediaAttachment *mediaAttachment = (ATLMediaAttachment *)attachment;
            [messageParts addObject:mediaAttachment.image];
            return;
        }
        NSAttributedString *attributedSubstring = [attributedString attributedSubstringFromRange:range];
        NSString *substring = attributedSubstring.string;
        NSString *trimmedSubstring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmedSubstring.length == 0) return;
        [messageParts addObject:trimmedSubstring];
    }];
    return messageParts;
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
        self.rightAccessoryButton.accessibilityLabel = @"Send Button";
        [self.rightAccessoryButton setImage:nil forState:UIControlStateNormal];
        self.rightAccessoryButton.contentEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
        self.rightAccessoryButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [self.rightAccessoryButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.rightAccessoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self.rightAccessoryButton setTitleColor:ATLBlueColor() forState:UIControlStateNormal];
    } else {
        self.rightAccessoryButton.accessibilityLabel = @"Location Button";
        [self.rightAccessoryButton setTitle:nil forState:UIControlStateNormal];
        self.rightAccessoryButton.contentEdgeInsets = UIEdgeInsetsZero;
        [self.rightAccessoryButton setImage:[UIImage imageNamed:@"AtlasResource.bundle/location_dark"] forState:UIControlStateNormal];
    }
}

- (void)configureButtonEnablement
{
    self.leftAccessoryButton.enabled = [self shouldEnableSendButton];
    self.rightAccessoryButton.enabled = [self shouldEnableSendButton];
}

- (BOOL)shouldEnableSendButton
{
    return YES;
}

@end
