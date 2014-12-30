//
//  LYRClientMockTests.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

#import <LayerKit/LayerKit.h>
#import "LYRClientMock.h"

@interface LYRClientMockTests : XCTestCase

@end

@implementation LYRClientMockTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [[LYRMockContentStore sharedStore] resetContentStore];
    [super tearDown];
}

- (void)testAddMessages
{
    LYRUserMock *user = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameCam];
    LYRClientMock *client = [LYRClientMock layerClientMockWithAuthenticatedUserID:user.participantIdentifier];
    
    NSSet *participants = [NSSet setWithObject:[[LYRUserMock randomUser] participantIdentifier]];
    LYRConversationMock *conversation = [client newConversationWithParticipants:participants options:nil error:nil];
    
    LYRMessagePartMock *messagePart1 = [LYRMessagePartMock messagePartWithText:@"How are you?"];
    LYRMessageMock *message1 = [client newMessageWithParts:@[messagePart1] options:nil error:nil];
    [conversation sendMessage:message1 error:nil];
    
    LYRMessagePartMock *messagePart2 = [LYRMessagePartMock messagePartWithText:@"I am well"];
    LYRMessageMock *message2 = [client newMessageWithParts:@[messagePart2] options:nil error:nil];
    [conversation sendMessage:message2 error:nil];
    
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"conversation" operator:LYRPredicateOperatorIsEqualTo value:conversation];
    NSOrderedSet *messages = [client executeQuery:query error:nil];
    expect(messages.count).to.equal(2);
}

- (void)testMessagesIndexInConversationPreserved
{
    LYRUserMock *user = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameCam];
    LYRClientMock *client = [LYRClientMock layerClientMockWithAuthenticatedUserID:user.participantIdentifier];
    
    NSSet *participants = [NSSet setWithObject:[[LYRUserMock randomUser] participantIdentifier]];
    LYRConversationMock *conversation = [client newConversationWithParticipants:participants options:nil error:nil];
    
    LYRMessagePartMock *messagePart1 = [LYRMessagePartMock messagePartWithText:@"How are you?"];
    LYRMessageMock *message1 = [client newMessageWithParts:@[messagePart1] options:nil error:nil];
    [conversation sendMessage:message1 error:nil];
    
    LYRMessagePartMock *messagePart2 = [LYRMessagePartMock messagePartWithText:@"I am well"];
    LYRMessageMock *message2 = [client newMessageWithParts:@[messagePart2] options:nil error:nil];
    [conversation sendMessage:message2 error:nil];
    
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
    query.predicate = [LYRPredicate predicateWithProperty:@"conversation" operator:LYRPredicateOperatorIsEqualTo value:conversation];
    NSOrderedSet *messages = [client executeQuery:query error:nil];
    expect(messages.count).to.equal(2);
    expect([messages[0] index]).to.equal(0);
    expect([messages[1] index]).to.equal(1);
    expect(conversation.lastMessage).to.equal(message2);
}

- (void)testDeletingMessagesReindexesIndexOrder
{
    LYRUserMock *user = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameCam];
    LYRClientMock *client = [LYRClientMock layerClientMockWithAuthenticatedUserID:user.participantIdentifier];
    
    NSSet *participants = [NSSet setWithObject:[[LYRUserMock randomUser] participantIdentifier]];
    LYRConversationMock *conversation = [client newConversationWithParticipants:participants options:nil error:nil];
    
    LYRMessagePartMock *messagePart1 = [LYRMessagePartMock messagePartWithText:@"How are you?"];
    LYRMessageMock *message1 = [client newMessageWithParts:@[messagePart1] options:nil error:nil];
    [conversation sendMessage:message1 error:nil];
    
    LYRMessagePartMock *messagePart2 = [LYRMessagePartMock messagePartWithText:@"I am well"];
    LYRMessageMock *message2 = [client newMessageWithParts:@[messagePart2] options:nil error:nil];
    [conversation sendMessage:message2 error:nil];
    
    [[LYRMockContentStore sharedStore] deleteMessage:message1];
    
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"conversation" operator:LYRPredicateOperatorIsEqualTo value:conversation];
    NSOrderedSet *messages = [client executeQuery:query error:nil];
    expect(messages.count).to.equal(1);
    expect([messages[0] index]).to.equal(0);
    expect(messages[0]).to.equal(message2);
    expect(conversation.lastMessage).to.equal(message2);
}

