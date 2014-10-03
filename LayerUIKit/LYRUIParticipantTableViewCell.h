//
//  LYRUIParticipantTableViewCell.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRUIParticipantPresenting.h"
#import "LYRUIParticipant.h"    

/**
 @abstract The `LYRUIParticipantTableViewCell` class provides a lightweight, customizable table
 view cell for presenting Layer conversation participants.
 */
@interface LYRUIParticipantTableViewCell : UITableViewCell <LYRUIParticipantPresenting>

@property (nonatomic) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIFont *subtitleFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *subtitleColor UI_APPEARANCE_SELECTOR;

@end
