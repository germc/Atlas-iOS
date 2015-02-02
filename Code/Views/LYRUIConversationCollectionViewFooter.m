//
//  LYRUIConversationCollectionViewFooter.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import "LYRUIConversationCollectionViewFooter.h"
#import "LYRUIConstants.h"

@interface LYRUIConversationCollectionViewFooter ()

@property (nonatomic) UILabel *recipientStatusLabel;

@property (nonatomic) NSLayoutConstraint *recipientStatusLabelWidthConstraint;
@property (nonatomic) NSLayoutConstraint *recipientStatusLabelHeightConstraint;

@end

@implementation LYRUIConversationCollectionViewFooter

NSString *const LYRUIConversationViewFooterIdentifier = @"LYRUIConversationViewFooterIdentifier";
CGFloat const LYRUIConversationViewViewFooterVericalPadding = 6;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.recipientStatusLabel = [[UILabel alloc] init];
        self.recipientStatusLabel.font = [UIFont boldSystemFontOfSize:12];
        self.recipientStatusLabel.textColor = [UIColor grayColor];
        self.recipientStatusLabel.textAlignment = NSTextAlignmentRight;
        self.recipientStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.recipientStatusLabel];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:2]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20]];
    }
    return self;
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

@end
