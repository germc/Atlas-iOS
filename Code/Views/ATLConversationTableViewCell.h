//
//  ATLUIConversationTableViewCell.h
//  Atlas
//
//  Created by Kevin Coleman on 8/29/14.
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
#import "ATLConversationPresenting.h"

/**
 @abstract The `ATLConversationTableViewCell` class provides a lightweight, customizable table
 view cell for presenting Layer conversation objects.
 */
@interface ATLConversationTableViewCell : UITableViewCell <ATLConversationPresenting>

/**
 @abstract The font for the conversation label displayed in the cell. Default is 14pt system font.
 */
@property (nonatomic) UIFont *conversationTitleLabelFont UI_APPEARANCE_SELECTOR;

/**
 @abstract The text color for the conversation label displayed in the cell. Default is black.
 */
@property (nonatomic) UIColor *conversationTitleLabelColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The font for the last message label displayed in the cell. Default is 12pt system font.
 */
@property (nonatomic) UIFont *lastMessageLabelFont UI_APPEARANCE_SELECTOR;

/**
 @abstract The text color for the last message label displayed in the cell. Default is gray.
 */
@property (nonatomic) UIColor *lastMessageLabelColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The font for the date label displayed in the cell. Default is 12pt system font.
 */
@property (nonatomic) UIFont *dateLabelFont UI_APPEARANCE_SELECTOR;

/**
 @abstract The text color for the date label displayed in the cell. Default is gray.
 */
@property (nonatomic) UIColor *dateLabelColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The background color for the unread message indicator displayed in the cell. Default is `ATLBlueColor()`.
 */
@property (nonatomic) UIColor *unreadMessageIndicatorBackgroundColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The background color for the cell. Default is white.
 */
@property (nonatomic) UIColor *cellBackgroundColor UI_APPEARANCE_SELECTOR;

@end
