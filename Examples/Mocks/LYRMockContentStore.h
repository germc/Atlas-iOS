//
//  ATLMockContentStore.h
//  Atlas
//
//  Created by Kevin Coleman on 12/8/14.
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
#import "LayerKitMock.h"

/**
 @abstract The `LYRMockContentStore` provides a simple, in-memory cache for mock Layer messaging content. The class is meant to be used
 for user interface testing with Atlas components.
 */
@interface LYRMockContentStore : NSObject

/**
 @abstract The user identifier of the currently authenticated user.
 */
@property (nonatomic) NSString *authenticatedUserID;

/**
 @abstract Defaults to `YES`. If set to `NO`, the content store will not broadcast mock `LYRObjectDidChangeNotification` change notifications.
 */
@property (nonatomic) BOOL shouldBroadcastChanges;

/**
 @abstract Singleton Accessor for the mock content store
 */
+ (id)sharedStore;

/**
 @abstrace Creates an arbitrary number of Layer conversations, each with 11 messages.
 @param authenticatedUserID The participant string representing the authenticated user.
 @param count The number of conversations to be created.
 */
- (void)hydrateConversationsForAuthenticatedUserID:(NSString *)authenticatedUserID count:(NSUInteger)count;

/**
 @abstrace Creates a single conversation for a given authenticated user
 @param authenticatedUserID The participant string representing the authenticated user.
 */
- (void)hydrateConversationForAuthenticatedUserID:(NSString *)authenticatedUserID;

/**
 @abstrace Removes all existing content from from the content store.
 */
- (void)resetContentStore;

//-------------------------
// Conversations
//-------------------------

- (void)insertConversation:(LYRConversationMock *)conversation;

- (void)updateConversation:(LYRConversationMock *)conversation;

- (void)deleteConversation:(LYRConversationMock *)conversation;

- (LYRConversationMock *)conversationForIdentifier:(NSURL *)identifier;

- (NSOrderedSet *)allConversations;

//-------------------------
// Messages
//-------------------------

- (void)insertMessage:(LYRMessageMock *)message;

- (void)updateMessage:(LYRMessageMock *)message;

- (void)deleteMessage:(LYRMessageMock *)message;

- (LYRMessageMock *)messageForIdentifier:(NSURL *)identifier;

- (NSOrderedSet *)allMessages;

//-------------------------
// Querying
//-------------------------

- (NSOrderedSet *)fetchObjectsWithClass:(Class)objectClass predicate:(LYRPredicate *)predicate sortDescriptior:(NSArray *)sortDescriptor;

- (void)broadcastChanges;

@end
