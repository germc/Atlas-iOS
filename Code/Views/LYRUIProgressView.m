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

@interface LYRUIProgressView ()

@property (nonatomic) CAShapeLayer *progressRingLayer;
@property (nonatomic) UIBezierPath *progressArcPath;
@property (nonatomic) float borderWidth;
@property (nonatomic, readonly) float radius;
@property (nonatomic) NSTimeInterval animationDuration;

@end

@implementation LYRUIProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _borderWidth = 8.0f;
        _progress = 0.0f;
        _animationDuration = 0.25f;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.progressRingLayer) {
        [self.progressRingLayer removeFromSuperlayer];
    }
    CGRect bounds = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
                                                        radius:self.radius / 2 - self.borderWidth / 2
                                                    startAngle:LYRUIDegreeToRadians(0 - 90)
                                                      endAngle:LYRUIDegreeToRadians(360 - 90)
                                                     clockwise:YES];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.strokeColor = [UIColor colorWithWhite:1.0f alpha:0.8f].CGColor;
    shapeLayer.lineWidth = self.borderWidth;
    shapeLayer.path = path.CGPath;
    shapeLayer.anchorPoint = CGPointMake(0.5, 0.5);
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.position = CGPointMake(self.layer.frame.size.width / 2, self.layer.frame.size.height / 2);
    shapeLayer.strokeEnd = 0.0f;
    
    [self.layer addSublayer:shapeLayer];
    self.progressArcPath = path;
    self.progressRingLayer = shapeLayer;
}

- (float)radius
{
    return MIN(self.bounds.size.width, self.bounds.size.height);
}

- (void)setProgress:(float)newProgress
{
    if (self.progress == 0.00f && newProgress != 0.00f) {
        // If beginning of the progress
        CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimation.duration = self.animationDuration;
        [fadeInAnimation setFillMode:kCAFillModeForwards];
        fadeInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        fadeInAnimation.removedOnCompletion = NO;
        fadeInAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
        fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        [self.progressRingLayer addAnimation:fadeInAnimation forKey:@"fadeIn"];
        
        CABasicAnimation *zoomInAnimation = [CABasicAnimation animationWithKeyPath:@"contentsScale"];
        zoomInAnimation.duration = self.animationDuration;
        [zoomInAnimation setFillMode:kCAFillModeForwards];
        zoomInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        zoomInAnimation.removedOnCompletion = NO;
        zoomInAnimation.fromValue = [NSNumber numberWithFloat:0.5f];
        zoomInAnimation.toValue = [NSNumber numberWithFloat:1.0f];
        [self.progressRingLayer addAnimation:zoomInAnimation forKey:@"zoomIn"];
    }

    // On every progress update
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.duration = self.animationDuration;
    [strokeEndAnimation setFillMode:kCAFillModeForwards];
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    strokeEndAnimation.removedOnCompletion = NO;
    strokeEndAnimation.fromValue = [NSNumber numberWithFloat:self.progress];
    strokeEndAnimation.toValue = [NSNumber numberWithFloat:newProgress];
    _progress = newProgress;
    self.progressRingLayer.strokeEnd = newProgress;
    [self.progressRingLayer addAnimation:strokeEndAnimation forKey:@"progressStatus"];

    if (self.progress != 1.00f && newProgress == 1.00f) {
        // On full progress
        CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimation.duration = self.animationDuration;
        [fadeInAnimation setFillMode:kCAFillModeForwards];
        fadeInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        fadeInAnimation.removedOnCompletion = NO;
        fadeInAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
        fadeInAnimation.toValue = [NSNumber numberWithFloat:0.0f];
        [self.progressRingLayer addAnimation:fadeInAnimation forKey:@"fadeIn"];
        
        CABasicAnimation *zoomInAnimation = [CABasicAnimation animationWithKeyPath:@"contentsScale"];
        zoomInAnimation.duration = self.animationDuration;
        [zoomInAnimation setFillMode:kCAFillModeForwards];
        zoomInAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        zoomInAnimation.removedOnCompletion = NO;
        zoomInAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
        zoomInAnimation.toValue = [NSNumber numberWithFloat:2.0f];
        [self.progressRingLayer addAnimation:zoomInAnimation forKey:@"zoomIn"];
    }
}

@end
