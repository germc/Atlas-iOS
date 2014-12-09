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

+ (id)sharedStore;

- (void)insertConversation:(LYRConversationMock *)conversation;

- (void)updateConversation:(LYRConversationMock *)conversation;

- (void)deleteConversation:(LYRConversationMock *)conversation;

- (LYRConversationMock *)conversationForIdentifier:(NSURL *)identifier;

- (NSOrderedSet *)allConversations;

- (void)hydrateConversationsWithCount:(NSUInteger)count;

@end
