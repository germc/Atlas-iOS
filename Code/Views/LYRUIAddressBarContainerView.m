//
//  LYRUIAddressBarContainerView.m
//  LayerUIKit
//
//  Created by Ben Blakley on 11/25/14.
//
//

#import "LYRUIAddressBarContainerView.h"
#import "LYRUIAddressBarView.h"

@implementation LYRUIAddressBarContainerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];

    // Ignore taps on this view (but allow taps on its subviews).
    if (view == self) return nil;

    return view;
}

@end
