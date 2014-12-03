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
#import <CoreLocation/CoreLocation.h>

@interface LYRUIMessageInputToolbar () <UITextViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSLayoutConstraint *textViewHeightConstraint;
@property (nonatomic) NSArray *messageParts;
@property (nonatomic, copy) NSAttributedString *attributedStringForMessageParts;

@end

@implementation LYRUIMessageInputToolbar

// Compose View Margin Constants
static CGFloat const LSComposeviewHorizontalMargin = 6;
static CGFloat const LSComposeviewVerticalMargin = 6;

// Compose View Button Constants
static CGFloat const LSLeftAccessoryButtonWidth = 40;
static CGFloat const LSRightAccessoryButtonWidth = 46;
static CGFloat const LSButtonHeight = 28;

- (id)init
{
    self = [super init];
    if (self) {
        self.accessibilityLabel = @"Message Input Toolbar";
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        // Setup
        self.backgroundColor =  LSLighGrayColor();
        self.canEnableSendButton = YES;

        // Initialize the Camera Button
        self.leftAccessoryButton = [[UIButton alloc] init];
        self.leftAccessoryButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.leftAccessoryButton.accessibilityLabel = @"Camera Button";
        self.leftAccessoryButton.layer.cornerRadius = 2;
        [self.leftAccessoryButton setImage:[UIImage imageNamed:@"LayerUIKitResource.bundle/camera"] forState:UIControlStateNormal];
        [self.leftAccessoryButton addTarget:self action:@selector(leftAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftAccessoryButton];
        
        // Initialize the Text Input View
        self.textInputView = [[LYRUIMessageComposeTextView alloc] init];
        self.textInputView.translatesAutoresizingMaskIntoConstraints = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.textInputView.delegate = self;
        self.textInputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.textInputView.layer.borderWidth = 1;
        self.textInputView.layer.cornerRadius = 4.0f;
        self.textInputView.accessibilityLabel = @"Text Input View";
        self.textInputView.text = LYRUIPlaceHolderText;
        [self addSubview:self.textInputView];
        
        // Initialize the Send Button
        self.rightAccessoryButton = [[UIButton alloc] init];
        self.rightAccessoryButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.rightAccessoryButton.accessibilityLabel = @"Send Button";
        self.rightAccessoryButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.rightAccessoryButton setTitle:@"SEND" forState:UIControlStateNormal];
        [self.rightAccessoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [self.rightAccessoryButton setTitleColor:LSBlueColor() forState:UIControlStateNormal];
        [self.rightAccessoryButton addTarget:self action:@selector(rightAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self configureSendButtonEnablement];
        [self addSubview:self.rightAccessoryButton];
    
        [self setupLayoutConstraints];

        // Default Max Num Lines is 8
        self.maxNumberOfLines = 8;
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(0, (self.textInputView.intrinsicContentSize.height + LSComposeviewVerticalMargin * 2));
}

- (void)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines
{
    _maxNumberOfLines = maxNumberOfLines;
    self.textInputView.maxHeight = self.maxNumberOfLines * self.textInputView.font.lineHeight;
}

#pragma mark Public Content Insertion Methods

- (void)insertImage:(UIImage *)image
{
    [self.textInputView insertImage:image];
    [self adjustFrame];
    [self configureSendButtonEnablement];
}

- (void)insertLocation:(CLLocation *)location
{
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    options.region = MKCoordinateRegionMake(location.coordinate, span);
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(200, 200);
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        UIImage *image = snapshot.image;
        MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
        UIImage *pinImage = pin.image;
        CGPoint pinPoint = CGPointMake(image.size.width/2, image.size.height/2);
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        [image drawAtPoint:CGPointMake(0, 0)];
        [pinImage drawAtPoint:pinPoint];
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self insertImage:finalImage];
    }];
}

#pragma mark Compose View Delegate Methods

- (void)leftAccessoryButtonTapped
{
    [self.inputToolBarDelegate messageInputToolbar:self didTapLeftAccessoryButton:self.leftAccessoryButton];
}

- (void)rightAccessoryButtonTapped
{
    if ([self.textInputView.text isEqualToString:LYRUIPlaceHolderText]) return;
    if ([self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidEndTyping:)]) {
        [self.inputToolBarDelegate messageInputToolbarDidEndTyping:self];
    }
    if (self.textInputView.text.length > 0) {
        [self.inputToolBarDelegate messageInputToolbar:self didTapRightAccessoryButton:self.rightAccessoryButton];
        self.rightAccessoryButton.enabled = NO;
        [self.textInputView removeAttachements];
        self.textInputView.text = @"";
        [self.textInputView layoutSubviews];
        self.messageParts = nil;
        self.attributedStringForMessageParts = nil;
        [self configureSendButtonEnablement];
    }
    [self adjustFrame];
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

#pragma mark TextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self adjustFrame];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self adjustFrame];
    [self configureSendButtonEnablement];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.text.length && (text.length == 0 && range.location == 0 && range.length == textView.text.length)) {
        // user cleared out the text
        if ([self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidEndTyping:)]) {
            [self.inputToolBarDelegate messageInputToolbarDidEndTyping:self];
        }
    } else if (text.length) {
        if ([self.inputToolBarDelegate respondsToSelector:@selector(messageInputToolbarDidBeginTyping:)]) {
            [self.inputToolBarDelegate messageInputToolbarDidBeginTyping:self];
        }
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    return YES;
}

- (void)paste:(id)sender
{
    UIImage *image = [UIPasteboard generalPasteboard].image;
    if (image) {
        [self insertImage:image];
        return;
    }
    [super paste:sender];
}

- (void)adjustFrame
{
    [self invalidateIntrinsicContentSize];
    
    // Make sure the text view always scrolls to the bottom
    CGFloat contentHeight = self.textInputView.contentSize.height;
    CGFloat height = self.textInputView.frame.size.height;
    [self.textInputView setContentOffset:CGPointMake(0, contentHeight - height)];
}

- (void)setupLayoutConstraints
{
    //**********Camera Button Constraints**********//
    // Left Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:LSComposeviewHorizontalMargin]];
    // Width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:LSLeftAccessoryButtonWidth]];

    // Height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:LSButtonHeight]];
    // Bottom Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-LSComposeviewVerticalMargin]];
    
    //**********Text Input View Constraints**********//
    // Left Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:LSComposeviewHorizontalMargin]];
    
    // Right Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.rightAccessoryButton
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:-LSComposeviewHorizontalMargin]];
    // Bottom Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-LSComposeviewVerticalMargin]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:LSComposeviewVerticalMargin]];
    
    //**********Send Button Constraints**********//
    // Width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSRightAccessoryButtonWidth]];
    
    // Right Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:-LSComposeviewVerticalMargin]];
    // Height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSButtonHeight]];
    // Bottom Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-LSComposeviewVerticalMargin]];
}

- (void)layoutSubviews
{
    [[self superview] addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.superview
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0
                                                                  constant:0]];
    [super layoutSubviews];
}

#pragma mark Send Button Enablement

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
    if ([self.textInputView.text isEqualToString:LYRUIPlaceHolderText]) return NO;
    if (self.textInputView.text.length == 0) return NO;
    return YES;
}

@end
