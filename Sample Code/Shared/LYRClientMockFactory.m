//
//  LYRClientMockFactory.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/31/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRClientMockFactory.h"
#import <LayerKit/LayerKit.h>

NSString *const LYRClientMockFactoryNameAlice       = @"Alice";
NSString *const LYRClientMockFactoryNameBob         = @"Bob";
NSString *const LYRClientMockFactoryNameCarol       = @"Carol";

@interface LYRClientMockFactory ()

@property (nonatomic, readwrite) LYRClientMock *layerClient;

@end

@interface LYRMessageMock ()

@property (nonatomic, readwrite) NSString *sentByUserID;
@property (nonatomic, readwrite) NSDate *sentAt;
@property (nonatomic, readwrite) NSDate *receivedAt;

@end

@implementation LYRClientMockFactory

#pragma mark - Initializers

- (instancetype)initWithAuthenticatedUserID:(NSString *)authenticatedUserID
{
    self = [super init];
    if (self) {
        _layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:authenticatedUserID];
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Failed to call designated initializer, use %@", NSStringFromSelector(@selector(initWithAuthenticatedUserID:))]  userInfo:nil];
}

+ (instancetype)emptyClientWithAuthenticatedUserID:(NSString *)authenticatedUserID
{
    return [[LYRClientMockFactory alloc] initWithAuthenticatedUserID:authenticatedUserID];
}

- (NSString *)authenticatedUserID
{
    return self.layerClient.authenticatedUserID;
}

#pragma mark - Factory methods

+ (LYRClientMockFactory *)emptyClientForAlice
{
    return [LYRClientMockFactory emptyClientWithAuthenticatedUserID:LYRClientMockFactoryNameAlice];
}

+ (LYRClientMockFactory *)emptyClientForBob
{
    return [LYRClientMockFactory emptyClientWithAuthenticatedUserID:LYRClientMockFactoryNameBob];
}

+ (LYRClientMockFactory *)emptyClientForCarol
{
    return [LYRClientMockFactory emptyClientWithAuthenticatedUserID:LYRClientMockFactoryNameCarol];
}

+ (LYRClientMockFactory *)clientForAliceWithConversation
{
    LYRClientMockFactory *factory = [LYRClientMockFactory emptyClientWithAuthenticatedUserID:LYRClientMockFactoryNameAlice];
    [factory addConversationBetweenAliceAndBob];
    return factory;
}

#pragma mark - ParticipantID-to-user resolver

+ (LYRUserMock *)userForParticipantIdentifier:(NSString *)participantIdentifier
{
    if ([participantIdentifier isEqualToString:LYRClientMockFactoryNameAlice]) {
        return [LYRUserMock userWithFirstName:@"Alice" lastName:@"Liddell" participantIdentifier:LYRClientMockFactoryNameAlice];
    } else if ([participantIdentifier isEqualToString:LYRClientMockFactoryNameBob]) {
        return [LYRUserMock userWithFirstName:@"Bob" lastName:@"Wiley" participantIdentifier:LYRClientMockFactoryNameBob];
    } else if ([participantIdentifier isEqualToString:LYRClientMockFactoryNameCarol]) {
        return [LYRUserMock userWithFirstName:@"Carol" lastName:@"Peletier" participantIdentifier:LYRClientMockFactoryNameCarol];
    }
    return [LYRUserMock userWithFirstName:@"John" lastName:@"Doe" participantIdentifier:participantIdentifier];
}

#pragma mark - Conversation department

- (void)addConversationBetweenAliceAndBob
{
    LYRConversationMock *conversation = [LYRClientMockFactory conversationBetweenAliceAndBob];
    [self.layerClient receiveMessage:[LYRClientMockFactory messageForConversation:conversation sentByUserID:LYRClientMockFactoryNameAlice text:@"You've got a lot of explaining to do."]];
    [self.layerClient receiveMessage:[LYRClientMockFactory messageForConversation:conversation sentByUserID:LYRClientMockFactoryNameBob text:@"She told you about the noodles, didn't she?!"]];
    [self.layerClient receiveMessage:[LYRClientMockFactory messageForConversation:conversation sentByUserID:LYRClientMockFactoryNameBob text:@"NO ONE CAN PROVE I DID THAT!"]];
    [self.layerClient receiveMessage:[LYRClientMockFactory messageForConversation:conversation sentByUserID:LYRClientMockFactoryNameAlice text:@"sure, sure ..."]];
}

+ (LYRConversationMock *)conversationBetweenAliceAndBob
{
    return [LYRConversationMock conversationWithParticipants:[NSSet setWithArray:@[LYRClientMockFactoryNameAlice, LYRClientMockFactoryNameBob]]];
}

+ (LYRMessageMock *)messageForConversation:(LYRConversationMock *)conversation sentByUserID:(NSString *)sentByUserID text:(NSString *)text
{
    LYRMessageMock *message = [LYRMessageMock messageWithConversation:conversation parts:@[[LYRMessagePart messagePartWithText:text]]];
    message.sentByUserID = sentByUserID;
    message.sentAt = [NSDate date];
    message.receivedAt = [NSDate date];
    [conversation.participants enumerateObjectsUsingBlock:^(NSString *recipientUserID, BOOL *stop) {
        [message setRecipientStatus:LYRRecipientStatusRead forUserID:recipientUserID];
    }];
    return message;
}

+ (NSArray *)messagesForConversation:(LYRConversationMock *)conversation sentByUserID:(NSString *)sentByUserID textArray:(NSArray *)textArray
{
    NSMutableArray *messages = [NSMutableArray array];
    for (NSString *text in textArray) {
        [messages addObject:[LYRClientMockFactory messageForConversation:conversation sentByUserID:sentByUserID text:text]];
    }
    return messages;
}

@end
