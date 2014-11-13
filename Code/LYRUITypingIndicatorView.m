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

@end

@implementation LYRUITypingIndicatorView

- (id)init
{
    self = [super init];
    if (self) {
        
        _typingIndicatorLabel = [[UILabel alloc] init];
        _typingIndicatorLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _typingIndicatorLabel.textColor = [UIColor lightGrayColor];
        _typingIndicatorLabel.font = LSMediumFont(12);
        _typingIndicatorLabel.textColor = [UIColor grayColor];
        _typingIndicatorLabel.numberOfLines = 0;
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

- (void)updateLabelInset:(NSUInteger)inset
{
//    if (self.labelLeftConstraint) {
//        [self removeConstraints:@[self.labelLeftConstraint, self.labelWidthConstraint]];
//    }
//    self.labelInset = inset;
//    [self setNeedsUpdateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    CAGradientLayer *typingIndicatorBackgroundLayer = [CAGradientLayer layer];
    typingIndicatorBackgroundLayer.frame = view .frame;
    typingIndicatorBackgroundLayer.startPoint = CGPointZero;
    typingIndicatorBackgroundLayer.endPoint = CGPointMake(0, 1);
    typingIndicatorBackgroundLayer.colors = @[(id)[[UIColor colorWithWhite:1.0 alpha:0.0] CGColor], (id)[[UIColor colorWithWhite:1.0 alpha:0.75] CGColor], (id)[[UIColor colorWithWhite:1.0 alpha:1.0] CGColor]];
    [view.layer addSublayer:typingIndicatorBackgroundLayer];
    [self addSubview:view];
    [self sendSubviewToBack:view];
}

@end
