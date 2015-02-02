//
//  LYRUIProgressView.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 1/17/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import "LYRUIProgressView.h"

float LYRUIDegreeToRadians(float degrees)
{
    return ((M_PI * degrees)/ 180);
}

NSString *LYRUIProgressViewStringForIconStyle(LYRUIProgressViewIconStyle iconStyle)
{
    switch (iconStyle) {
        case LYRUIProgressViewIconStyleDownload:
            return @"▼";
            break;
        case LYRUIProgressViewIconStylePause:
            return @"❚❚";
            break;
        case LYRUIProgressViewIconStyleStop:
            return @"⬛︎";
            break;
        case LYRUIProgressViewIconStylePlay:
            return @"▶︎";
            break;
        case LYRUIProgressViewIconStyleError:
            return @"✕";
            break;
        default:
            return nil;
            break;
    }
}

@interface LYRUIProgressView ()

@property (nonatomic) CAShapeLayer *backRingLayer;
@property (nonatomic) CAShapeLayer *progressRingLayer;
@property (nonatomic) CATextLayer *iconLayer;
@property (nonatomic) UIBezierPath *progressArcPath;
@property (nonatomic) float borderWidth;
@property (nonatomic, readonly) float radius;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) float progress;

@end

@implementation LYRUIProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _borderWidth = 8.0f;
        _progress = 0.0f;
        _animationDuration = 0.25f;
        _backRingLayer = [CAShapeLayer layer];
        _progressRingLayer = [CAShapeLayer layer];
        _iconLayer = [CATextLayer layer];
        [self.layer addSublayer:_backRingLayer];
        [self.layer addSublayer:_progressRingLayer];
        [self.layer addSublayer:_iconLayer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
                                                        radius:self.radius / 2 - self.borderWidth / 2
                                                    startAngle:LYRUIDegreeToRadians(0 - 90)
                                                      endAngle:LYRUIDegreeToRadians(360 - 90)
                                                     clockwise:YES];
    _progressRingLayer.frame = self.bounds;
    _progressRingLayer.strokeColor = [UIColor colorWithWhite:1.0f alpha:0.7f].CGColor;
    _progressRingLayer.lineWidth = self.borderWidth;
    _progressRingLayer.path = path.CGPath;
    _progressRingLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _progressRingLayer.fillColor = [UIColor clearColor].CGColor;
    _progressRingLayer.position = CGPointMake(self.layer.frame.size.width / 2, self.layer.frame.size.height / 2);
    _progressRingLayer.strokeEnd = self.progress;

    _backRingLayer.frame = self.bounds;
    _backRingLayer.strokeColor = [UIColor colorWithWhite:1.0f alpha:0.3f].CGColor;
    _backRingLayer.lineWidth = self.borderWidth;
    _backRingLayer.path = path.CGPath;
    _backRingLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _backRingLayer.fillColor = [UIColor clearColor].CGColor;
    _backRingLayer.position = CGPointMake(self.layer.frame.size.width / 2, self.layer.frame.size.height / 2);
    _backRingLayer.strokeEnd = 1.0f;

    _iconLayer.frame = CGRectOffset(self.bounds, 0, (self.bounds.size.height / 5.5));
    _iconLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _iconLayer.foregroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f].CGColor;
    _iconLayer.alignmentMode = @"center";
    _iconLayer.opacity = self.iconStyle == LYRUIProgressViewIconStyleNone ? 0.0f : 1.0f;
    _iconLayer.string = LYRUIProgressViewStringForIconStyle(self.iconStyle) ?: @"";
}

- (float)radius
{
    return MIN(self.bounds.size.width, self.bounds.size.height);
}

- (void)setProgress:(float)newProgress animated:(BOOL)animated
{
    // Do not animate if going backwards.
//    if (animated) {
//        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
//        strokeEndAnimation.duration = self.animationDuration;
//        [strokeEndAnimation setFillMode:kCAFillModeForwards];
//        strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//        strokeEndAnimation.removedOnCompletion = YES;
//        strokeEndAnimation.fromValue = [NSNumber numberWithFloat:self.progress];
//        strokeEndAnimation.toValue = [NSNumber numberWithFloat:newProgress];
//        [self.progressRingLayer addAnimation:strokeEndAnimation forKey:@"progressStatus"];
//    }
    self.progressRingLayer.strokeEnd = newProgress;
    _progress = newProgress;
}

- (void)setIconStyle:(LYRUIProgressViewIconStyle)iconStyle
{
    if (self.iconStyle == LYRUIProgressViewIconStyleNone && iconStyle != LYRUIProgressViewIconStyleNone) {
        CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimation.duration = self.animationDuration;
        [fadeInAnimation setFillMode:kCAFillModeForwards];
        fadeInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        fadeInAnimation.removedOnCompletion = NO;
        fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        self.iconLayer.opacity = 1.0f;
        [self.iconLayer addAnimation:fadeInAnimation forKey:@"fadeIn"];
    } else if (self.iconStyle != LYRUIProgressViewIconStyleNone && iconStyle == LYRUIProgressViewIconStyleNone) {
        CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeOutAnimation.duration = self.animationDuration;
        [fadeOutAnimation setFillMode:kCAFillModeForwards];
        fadeOutAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        fadeOutAnimation.removedOnCompletion = NO;
        fadeOutAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
        fadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0f];
        self.iconLayer.opacity = 0.0f;
        [self.iconLayer addAnimation:fadeOutAnimation forKey:@"fadeOut"];
    }
    
    NSString *iconString = LYRUIProgressViewStringForIconStyle(iconStyle);
    if (iconStyle) {
        self.iconLayer.string = iconString;
    }
    _iconStyle = iconStyle;
}

@end
