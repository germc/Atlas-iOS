//
//  LYRUIMessageBubbleView.h
//  Atlas
//
//  Created by Kevin Coleman on 9/8/14.
//  Copyright (c) 2015 Layer. All rights reserved.
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
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LYRUIProgressView.h"

extern CGFloat const LYRUIMessageBubbleLabelHorizontalPadding;
extern CGFloat const LYRUIMessageBubbleLabelVerticalPadding;
extern CGFloat const LYRUIMessageBubbleMapWidth;
extern CGFloat const LYRUIMessageBubbleMapHeight;
extern CGFloat const LYRUIMessageBubbleDefaultHeight;

/**
 @abstract Posted when a user taps a link in a message bubble.
 */
extern NSString *const LYRUIUserDidTapLinkNotification;

/**
 @abstract The `LYRUIMessageBubbleView` class provides a lightweight, customizable view that 
 handles displaying the actual message content within a collection view cell.
 @discussion The view provides support for multiple content types including text,
 images, and location data.
 */
@interface LYRUIMessageBubbleView : UIView <UIAppearanceContainer>

/**
 @abstract Tells the bubble view to display a given string.
 */
- (void)updateWithAttributedText:(NSAttributedString *)text;

/**
 @abstract Tells the bubble view to display a given image.
 */
- (void)updateWithImage:(UIImage *)image width:(CGFloat)width;

/**
 @abstract Tells the bubble view to display a map image for a given location.
 */
- (void)updateWithLocation:(CLLocationCoordinate2D)location;

/**
 @abstract Tells the bubble view to clear out the content and prepare it for reuse.
 */
- (void)prepareForReuse;

/**
 @abstract The view that handles displaying text.
 */
@property (nonatomic) UILabel *bubbleViewLabel;

/**
 @abstract The view that handles displaying an image.
 */
@property (nonatomic) UIImageView *bubbleImageView;

@end
