//
//  ATLUIProgressView.h
//  Atlas
//
//  Created by Dinesh Kakumani on 7/21/15.
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

#import "ATLPlayView.h"
#import "ATLMessagingUtilities.h"

@interface ATLPlayView ()

@property (nonatomic) CAShapeLayer *circleLayer;
@property (nonatomic) CAShapeLayer *iconLayer;
@property (nonatomic) UIColor *defaultBackgroundRingColor;
@property (nonatomic) UIColor *defaultForegroundRingColor;
@property (nonatomic, readonly) CGFloat radius;

@end

@implementation ATLPlayView

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
    _circleLayer = [CAShapeLayer layer];
    _circleLayer.fillRule = @"even-odd";
    _iconLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_circleLayer];
    [self.layer addSublayer:_iconLayer];
    _defaultBackgroundRingColor = [UIColor colorWithWhite:0.8f alpha:0.5f];
    _defaultForegroundRingColor = [UIColor colorWithWhite:0.2f alpha:0.8f];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    
    // Draw the triangle
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:CGPointMake(center.x, center.y - self.radius / 2)];
    [triangle addLineToPoint:CGPointMake(center.x + self.radius / 2, center.y + self.radius / 2)];
    [triangle addLineToPoint:CGPointMake(center.x - self.radius / 2, center.y + self.radius / 2)];
    [triangle applyTransform:CGAffineTransformMakeScale(0.5f, 0.4f)];
    [triangle applyTransform:CGAffineTransformMakeRotation(ATLDegreeToRadians(90))];
    [triangle applyTransform:CGAffineTransformMakeTranslation(self.radius - self.radius / 4, self.radius / 4)];
    
    // Draw the circle
    UIBezierPath *arc = [UIBezierPath bezierPathWithArcCenter:center
                                                       radius:self.radius / 2
                                                   startAngle:ATLDegreeToRadians(0 - 90)
                                                     endAngle:ATLDegreeToRadians(360 - 90)
                                                    clockwise:YES];

    UIBezierPath *clippedPath = [UIBezierPath bezierPath];
    clippedPath.usesEvenOddFillRule = YES;
    [clippedPath appendPath:arc];
    [clippedPath appendPath:triangle];
    
    _circleLayer.frame = self.bounds;
    _circleLayer.path = clippedPath.CGPath;
    _circleLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _circleLayer.fillColor = _defaultBackgroundRingColor.CGColor;
    _circleLayer.position = CGPointMake(self.layer.frame.size.width / 2, self.layer.frame.size.height / 2);
    _circleLayer.strokeEnd = 1.0f;
    
    _iconLayer.frame = self.bounds;
    _iconLayer.path = triangle.CGPath;
    _iconLayer.anchorPoint = CGPointMake(0.5, 0.5);
    _iconLayer.fillColor = _defaultForegroundRingColor.CGColor;
    _iconLayer.position = CGPointMake(self.layer.frame.size.width / 2, self.layer.frame.size.height / 2);
    _iconLayer.strokeEnd = 1.0f;
}

- (CGFloat)radius
{
    return MIN(self.bounds.size.width, self.bounds.size.height);
}

- (BOOL)isUserInteractionEnabled
{
    return NO;
}

@end
