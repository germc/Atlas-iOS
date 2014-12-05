 //
//  UIMessageComposeTextView.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIMessageComposeTextView.h"

@interface LYRUIMessageComposeTextView ()

@property (nonatomic) UILabel *placeholderLabel;

@end

static NSString *const LYRUIPlaceHolderText = @"Enter Message";

@implementation LYRUIMessageComposeTextView

- (id)init
{
    self = [super init];
    if (self) {
        self.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
        self.font = [UIFont systemFontOfSize:14];
        self.dataDetectorTypes = UIDataDetectorTypeLink;
        self.placeholder = LYRUIPlaceHolderText;

        self.placeholderLabel = [UILabel new];
        self.placeholderLabel.font = self.font;
        self.placeholderLabel.text = self.placeholder;
        self.placeholderLabel.textColor = [UIColor lightGrayColor];
        self.placeholderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.placeholderLabel];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (!self.placeholderLabel.isHidden) {
        // Position the placeholder label over where entered text would be displayed.
        CGRect placeholderFrame = self.placeholderLabel.frame;
        CGFloat textViewHorizontalIndent = 5;
        placeholderFrame.origin.x = self.textContainerInset.left + textViewHorizontalIndent;
        placeholderFrame.origin.y = self.textContainerInset.top;
        CGSize fittedPlaceholderSize = [self.placeholderLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        placeholderFrame.size = fittedPlaceholderSize;
        CGFloat maxPlaceholderWidth = CGRectGetWidth(self.frame) - self.textContainerInset.left - self.textContainerInset.right - textViewHorizontalIndent * 2;
        if (fittedPlaceholderSize.width > maxPlaceholderWidth) {
            placeholderFrame.size.width = maxPlaceholderWidth;
        }
        self.placeholderLabel.frame = placeholderFrame;

        // We want the placeholder to be overlapped by / underneath the cursor.
        [self sendSubviewToBack:self.placeholderLabel];
    }
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    self.placeholderLabel.font = font;
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self configurePlaceholderVisibility];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self configurePlaceholderVisibility];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    self.placeholderLabel.text = placeholder;
    [self setNeedsLayout];
}

#pragma mark - Notification Handlers

- (void)textViewTextDidChange:(NSNotification *)notification
{
    [self configurePlaceholderVisibility];
}

#pragma mark - Helpers

- (void)configurePlaceholderVisibility
{
    self.placeholderLabel.hidden = self.attributedText.length > 0;
}

@end
