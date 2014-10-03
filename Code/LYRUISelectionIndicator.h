//
//  LYRUISelectionIndicator.h
//  Pods
//
//  Created by Kevin Coleman on 8/31/14.
//
//

#import <UIKit/UIKit.h>

@interface LYRUISelectionIndicator : UIButton

+ (instancetype)initWithDiameter:(CGFloat)diameter;

- (void)setHighlighted:(BOOL)highlighted;

@end
