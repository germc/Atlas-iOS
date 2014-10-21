//
//  LSLabel.m
//  Pods
//
//  Created by Kevin Coleman on 10/20/14.
//
//

#import "LYRUILabel.h"

@interface LYRUILabel ()

@property (nonatomic) UILongPressGestureRecognizer *gestureRecognizer;

@end

@implementation LYRUILabel

- (id)init
{
    self = [super init];
    if (self) {
        
        self.userInteractionEnabled = YES;
        self.gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
        self.gestureRecognizer.minimumPressDuration = 1.0;
        self.gestureRecognizer.allowableMovement = 100.0f;
        [self addGestureRecognizer:self.gestureRecognizer];
        
    }
    return self;
}

- (void)handleTap
{
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
}

- (BOOL) canPerformAction: (SEL) action withSender: (id) sender
{
    return (action == @selector(copy:));
}

- (BOOL) canBecomeFirstResponder
{
    return YES;
}

@end
