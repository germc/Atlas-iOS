//
//  ATLUIAvatarImageView.h
//  Atlas
//
//  Created by Kevin Coleman on 10/22/14.
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
#import "ATLAvatarItem.h"

extern CGFloat const ATLAvatarImageDiameter;

/**
 @abstract The `ATLAvatarImageView` displays a circular avatar image representing a participant in a conversation. 
 If no image is present, the image view can optionally display initials for a participant.
 */
@interface ATLAvatarImageView : UIImageView

/**
 @abstract An object conforming to the `ATLAvatarItem` protocol. 
 @disucssion The object's image or initials will be used for display in the receiver.
 */
@property (nonatomic) id<ATLAvatarItem> avatarItem;

/**
 @abstract Sets the diameter for the avatar image view. Default is 30.
 @discussion Bounds for the image view are clipped to half of the diameter to create a circular
 image.
 */
@property (nonatomic) CGFloat avatarImageViewDiameter UI_APPEARANCE_SELECTOR;

/**
 @abstract Sets the font for the avatar initials. Default is 14pt system font.
 */
@property (nonatomic) UIFont *initialsFont UI_APPEARANCE_SELECTOR;

/**
 @abstract Sets the text color for the avatar initials. Default is black.
 */
@property (nonatomic) UIColor *initialsColor UI_APPEARANCE_SELECTOR;

/**
 @abstract Sets the background color for the avatar image view. Default is light gray.
 */
@property (nonatomic) UIColor *imageViewBackgroundColor UI_APPEARANCE_SELECTOR;

/**
 @abstract Sets the avatar item, image view, and initial view to nil in preparation for reuse.
 */
- (void)resetView;

@end
