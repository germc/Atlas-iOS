//
//  LYRMockContentStore.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
//

#import <Foundation/Foundation.h>
#import "LayerKitMock.h"

@interface LYRMockContentStore : NSObject

@property (nonatomic) NSString *authenticatedUserID;

+ (id)sharedStore;

- (void)hydrateConversationsForAuthenticatedUserID:(NSString *)authenticatedUserID count:(NSUInteger)count;

- (void)hydrateConversationForAuthenticatedUserID:(NSString *)authenticatedUserID;

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

- (void)broadCastChanges;

@end
