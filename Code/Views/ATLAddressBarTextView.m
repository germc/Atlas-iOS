//
//  ATLUIAddresBarView.m
//  Atlas
//
//  Created by Kevin Coleman on 10/27/14.
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
#import "ATLAddressBarTextView.h"
#import "ATLConstants.h"
#import "ATLMessagingUtilities.h"

NSString *const ATLAddressBarPartAttributeName = @"ATLAddressBarPart";
NSString *const ATLAddressBarNamePart = @"fullName";
NSString *const ATLAddressBarDelimiterPart = @"delimiter";

@interface ATLAddressBarTextView ()

@property (nonatomic) UILabel *toLabel;
@property (nonatomic) CGFloat maxHeight;
@property (nonatomic) NSLayoutConstraint *heightConstraint;

@end

@implementation ATLAddressBarTextView

NSString *const ATLAddressBarTextViewAccesssibilityLabel = @"Address Bar Text View";
CGFloat const ATLAddressBarTextViewIndent = 34.0f;
CGFloat const ATLAddressBarTextContainerInset = 10.0f;
static CGFloat const ATLLineSpacing = 6;

- (id)init
{
    self = [super init];
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
    _addressBarFont = ATLMediumFont(15);
    _addressBarTextColor = [UIColor blackColor];
    _addressBarHighlightColor = ATLBlueColor();
    
    self.accessibilityLabel = ATLAddressBarTextViewAccesssibilityLabel;
    self.backgroundColor = [UIColor clearColor];
    self.textContainerInset = UIEdgeInsetsMake(ATLAddressBarTextContainerInset, 0, ATLAddressBarTextContainerInset, 0);
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.firstLineHeadIndent = ATLAddressBarTextViewIndent;
    paragraphStyle.lineSpacing = ATLLineSpacing;
    self.typingAttributes = @{NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: self.addressBarTextColor};
    self.font = self.addressBarFont;
    
    self.toLabel = [UILabel new];
    self.toLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.toLabel.text = ATLLocalizedString(@"atl.addressbar.textview.tolabel.key", @"To:", nil);
    self.toLabel.textColor = [UIColor grayColor];
    self.toLabel.font = self.addressBarFont;
    [self addSubview:self.toLabel];
    
    [self configureHeightConstraint];
    [self configureToLabelConstraints];
    [self setUpMaxHeight];
}

- (void)updateConstraints
{
    CGSize size = [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame), MAXFLOAT)];
    size.height = ceil(size.height);
    if (size.height > self.maxHeight) {
        size.height = self.maxHeight;
    }
    self.heightConstraint.constant = size.height;
    [super updateConstraints];
}

- (void)setAddressBarFont:(UIFont *)addressBarFont
{
    if (!addressBarFont) return;
    self.font = addressBarFont;
    self.toLabel.font = addressBarFont;
    [self setUpMaxHeight];
    [self setNeedsUpdateConstraints];
    _addressBarFont = addressBarFont;
}

 - (void)setAddressBarTextColor:(UIColor *)addressBarTextColor
{
    if (!addressBarTextColor) return;
    _addressBarTextColor = addressBarTextColor;
    if (!self.userInteractionEnabled) return;
    NSAttributedString *attributedText = self.attributedText;
    NSMutableAttributedString *adjustedAttributedText = [attributedText mutableCopy];
    NSRange selectedRange = self.selectedRange;
    [attributedText enumerateAttributesInRange:NSMakeRange(0, attributedText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        if (attrs[ATLAddressBarNamePart]) return;
        if (attrs[ATLAddressBarDelimiterPart]) return;
        [adjustedAttributedText addAttribute:NSForegroundColorAttributeName value:addressBarTextColor range:range];
    }];
    self.attributedText = adjustedAttributedText;
    self.selectedRange = selectedRange;
}

- (void)setAddressBarHighlightColor:(UIColor *)addressBarHighlightColor
{
    if (!addressBarHighlightColor) return;
    _addressBarHighlightColor = addressBarHighlightColor;
    if (!self.userInteractionEnabled) return;
    NSAttributedString *attributedText = self.attributedText;
    NSMutableAttributedString *adjustedAttributedText = [attributedText mutableCopy];
    NSRange selectedRange = self.selectedRange;
    [attributedText enumerateAttribute:ATLAddressBarPartAttributeName inRange:NSMakeRange(0, attributedText.length) options:0 usingBlock:^(NSString *partName, NSRange range, BOOL *stop) {
        if (!partName || ![partName isEqualToString:ATLAddressBarNamePart]) return;
        [adjustedAttributedText addAttribute:NSForegroundColorAttributeName value:addressBarHighlightColor range:range];
    }];
    self.attributedText = adjustedAttributedText;
    self.selectedRange = selectedRange;
}

- (void)configureHeightConstraint
{
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
    [self addConstraint:self.heightConstraint];
}

- (void)configureToLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.toLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:14]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.toLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:10]];
    // Adding the constraint below works around a crash on iOS 7.1. It will be overriden by the content size.
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.toLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
}

- (void)setUpMaxHeight
{
    CGSize size = ATLTextPlainSize(@" ", self.font);
    self.maxHeight = ceil(size.height) * 2 + ATLLineSpacing + self.textContainerInset.top + self.textContainerInset.bottom;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // We update constraints to allow text view to properly size its height given its width.
    [self updateConstraints];
}
@end
