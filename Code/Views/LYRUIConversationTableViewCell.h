//
//  LYRUIConversationTableViewCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRUIConversationPresenting.h"

/**
 @abstract The `LYRUIConversationTableViewCell` class provides a lightweight, customizable table
 view cell for presenting Layer conversation objects.
 */
@interface LYRUIConversationTableViewCell : UITableViewCell <LYRUIConversationPresenting>

/**
 @abstract The font for the conversation label displayed in the cell. Default is 14pt system font.
 */
@property (nonatomic) UIFont *conversationLabelFont UI_APPEARANCE_SELECTOR;

/**
 @abstract The text color for the conversation label displayed in the cell. Default is black.
 */
@property (nonatomic) UIColor *conversationLabelColor UI_APPEARANCE_SELECTOR;

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
 @abstract The background color for the unread message indicator displayed in the cell. Default is `LYRUIBlueColor()`.
 */
@property (nonatomic) UIColor *unreadMessageIndicatorBackgroundColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The background color for the cell. Default is white.
 */
@property (nonatomic) UIColor *cellBackgroundColor UI_APPEARANCE_SELECTOR;

@end
