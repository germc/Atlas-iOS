//
//  ATLUIMessageCollectionViewCell.h
//  Atlas
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
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
#import "ATLMessagePresenting.h"
#import "ATLMessageBubbleView.h"
#import "ATLConstants.h"
#import "ATLAvatarImageView.h"

extern CGFloat const ATLMessageCellHorizontalMargin;
extern NSString *const ATLGIFAccessibilityLabel;
extern NSString *const ATLImageAccessibilityLabel;

/**
 @abstract The `ATLMessageCollectionViewCell` class provides a lightweight, customizable collection
 view cell for presenting Layer message objects. The class is subclassed by `ATLIncomingMessageCollectionViewCell`
 and `ATLOutgoingMessageCollectionViewCell`.
 */
@interface ATLMessageCollectionViewCell : UICollectionViewCell <ATLMessagePresenting>

/**
 @abstract The font for text displayed in the cell. Default is 14pt system font.
 */
@property (nonatomic) UIFont *messageTextFont UI_APPEARANCE_SELECTOR;

/**
 @abstract The text color for text displayed in the cell. Default is black.
 */
@property (nonatomic) UIColor *messageTextColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The text color for links displayed in the cell. Default is blue.
 */
@property (nonatomic) UIColor *messageLinkTextColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The background color for the bubble view displayed in the cell. Default is light gray.
 */
@property (nonatomic) UIColor *bubbleViewColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The corner radius of the bubble view displayed in the cell. Default is 16.
 */
@property (nonatomic) CGFloat bubbleViewCornerRadius UI_APPEARANCE_SELECTOR;

/**
 @abstract The view that handles displaying the cell content.
 */
@property (nonatomic) ATLMessageBubbleView *bubbleView;

/**
 @abstract The optional avatar image view representing a user.
 */
@property (nonatomic) ATLAvatarImageView *avatarImageView;

/**
 @abstract Performs calculations to determine a cell's height.
 @param message The `LYRMessage` object that will be displayed in the cell.
 @param view The view where the cell will be displayed.
 @return The height for the cell.
 */
+ (CGFloat)cellHeightForMessage:(LYRMessage *)message inView:(UIView *)view;

@end
