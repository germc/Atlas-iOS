//
//  LYRUIConversationPresenting.h
//  
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
#import "LYRUIAvatarItem.h"

/**
 @abstract The `LYRUIConversationPresenting` protocol must be adopted by any view component
 that wishes to present a Layer conversation object.
 */
@protocol LYRUIConversationPresenting <NSObject>

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
 @abstract Provides an object conforming to the `LYRUIAvatarItem` protocol.
 @param avatarItem The object conforming to `LYRUIAvatarItem` protocol.
 @discussion The avatarItem is used to display either an image or initials with an `LYRUIAvatarImageView`
 in an `LYRUIConversationTableViewCell.`
 */
- (void)updateWithAvatarItem:(id<LYRUIAvatarItem>)avatarItem;

@end
