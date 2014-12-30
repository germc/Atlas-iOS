//
//  LYRMockContentStore.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
//

#import <Foundation/Foundation.h>
#import "LayerKitMock.h"

/**
 @abstract The `LYRMockContentStore` provides a simple, in-memory cache for mock Layer messaging content. The class is meant to be used
 for simple user interface testing with LayerUIKit components.
 */
@interface LYRMockContentStore : NSObject

@property (nonatomic) NSString *authenticatedUserID;

/**
 @abstract Singleton Accessor for the mock content store
 */
+ (id)sharedStore;

/**
 @abstrace Creates an arbitrary number of Layer conversations, each with 8 messages.
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

//-------------------------
// Querying
//-------------------------

- (NSOrderedSet *)fetchObjectsWithClass:(Class)objectClass predicate:(LYRPredicate *)predicate sortDescriptior:(NSArray *)sortDescriptor;

- (void)broadcastChanges;

@end
