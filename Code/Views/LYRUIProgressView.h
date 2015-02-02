//
//  LYRUIProgressView.h
//  LayerUIKit
//
//  Created by Klemen Verdnik on 1/17/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LYRUIProgressViewIconStyle) {
    LYRUIProgressViewIconStyleNone            = 0,
    LYRUIProgressViewIconStyleDownload        = 1,
    LYRUIProgressViewIconStyleStop            = 2,
    LYRUIProgressViewIconStylePause           = 3,
    LYRUIProgressViewIconStylePlay            = 4,
    LYRUIProgressViewIconStyleError           = 5,
};

@interface LYRUIProgressView : UIView

@property (nonatomic, readonly) float progress;
@property (nonatomic) LYRUIProgressViewIconStyle iconStyle;

- (void)setProgress:(float)newProgress animated:(BOOL)animated;

@end
