//
//  ATLUIProgressView.m
//  Atlas
//
//  Created by Klemen Verdnik on 1/17/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
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

#import "ATLProgressView.h"
#import "ATLMessagingUtilities.h"

static NSTimeInterval const ATLProgressViewDefaultBorderWidth = 8.00f;
static NSTimeInterval const ATLProgressViewDefaultTimeInterval = 0.25f;

@interface ATLProgressView ()

@property (nonatomic) CAShapeLayer *backRingLayer;
@property (nonatomic) CAShapeLayer *progressRingLayer;
@property (nonatomic) UIColor *defaultBackgroundRingColor;
@property (nonatomic) UIColor *defaultForegroundRingColor;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, readonly) CGFloat radius;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) float progress;

@end

@implementation ATLProgressView

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
    _borderWidth = ATLProgressViewDefaultBorderWidth;
    _animationDuration = ATLProgressViewDefaultTimeInterval;
    _backRingLayer = [CAShapeLayer layer];
    _progressRingLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_backRingLayer];
    [self.layer addSublayer:_progressRingLayer];
    _defaultBackgroundRingColor = [UIColor colorWithWhite:0.8f alpha:0.5f];
    _defaultForegroundRingColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    _progress = 0.0f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
                                                        radius:self.radius / 2 - self.borderWidth / 2
                                                    startAngle:ATLDegreeToRadians(0 - 90)
                                                      endAngle:ATLDegreeToRadians(360 - 90)
                                                     clockwise:YES];
    _progressRingLayer.frame = self.bounds;
    _progressRingLayer.lineWidth = self.borderWidth;
    _progressRingLayer.path = path.CGPath;
    _progressRingLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _progressRingLayer.fillColor = [UIColor clearColor].CGColor;
    _progressRingLayer.position = CGPointMake(self.layer.frame.size.width / 2, self.layer.frame.size.height / 2);
    _progressRingLayer.strokeEnd = self.progress;
    _progressRingLayer.strokeColor = _defaultForegroundRingColor.CGColor;

    _backRingLayer.frame = self.bounds;
    _backRingLayer.lineWidth = self.borderWidth;
    _backRingLayer.path = path.CGPath;
    _backRingLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _backRingLayer.fillColor = [UIColor clearColor].CGColor;
    _backRingLayer.position = CGPointMake(self.layer.frame.size.width / 2, self.layer.frame.size.height / 2);
    _backRingLayer.strokeEnd = 1.0f;
    _backRingLayer.strokeColor = _defaultBackgroundRingColor.CGColor;
}

- (CGFloat)radius
{
    return MIN(self.bounds.size.width, self.bounds.size.height);
}

- (void)setProgress:(float)newProgress animated:(BOOL)animated
{
    // Animate only if the animation is request, and if the new value
    // is bigger than the previous one.
    if (animated) {
        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.duration = self.animationDuration;
        [strokeEndAnimation setFillMode:kCAFillModeForwards];
        strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        strokeEndAnimation.removedOnCompletion = YES;
        strokeEndAnimation.fromValue = [NSNumber numberWithFloat:self.progress];
        strokeEndAnimation.toValue = [NSNumber numberWithFloat:newProgress];
        [self.progressRingLayer addAnimation:strokeEndAnimation forKey:@"progressStatus"];
    }
    self.progressRingLayer.strokeEnd = newProgress;
    _progress = newProgress;
}

- (BOOL)isUserInteractionEnabled
{
    return NO;
}

@end
