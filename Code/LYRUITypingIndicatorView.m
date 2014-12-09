//
//  LYRTypingIndicatorView.m
//  Pods
//
//  Created by Kevin Coleman on 11/11/14.
//
//

#import "LYRUITypingIndicatorView.h"
#import "LYRUIConstants.h"
#import "LYRUIMessagingUtilities.h"

@interface LYRUITypingIndicatorView ()

@property (nonatomic) UILabel *typingIndicatorLabel;
@property (nonatomic) CGFloat labelInset;
@property (nonatomic) NSLayoutConstraint *labelLeftConstraint;
@property (nonatomic) NSLayoutConstraint *labelWidthConstraint;
@property (nonatomic) CAGradientLayer *backgroundGradientLayer;

@end

@implementation LYRUITypingIndicatorView

- (id)init
{
    self = [super init];
    if (self) {
        CAGradientLayer *typingIndicatorBackgroundLayer = [CAGradientLayer layer];
        typingIndicatorBackgroundLayer.frame = self.bounds;
        typingIndicatorBackgroundLayer.startPoint = CGPointZero;
        typingIndicatorBackgroundLayer.endPoint = CGPointMake(0, 1);
        typingIndicatorBackgroundLayer.colors = @[(id)[[UIColor colorWithWhite:1.0 alpha:0.0] CGColor], (id)[[UIColor colorWithWhite:1.0 alpha:0.75] CGColor], (id)[[UIColor colorWithWhite:1.0 alpha:1.0] CGColor]];
        _backgroundGradientLayer = typingIndicatorBackgroundLayer;
        [self.layer addSublayer:typingIndicatorBackgroundLayer];

        _typingIndicatorLabel = [[UILabel alloc] init];
        _typingIndicatorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _typingIndicatorLabel.textColor = [UIColor lightGrayColor];
        _typingIndicatorLabel.font = LSMediumFont(12);
        _typingIndicatorLabel.textColor = [UIColor grayColor];
        _typingIndicatorLabel.numberOfLines = 0;
        _typingIndicatorLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_typingIndicatorLabel];
    }
    return self;
}

- (void)updateConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.typingIndicatorLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.typingIndicatorLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.typingIndicatorLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [super updateConstraints];
}

- (void)setText:(NSString *)text
{
    self.typingIndicatorLabel.text = text;
    [self.typingIndicatorLabel sizeToFit];
    [self setNeedsUpdateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundGradientLayer.frame = self.bounds;
}

@end
