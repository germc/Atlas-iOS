//
//  LYRUIMessageInputToolbar.m
//  Pods
//
//  Created by Kevin Coleman on 9/18/14.
//
//

#import "LYRUIMessageInputToolbar.h"
#import "LYRUIConstants.h"
#import "LYRUIMediaAttachment.h"
#import "LYRUIMessagingUtilities.h"

NSString *const LYRUIMessageInputToolbarDidChangeHeightNotification = @"LYRUIMessageInputToolbarDidChangeHeightNotification";

@interface LYRUIMessageInputToolbar () <UITextViewDelegate>

@property (nonatomic) NSArray *messageParts;
@property (nonatomic, copy) NSAttributedString *attributedStringForMessageParts;
@property (nonatomic) UITextView *dummyTextView;
@property (nonatomic) CGFloat textViewMaxHeight;

@end

@implementation LYRUIMessageInputToolbar

// Compose View Margin Constants
static CGFloat const LYRUIHorizontalMargin = 6;
static CGFloat const LYRUIVerticalMargin = 6;

// Compose View Button Constants
static CGFloat const LYRUILeftAccessoryButtonWidth = 40;
static CGFloat const LYRUIRightAccessoryButtonWidth = 46;
static CGFloat const LYRUIButtonHeight = 28;

- (id)init
{
    self = [super init];
    if (self) {
        self.accessibilityLabel = @"Message Input Toolbar";
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor =  LYRUILightGrayColor();
        self.canEnableSendButton = YES;

        self.leftAccessoryButton = [[UIButton alloc] init];
        self.leftAccessoryButton.accessibilityLabel = @"Camera Button";
        [self.leftAccessoryButton setImage:[UIImage imageNamed:@"LayerUIKitResource.bundle/camera"] forState:UIControlStateNormal];
        [self.leftAccessoryButton addTarget:self action:@selector(leftAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftAccessoryButton];
        
        self.textInputView = [[LYRUIMessageComposeTextView alloc] init];
        self.textInputView.delegate = self;
        self.textInputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.textInputView.layer.borderWidth = 1;
        self.textInputView.layer.cornerRadius = 4.0f;
        self.textInputView.accessibilityLabel = @"Text Input View";
        [self addSubview:self.textInputView];
        
        self.rightAccessoryButton = [[UIButton alloc] init];
        self.rightAccessoryButton.accessibilityLabel = @"Send Button";
        self.rightAccessoryButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.rightAccessoryButton setTitle:@"SEND" forState:UIControlStateNormal];
        [self.rightAccessoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self.rightAccessoryButton setTitleColor:LYRUIBlueColor() forState:UIControlStateNormal];
        [self.rightAccessoryButton addTarget:self action:@selector(rightAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self configureSendButtonEnablement];
        [self addSubview:self.rightAccessoryButton];

        // Calling sizeThatFits: or contentSize on the displayed UITextView causes the cursor's position to momentarily appear out of place and prevent scrolling to the selected range. So we use another text view for height calculations.
        self.dummyTextView = [UITextView new];

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

    leftButtonFrame.size.width = LYRUILeftAccessoryButtonWidth;
    leftButtonFrame.size.height = LYRUIButtonHeight;
    leftButtonFrame.origin.x = LYRUIHorizontalMargin;

    rightButtonFrame.size.width = LYRUIRightAccessoryButtonWidth;
    rightButtonFrame.size.height = LYRUIButtonHeight;
    rightButtonFrame.origin.x = CGRectGetWidth(frame) - CGRectGetWidth(rightButtonFrame) - LYRUIVerticalMargin;

    textViewFrame.origin.x = CGRectGetMaxX(leftButtonFrame) + LYRUIHorizontalMargin;
    textViewFrame.origin.y = LYRUIVerticalMargin;
    textViewFrame.size.width = CGRectGetMinX(rightButtonFrame) - CGRectGetMinX(textViewFrame) - LYRUIHorizontalMargin;

    self.dummyTextView.font = self.textInputView.font;
    self.dummyTextView.attributedText = self.textInputView.attributedText;
    CGSize fittedTextViewSize = [self.dummyTextView sizeThatFits:CGSizeMake(CGRectGetWidth(textViewFrame), MAXFLOAT)];
    textViewFrame.size.height = MIN(fittedTextViewSize.height, self.textViewMaxHeight);

    frame.size.height = CGRectGetHeight(textViewFrame) + LYRUIVerticalMargin * 2;
    frame.origin.y -= frame.size.height - CGRectGetHeight(self.frame);

    leftButtonFrame.origin.y = CGRectGetHeight(frame) - CGRectGetHeight(leftButtonFrame) - LYRUIVerticalMargin;

    rightButtonFrame.origin.y = CGRectGetHeight(frame) - CGRectGetHeight(rightButtonFrame) - LYRUIVerticalMargin;

    self.leftAccessoryButton.frame = leftButtonFrame;
    self.rightAccessoryButton.frame = rightButtonFrame;
    self.textInputView.frame = textViewFrame;

    // Setting one's own frame like this is a no-no but seems to be the lesser of evils when working around the layout issues mentioned above.
    CGRect existingFrame = self.frame;
    if (!CGRectEqualToRect(frame, existingFrame)) {
        self.frame = frame;
        BOOL changedHeight = CGRectGetHeight(frame) != CGRectGetHeight(existingFrame);
        if (changedHeight) {
            [[NSNotificationCenter defaultCenter] postNotificationName:LYRUIMessageInputToolbarDidChangeHeightNotification object:self];
        }
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

    LYRUIMediaAttachment *textAttachment = [LYRUIMediaAttachment new];
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
    [self configureSendButtonEnablement];
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
    if (self.textInputView.text.length == 0) return;
    if ([self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidEndTyping:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidEndTyping:self];
    }
    [self.inputToolBarDelegate messageInputToolbar:self didTapRightAccessoryButton:self.rightAccessoryButton];
    self.rightAccessoryButton.enabled = NO;
    self.textInputView.text = @"";
    [self setNeedsLayout];
    self.messageParts = nil;
    self.attributedStringForMessageParts = nil;
    [self configureSendButtonEnablement];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0 && [self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidType:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidType:self];
    } else if (textView.text.length == 0 && [self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidEndTyping:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidEndTyping:self];
    }

    [self setNeedsLayout];
    [self configureSendButtonEnablement];

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
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(NSDictionary *attributes, NSRange range, BOOL *stop) {
        id attachment = attributes[NSAttachmentAttributeName];
        if ([attachment isKindOfClass:[LYRUIMediaAttachment class]]) {
            LYRUIMediaAttachment *mediaAttachment = (LYRUIMediaAttachment *)attachment;
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

#pragma mark - Send Button Enablement

- (void)setCanEnableSendButton:(BOOL)canEnableSendButton
{
    if (canEnableSendButton == _canEnableSendButton) return;
    _canEnableSendButton = canEnableSendButton;
    [self configureSendButtonEnablement];
}

- (void)configureSendButtonEnablement
{
    self.rightAccessoryButton.enabled = [self shouldEnableSendButton];
}

- (BOOL)shouldEnableSendButton
{
    if (!self.canEnableSendButton) return NO;
    NSString *text = self.textInputView.text;
    NSString *trimmedText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedText.length == 0) return NO;
    return YES;
}

@end
