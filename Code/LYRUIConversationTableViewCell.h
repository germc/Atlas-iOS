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
 @abstract Customization selectors for configuring cell appearance
 */
@property (nonatomic) UIFont *conversationLabelFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *conversationLableColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIFont *lastMessageTextFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *lastMessageTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIFont *dateLabelFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *dateLabelColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

@end
