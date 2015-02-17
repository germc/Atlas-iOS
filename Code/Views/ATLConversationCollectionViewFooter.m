//
//  ATLUIConversationCollectionViewFooter.m
//  Atlas
//
//  Created by Kevin Coleman on 9/10/14.
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

#import "ATLConversationCollectionViewFooter.h"
#import "ATLConstants.h"
#import "ATLMessagingUtilities.h"
#import "ATLMessageCollectionViewCell.h"

@interface ATLConversationCollectionViewFooter ()

@property (nonatomic) UILabel *recipientStatusLabel;

@property (nonatomic) NSLayoutConstraint *recipientStatusLabelWidthConstraint;
@property (nonatomic) NSLayoutConstraint *recipientStatusLabelHeightConstraint;

@end

@implementation ATLConversationCollectionViewFooter

NSString *const ATLConversationViewFooterIdentifier = @"ATLConversationViewFooterIdentifier";
CGFloat const ATLConversationViewFooterTopPadding = 2;
CGFloat const ATLConversationViewFooterEmptyHeight = 1;
CGFloat const ATLConversationViewFooterUnClusteredPadding = 7;

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
    self.recipientStatusLabel = [[UILabel alloc] init];
    self.recipientStatusLabel.font = [[self class] defaultRecipientStatusFont];
    self.recipientStatusLabel.textColor = [UIColor grayColor];
    self.recipientStatusLabel.textAlignment = NSTextAlignmentRight;
    self.recipientStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.recipientStatusLabel];
    
    [self configureRecipientStatusLabelConstraints];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.recipientStatusLabel.text = nil;
}

- (void)updateWithAttributedStringForRecipientStatus:(NSAttributedString *)recipientStatus
{
    self.recipientStatusLabel.attributedText = recipientStatus;
}

#pragma mark - Height Calculations

+ (CGFloat)footerHeightWithRecipientStatus:(NSAttributedString *)recipientStatus clustered:(BOOL)clustered
{
    CGFloat height = ATLConversationViewFooterEmptyHeight;
    if (!clustered) {
        height += ATLConversationViewFooterUnClusteredPadding;
    }
    if (!recipientStatus.length) {
        return height;
    }
    UIFont *defaultFont = [self defaultRecipientStatusFont];
    NSAttributedString *recipientStatusWithDefaultFont = [self attributedStringWithDefaultFont:defaultFont attributedString:recipientStatus];
    CGFloat recipientStatusHeight = [self heightForAttributedString:recipientStatusWithDefaultFont];
    return ATLConversationViewFooterTopPadding + ceil(recipientStatusHeight) + height;
}

+ (NSAttributedString *)attributedStringWithDefaultFont:(UIFont *)defaultFont attributedString:(NSAttributedString *)attributedString
{
    NSMutableAttributedString *attributedStringWithDefaultFont = [attributedString mutableCopy];
    [attributedStringWithDefaultFont enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0, attributedStringWithDefaultFont.length) options:0 usingBlock:^(UIFont *font, NSRange range, BOOL *stop) {
        if (font) return;
        [attributedStringWithDefaultFont addAttribute:NSFontAttributeName value:defaultFont range:range];
    }];
    return attributedStringWithDefaultFont;
}

+ (CGFloat)heightForAttributedString:(NSAttributedString *)attributedString
{
    CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                 context:nil];
    return CGRectGetHeight(rect);
}

+ (UIFont *)defaultRecipientStatusFont
{
    return [UIFont boldSystemFontOfSize:14];
}

- (void)configureRecipientStatusLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:ATLConversationViewFooterTopPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20]];
    NSLayoutConstraint *recipientStatusLabelRightConstraint = [NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-ATLMessageCellHorizontalMargin];
    // To work around an apparent system bug that initially requires the view to have zero width, instead of a required priority, we use a priority one higher than the content compression resistance.
    recipientStatusLabelRightConstraint.priority = UILayoutPriorityDefaultHigh + 1;
    [self addConstraint:recipientStatusLabelRightConstraint];
}

@end
