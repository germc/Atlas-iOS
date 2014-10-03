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

/**
 @abstract The `LYRUIMessageCollectionViewCell` class provides a lightweight, customizable collection
 view cell for presenting Layer message objects. The class is subclassed by by the LYRUIIncomingMessageCollectionViewCell`
 and the `LYRUIOutgoingMessageCollectionViewCell
 */
@interface LYRUIMessageCollectionViewCell : UICollectionViewCell <LYRUIMessagePresenting>

/**
 @abstract Customization selectors for configuring cell appearance
 */
@property (nonatomic) UIFont *messageTextFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *messageTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *bubbleViewColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The cell `Bubble View` which handles displaying the cell content
 */
@property (nonatomic) LYRUIMessageBubbleView *bubbleView;

/**
 @abstract The optional avatar image view representing a user
 */
@property (nonatomic) UIImageView *avatarImage;

@end