- (void)testFetchingConversationByIdentifier
{
    LYRUserMock *user = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameCam];
    LYRClientMock *client = [LYRClientMock layerClientMockWithAuthenticatedUserID:user.participantIdentifier];
    
    NSSet *participants = [NSSet setWithObject:[[LYRUserMock randomUser] participantIdentifier]];
    LYRConversationMock *conversation1 = [client newConversationWithParticipants:participants options:nil error:nil];
    
    LYRMessagePartMock *messagePart1 = [LYRMessagePartMock messagePartWithText:@"How are you?"];
    LYRMessageMock *message1 = [client newMessageWithParts:@[messagePart1] options:nil error:nil];
    [conversation1 sendMessage:message1 error:nil];
    
    LYRConversationMock *conversation2 = [client newConversationWithParticipants:participants options:nil error:nil];
    
    LYRMessagePartMock *messagePart2 = [LYRMessagePartMock messagePartWithText:@"How are you?"];
    LYRMessageMock *message2 = [client newMessageWithParts:@[messagePart2] options:nil error:nil];
    [conversation2 sendMessage:message2 error:nil];

    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:conversation1.identifier];
    LYRConversationMock *fetchedConversation = [[client executeQuery:query error:nil] lastObject];
    expect(conversation1).to.equal(fetchedConversation);
    
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:conversation2.identifier];
    fetchedConversation = [[client executeQuery:query error:nil] lastObject];
    expect(conversation2).to.equal(fetchedConversation);
}

- (void)testFetchingConversationForParticipants
{
    LYRUserMock *user = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameCam];
    LYRClientMock *client = [LYRClientMock layerClientMockWithAuthenticatedUserID:user.participantIdentifier];
    
    NSSet *participants1 = [NSSet setWithObject:[[LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby] participantIdentifier]];
    LYRConversationMock *conversation1 = [client newConversationWithParticipants:participants1 options:nil error:nil];
    
    LYRMessagePartMock *messagePart1 = [LYRMessagePartMock messagePartWithText:@"How are you?"];
    LYRMessageMock *message1 = [client newMessageWithParts:@[messagePart1] options:nil error:nil];
    [conversation1 sendMessage:message1 error:nil];
    
    NSSet *participants2 = [NSSet setWithObjects:[[LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby] participantIdentifier], [[LYRUserMock userWithMockUserName:LYRClientMockFactoryNameMarshawn] participantIdentifier], nil];
    LYRConversationMock *conversation2 = [client newConversationWithParticipants:participants2 options:nil error:nil];
    
    LYRMessagePartMock *messagePart2 = [LYRMessagePartMock messagePartWithText:@"How are you?"];
    LYRMessageMock *message2 = [client newMessageWithParts:@[messagePart2] options:nil error:nil];
    [conversation2 sendMessage:message2 error:nil];
    
    LYRQuery *query1 = [LYRQuery queryWithClass:[LYRConversation class]];
    query1.predicate = [LYRPredicate predicateWithProperty:@"participants" operator:LYRPredicateOperatorIsEqualTo value:participants1];
    NSOrderedSet *fetchedConversations1 = [client executeQuery:query1 error:nil];
    expect(fetchedConversations1.count).to.equal(1);
    
    LYRConversationMock *fetchedConversation = [fetchedConversations1 lastObject];
    expect(conversation1).to.equal(fetchedConversation);
    
    LYRQuery *query2 = [LYRQuery queryWithClass:[LYRConversation class]];
    query2.predicate = [LYRPredicate predicateWithProperty:@"participants" operator:LYRPredicateOperatorIsEqualTo value:participants2];
    NSOrderedSet *fetchedConversations2 = [client executeQuery:query2 error:nil];
    expect(fetchedConversations2.count).to.equal(1);
    
    LYRConversationMock *fetchedConversation2 = [fetchedConversations2 lastObject];
    expect(conversation2).to.equal(fetchedConversation2);
    
    LYRQuery *query3 = [LYRQuery queryWithClass:[LYRConversation class]];
    query3.predicate = [LYRPredicate predicateWithProperty:@"participants" operator:LYRPredicateOperatorIsEqualTo value:[NSSet set]];
    NSOrderedSet *fetchedConversations3 = [client executeQuery:query3 error:nil];
    expect(fetchedConversations3.count).to.equal(0);
}

@end
