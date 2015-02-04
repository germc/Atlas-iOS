//
//  LYRUIProgressView.h
//  LayerUIKit
//
//  Created by Klemen Verdnik on 1/17/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LYRUIProgressViewIconStyle) {
    LYRUIProgressViewIconStyleNone,
    LYRUIProgressViewIconStyleDownload,
    LYRUIProgressViewIconStyleUpload,
    LYRUIProgressViewIconStyleStop,
    LYRUIProgressViewIconStylePause,
    LYRUIProgressViewIconStylePlay,
    LYRUIProgressViewIconStyleError,
};

@interface LYRUIProgressView : UIView

@property (nonatomic, readonly) double progress;

@property (nonatomic) LYRUIProgressViewIconStyle iconStyle;

- (void)setProgress:(double)newProgress animated:(BOOL)animated;

@end
