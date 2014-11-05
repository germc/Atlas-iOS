//
//  LYRClientMock.h
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

@class LYRConversationMock, LYRMessageMock;

@interface LYRClientMock : NSObject

@property (nonatomic, readonly) NSString *authenticatedUserID;
@property (nonatomic, weak) id<LYRClientDelegate> delegate;

+ (instancetype)layerClientMockWithAuthenticatedUserID:(NSString *)authenticatedUserID;
+ (instancetype)layerClientMockWithAuthenticatedUserID:(NSString *)authenticatedUserID conversations:(NSArray *)conversations;

///------------------------------------------------
/// @name LYRClient's Public API - Object Fetching
///------------------------------------------------

- (LYRConversationMock *)conversationForIdentifier:(NSURL *)identifier;
- (NSSet *)conversationsForIdentifiers:(NSSet *)conversationIdentifiers;
- (NSSet *)conversationsForParticipants:(NSSet *)participants;
- (NSSet *)messagesForIdentifiers:(NSSet *)messageIdentifiers;
- (NSOrderedSet *)messagesForConversation:(LYRConversationMock *)conversation;

///------------------------------------------------
/// @name LYRClient's Public API - Sending changes
///------------------------------------------------

- (BOOL)sendMessage:(LYRMessageMock *)message error:(NSError **)error;
- (BOOL)markMessageAsRead:(LYRMessageMock *)message error:(NSError **)error;
- (BOOL)setMetadata:(NSDictionary *)metadata onObject:(id)object;
- (BOOL)addParticipants:(NSSet *)participants toConversation:(LYRConversationMock *)conversation error:(NSError **)error;
- (BOOL)removeParticipants:(NSSet *)participants fromConversation:(LYRConversationMock *)conversation error:(NSError **)error;
- (BOOL)deleteMessage:(LYRMessageMock *)message mode:(LYRDeletionMode)deletionMode error:(NSError **)error;
- (BOOL)deleteConversation:(LYRConversationMock *)conversation mode:(LYRDeletionMode)deletionMode error:(NSError **)error;
- (void)sendTypingIndicator:(LYRTypingIndicator)typingIndicator toConversation:(LYRConversationMock *)conversation;

///------------------------------------------
/// @name LYRClient Mocking incoming changes
///------------------------------------------

- (void)receiveMessage:(LYRMessageMock *)receivedMessage;
- (void)receiveMessages:(NSArray *)receivedMessages;
- (void)receiveMessageRecipientStatusChangeForMessage:(LYRMessageMock *)message recipientStatus:(LYRRecipientStatus)recipientStatus userID:(NSString *)userID;
- (void)receiveMessageMetadataChangeForMessage:(LYRMessageMock *)message metadata:(NSDictionary *)metadata;
- (void)receiveMessageDeletion:(LYRMessageMock *)message;
- (void)receiveConversationParticipantsAdded:(NSSet *)participantsAdded toConversation:(LYRConversationMock *)conversation;
- (void)receiveConversationParticipantsRemoved:(NSSet *)participantsRemoved fromConversation:(LYRConversationMock *)conversation;
- (void)receiveConversationMetadataChangeForMessage:(LYRConversationMock *)conversation metadata:(NSDictionary *)metadata;
- (void)receiveConversationDeletion:(LYRConversationMock *)conversation;
- (void)receiveTypingIndicator:(LYRTypingIndicator)typingIndicator fromParticipant:(NSString *)userID conversation:(LYRConversationMock *)conversation;

@end

@interface LYRConversationMock : NSObject

@property (nonatomic, readonly) NSURL *identifier;
@property (nonatomic, readonly) NSSet *participants;
@property (nonatomic, readonly) NSDate *createdAt;
@property (nonatomic, readonly) LYRMessageMock *lastMessage;
@property (nonatomic, readonly) BOOL isDeleted;
@property (nonatomic, readonly) NSDictionary *metadata;

+ (instancetype)conversationWithParticipants:(NSSet *)participants;

@end

@interface LYRMessageMock : NSObject

@property (nonatomic, readonly) NSURL *identifier;
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) LYRConversationMock *conversation;
@property (nonatomic, readonly) NSArray *parts;
@property (nonatomic, readonly) BOOL isSent;
@property (nonatomic, readonly) BOOL isDeleted;
@property (nonatomic, readonly) NSDate *sentAt;
@property (nonatomic, readonly) NSDate *receivedAt;
@property (nonatomic, readonly) NSString *sentByUserID;
@property (nonatomic, readonly) NSDictionary *recipientStatusByUserID;
@property (nonatomic, readonly) NSDictionary *metadata;

+ (instancetype)messageWithConversation:(LYRConversationMock *)conversation parts:(NSArray *)messageParts;
+ (instancetype)messageWithConversation:(LYRConversationMock *)conversation parts:(NSArray *)messageParts userID:(NSString *)userID;
- (LYRRecipientStatus)recipientStatusForUserID:(NSString *)userID;
- (void)setRecipientStatus:(LYRRecipientStatus)recipientStatus forUserID:(NSString *)userID;

@end
