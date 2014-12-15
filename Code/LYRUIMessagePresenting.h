//
//  LYRUIMessagePresenting.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRUIParticipant.h"
#import <LayerKit/LayerKit.h>

/**
 @abstract The `LYRUIMessagePresenting` protocol must be adopted by objects wishing to present
 Layer message parts via a user interface.
 */
@protocol LYRUIMessagePresenting <NSObject>

/**
 @abstract Tells the receiver to display a message.
 */
- (void)presentMessage:(LYRMessage *)message;

/**
 @abstract Tells the receiver if the message has been sent.
 */
- (void)updateWithMessageSentState:(BOOL)messageSentState;

/**
 @abstract Informs the receiver of its participant.
 */
- (void)updateWithParticipant:(id<LYRUIParticipant>)participant;

/**
 @abstract Tells the receiver if it should display an avatar image.
 */
- (void)shouldDisplayAvatarImage:(BOOL)shouldDisplayAvatarImage;

/**
 @abstract Tells the receiver if the cell is in a group conversation.
 */
- (void)isGroupConversation:(BOOL)isGroupConversation;

@end
