//
//  LYRUIAddresBarView.m
//  Pods
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import "LYRUIAddressBarTextView.h"
#import "LYRUIConstants.h"
#import "LYRUIMessagingUtilities.h"

@interface LYRUIAddressBarTextView ()

@property (nonatomic) UILabel *toLabel;
@property (nonatomic) CGFloat maxHeight;

@end

@implementation LYRUIAddressBarTextView

static CGFloat const LYRUILineSpacing = 6;

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textContainerInset = UIEdgeInsetsMake(10, 0, 10, 0);

        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.firstLineHeadIndent = 28.0f;
        paragraphStyle.lineSpacing = LYRUILineSpacing;
        self.typingAttributes = @{NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: [UIColor blackColor]};
        
        self.toLabel = [UILabel new];
        self.toLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.toLabel.text = @"To:";
        self.toLabel.textColor = LSGrayColor();
        [self addSubview:self.toLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.toLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:12]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.toLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:10]];
        // Adding the constraint below works around a crash on iOS 7.1. It will be overriden by the content size.
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.toLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    [self layoutSubviews];
    if (self.contentSize.height > self.maxHeight) {
        return CGSizeMake(self.contentSize.width, self.maxHeight);
    }
    return self.contentSize;
}

- (void)setAddressBarFont:(UIFont *)addressBarFont
{
    self.font = addressBarFont;
    self.toLabel.font = addressBarFont;
    [self setUpMaxHeight];
    [self invalidateIntrinsicContentSize];
    _addressBarFont = addressBarFont;
}

- (void)setUpMaxHeight
{
    CGSize size = LYRUITextPlainSize(@" ", self.font);
    self.maxHeight = ceil(size.height) * 2 + LYRUILineSpacing + self.textContainerInset.top + self.textContainerInset.bottom;
}

@end
