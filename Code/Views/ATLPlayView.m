//
//  ATLPlayView.m
//  Pods
//
//  Created by Layer on 7/21/15.
//
//

#import "ATLPlayView.h"

float ATLDegreeToRadians1(float degrees)
{
    return ((M_PI * degrees)/ 180);
}

@implementation ATLPlayView

- (id)initWithFrame:(CGRect)frame shape:(NSString *)shape;
{
    self = [super initWithFrame:frame];
    return self;
    
}

- (void)drawRect:(CGRect)rect {
    
    [self drawCircle];
    [self drawTriangle];
    
}

- (void)drawCircle
{
    
    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)
                                                         radius:25
                                                     startAngle:0
                                                       endAngle:ATLDegreeToRadians1(365)
                                                      clockwise:YES];
    UIColor *grayTransparentColor = [UIColor colorWithWhite:.7 alpha:.8];
    [grayTransparentColor setFill];
    [aPath closePath];
    [aPath fill];

}

-(void)drawTriangle
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineWidth = 2.0;
    
    [bezierPath moveToPoint:CGPointMake(4.5/10.0 * self.frame.size.width, 3.5/10.0 * self.frame.size.height)];
    [bezierPath addLineToPoint:CGPointMake(4.5/10.0 *self.frame.size.width, 6.5/10.0 * self.frame.size.height)];
    [bezierPath addLineToPoint:CGPointMake(6.5/10.0 * self.frame.size.width, 5/10.0 * self.frame.size.height)];
    [[UIColor blackColor] setFill];
    [bezierPath closePath];
    [bezierPath fill];
    
}

-(void)setHiddenValue:(BOOL)hidden
{
    self.hidden = hidden;
}

@end
