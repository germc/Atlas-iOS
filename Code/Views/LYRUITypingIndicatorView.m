//
//  LYRTypingIndicatorView.m
//  LayerUIKit
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
        // Make dragging on the typing indicator scroll the scroll view / keyboard.
        self.userInteractionEnabled = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        _backgroundGradientLayer = [CAGradientLayer layer];
        _backgroundGradientLayer.frame = self.bounds;
        _backgroundGradientLayer.startPoint = CGPointZero;
        _backgroundGradientLayer.endPoint = CGPointMake(0, 1);
        _backgroundGradientLayer.colors = @[
            (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
            (id)[UIColor colorWithWhite:1.0 alpha:0.75].CGColor,
            (id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor
        ];
        [self.layer addSublayer:_backgroundGradientLayer];

        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.font = LYRUIMediumFont(12);
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
