 //
//  UIMessageComposeTextView.m
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

#import "ATLMessageComposeTextView.h"
#import "ATLMessagingUtilities.h"
#import "ATLConstants.h"

@interface ATLMessageComposeTextView ()

@property (nonatomic) UILabel *placeholderLabel;

@end

static NSString *const ATLPlaceholderText = @"Enter Message";

@implementation ATLMessageComposeTextView

- (id)init
{
    self = [super init];
    if (self) {
        
        self.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17],
                                                                                         NSForegroundColorAttributeName : ATLGrayColor()}];
        self.textContainerInset = UIEdgeInsetsMake(4, 4, 4, 4);
        self.font = [UIFont systemFontOfSize:17];
        self.dataDetectorTypes = UIDataDetectorTypeLink;
        self.placeholder = ATLPlaceholderText;

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
