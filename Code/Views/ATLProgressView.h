//
//  ATLUIProgressView.h
//  Atlas
//
//  Created by Klemen Verdnik on 1/17/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ATLProgressViewIconStyle) {
    ATLProgressViewIconStyleNone,
    ATLProgressViewIconStyleDownload,
    ATLProgressViewIconStyleUpload,
    ATLProgressViewIconStyleStop,
    ATLProgressViewIconStylePause,
    ATLProgressViewIconStylePlay,
    ATLProgressViewIconStyleError,
};

@interface ATLProgressView : UIView

@property (nonatomic, readonly) double progress;

@property (nonatomic) ATLProgressViewIconStyle iconStyle;

- (void)setProgress:(double)newProgress animated:(BOOL)animated;

@end
