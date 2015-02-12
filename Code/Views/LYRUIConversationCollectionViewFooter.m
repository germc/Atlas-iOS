//
//  LYRUIConversationCollectionViewFooter.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import "LYRUIConversationCollectionViewFooter.h"
#import "LYRUIConstants.h"
#import "LYRUIMessagingUtilities.h"

@interface LYRUIConversationCollectionViewFooter ()

@property (nonatomic) UILabel *recipientStatusLabel;

@property (nonatomic) NSLayoutConstraint *recipientStatusLabelWidthConstraint;
@property (nonatomic) NSLayoutConstraint *recipientStatusLabelHeightConstraint;

@end

@implementation LYRUIConversationCollectionViewFooter

NSString *const LYRUIConversationViewFooterIdentifier = @"LYRUIConversationViewFooterIdentifier";
CGFloat const LYRUIConversationViewFooterTopPadding = 2;
CGFloat const LYRUIConversationViewFooterBottomPadding = 7;
CGFloat const LYRUIConversationViewFooterEmptyHeight = 2;

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

+ (CGFloat)footerHeightWithRecipientStatus:(NSAttributedString *)recipientStatus
{
    if (!recipientStatus.length) return LYRUIConversationViewFooterEmptyHeight;
    UIFont *defaultFont = [self defaultRecipientStatusFont];
    NSAttributedString *recipientStatusWithDefaultFont = [self attributedStringWithDefaultFont:defaultFont attributedString:recipientStatus];
    CGFloat recipientStatusHeight = [self heightForAttributedString:recipientStatusWithDefaultFont];
    return LYRUIConversationViewFooterTopPadding + ceil(recipientStatusHeight) + LYRUIConversationViewFooterBottomPadding;
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
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:LYRUIConversationViewFooterTopPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20]];
    NSLayoutConstraint *recipientStatusLabelRightConstraint = [NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];
    // To work around an apparent system bug that initially requires the view to have zero width, instead of a required priority, we use a priority one higher than the content compression resistance.
    recipientStatusLabelRightConstraint.priority = UILayoutPriorityDefaultHigh + 1;
    [self addConstraint:recipientStatusLabelRightConstraint];
}

@end
