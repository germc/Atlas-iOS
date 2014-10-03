//
//  LYRUISelectionIndicator.m
//  Pods
//
//  Created by Kevin Coleman on 8/31/14.
//
//

#import "LYRUISelectionIndicator.h"
#import "LYRUIConstants.h"

@implementation LYRUISelectionIndicator

+ (instancetype)initWithDiameter:(CGFloat)diameter
{
    return [[self alloc] initWithDiameter:diameter];
}

- (id)initWithDiameter:(CGFloat)diameter
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = FALSE;
        self.layer.cornerRadius = diameter / 2;
        [self setBackgroundImage:[UIImage imageNamed:@"unselected-indicator"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"selection-indicator"] forState:UIControlStateHighlighted];
    }
    return self;
}


- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
}

@end
