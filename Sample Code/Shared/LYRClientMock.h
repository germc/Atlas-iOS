//
//  LYRClientMock.h
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayerKitMock.h"

@class LYRConversationMock, LYRMessageMock, LYRQueryMock, LYRQueryControllerMock;

@interface LYRClientMock : NSObject

@property (nonatomic, readonly) NSString *authenticatedUserID;
@property (nonatomic, weak) id<LYRClientDelegate> delegate;

+ (instancetype)layerClientMockWithAuthenticatedUserID:(NSString *)authenticatedUserID;
+ (instancetype)layerClientMockWithAuthenticatedUserID:(NSString *)authenticatedUserID conversations:(NSArray *)conversations;

///------------------------------------------------
/// @name LYRClient's Public API - Sending changes
///------------------------------------------------

- (LYRConversationMock *)newConversationWithParticipants:(NSSet *)participants options:(NSDictionary *)options error:(NSError **)error;
- (LYRMessageMock *)newMessageWithParts:(NSArray *)messageParts options:(NSDictionary *)options error:(NSError **)error;
- (NSOrderedSet *)executeQuery:(LYRQuery *)query error:(NSError **)error;
- (NSUInteger)countForQuery:(LYRQuery *)query error:(NSError **)error;
- (LYRQueryControllerMock *)queryControllerWithQuery:(LYRQueryMock *)query; 

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


