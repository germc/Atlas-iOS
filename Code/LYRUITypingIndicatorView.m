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

        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.textColor = [UIColor lightGrayColor];
        _label.font = LSMediumFont(12);
        _label.textColor = [UIColor grayColor];
        _label.numberOfLines = 1;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:8]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-8]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundGradientLayer.frame = self.bounds;
}

@end
