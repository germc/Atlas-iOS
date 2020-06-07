//
//  ATLUIConversationPresenting.h
//  Atlas
//
//  Created by Kevin Coleman on 8/29/14.
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

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "ATLAvatarItem.h"

/**
 @abstract The `ATLConversationPresenting` protocol must be adopted by any view component
 that wishes to present a Layer conversation object.
 */
@protocol ATLConversationPresenting <NSObject>

/**
 @abstract Tells the receiver to present a given Layer conversation.
 @param conversation The conversation to present.
 */
- (void)presentConversation:(LYRConversation *)conversation;

/**
 @abstract Provides a string to display representing the conversation title.
 @param conversationTitle The conversation title to display.
 */
- (void)updateWithConversationTitle:(NSString *)conversationTitle;

/**
 @abstract Gives the receiver an object conforming to the `ATLAvatarItem` protocol.
 @param avatarItem The object conforming to `ATLAvatarItem` protocol.
 @discussion The avatarItem is used to display either an image or initials with an `ATLAvatarImageView`
 in an `ATLConversationTableViewCell.`
 */
- (void)updateWithAvatarItem:(id<ATLAvatarItem>)avatarItem;

/**
 @abstract Provides a string to display representing the conversation's last message.
 @param lastMessageText The last message text to display.
 */
- (void)updateWithLastMessageText:(NSString *)lastMessageText;

@end
