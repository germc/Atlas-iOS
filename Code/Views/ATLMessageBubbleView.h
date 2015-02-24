//
//  ATLUIMessageBubbleView.h
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
#import "ATLProgressView.h"

extern CGFloat const ATLMessageBubbleLabelVerticalPadding;
extern CGFloat const ATLMessageBubbleLabelHorizontalPadding;
extern CGFloat const ATLMessageBubbleMapWidth;
extern CGFloat const ATLMessageBubbleMapHeight;
extern CGFloat const ATLMessageBubbleDefaultHeight;

/**
 @abstract Posted when a user taps a link in a message bubble.
 */
extern NSString *const ATLUserDidTapLinkNotification;

/**
 @abstract The `ATLMessageBubbleView` class provides a lightweight, customizable view that 
 handles displaying the actual message content within a collection view cell.
 @discussion The view provides support for multiple content types including text,
 images, and location data.
 */
@interface ATLMessageBubbleView : UIView <UIAppearanceContainer>

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
 @abstract Tells the bubble view to update the circular progress that is overlaid on top of the content.
 @param progress The progress in percent, 0.0f being at 0% and 1.0f being at a full 100%.
 @param visible Passing `YES` will make the overlay visible, `NO`
 @param animated Passing `YES` will animate the update changes (progress and visibility), `NO` performs the updates immediately.
 */
- (void)updateProgressIndicatorWithProgress:(float)progress visible:(BOOL)visible animated:(BOOL)animated;

/**
 @abstract The view that handles displaying text.
 */
@property (nonatomic) UILabel *bubbleViewLabel;

/**
 @abstract The view that handles displaying an image.
 */
@property (nonatomic) UIImageView *bubbleImageView;

@end
