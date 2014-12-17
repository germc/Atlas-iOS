//
//  LYRUIMessageCollectionViewCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRUIMessagePresenting.h"
#import "LYRUIMessageBubbleView.h"
#import "LYRUIConstants.h"
#import "LYRUIAvatarImageView.h"

/**
 @abstract The `LYRUIMessageCollectionViewCell` class provides a lightweight, customizable collection
 view cell for presenting Layer message objects. The class is subclassed by `LYRUIIncomingMessageCollectionViewCell`
 and `LYRUIOutgoingMessageCollectionViewCell`.
 */
@interface LYRUIMessageCollectionViewCell : UICollectionViewCell <LYRUIMessagePresenting>

/**
 @abstract Customization selectors for configuring cell appearance.
 */
@property (nonatomic) UIFont *messageTextFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *messageTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *bubbleViewColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat bubbleViewCornerRadius UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat avatarImageViewCornerRadius UI_APPEARANCE_SELECTOR;

/**
 @abstract The view that handles displaying the cell content.
 */
@property (nonatomic) LYRUIMessageBubbleView *bubbleView;

/**
 @abstract The optional avatar image view representing a user.
 */
@property (nonatomic) LYRUIAvatarImageView *avatarImageView;

@end
