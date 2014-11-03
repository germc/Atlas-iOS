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

- (void)testAddMessages
{
    LYRClientMock *client = [LYRClientMock layerClientMockWithAuthenticatedUserID:@"Alice"];
    LYRConversationMock *conversation = [LYRConversationMock conversationWithParticipants:[NSSet setWithObjects:@"Alice", @"Bob", @"Carol", nil]];
    LYRMessageMock *message1 = [LYRMessageMock messageWithConversation:conversation parts:@[[LYRMessagePart messagePartWithText:@"sup, buddy?"]]];
    LYRMessageMock *message2 = [LYRMessageMock messageWithConversation:conversation parts:@[[LYRMessagePart messagePartWithText:@"you there?"]]];
    [client receiveMessages:@[message1, message2]];
    
    NSSet *messages = [client messagesForIdentifiers:nil];
    expect(messages.count).to.equal(2);
}

- (void)testMessagesIndexInConversationPreserved
{
    LYRClientMock *client = [LYRClientMock layerClientMockWithAuthenticatedUserID:@"Alice"];
    LYRConversationMock *conversation = [LYRConversationMock conversationWithParticipants:[NSSet setWithObjects:@"Alice", @"Bob", @"Carol", nil]];
    LYRMessageMock *message1 = [LYRMessageMock messageWithConversation:conversation parts:@[[LYRMessagePart messagePartWithText:@"sup, buddy?"]]];
    LYRMessageMock *message2 = [LYRMessageMock messageWithConversation:conversation parts:@[[LYRMessagePart messagePartWithText:@"you there?"]]];
    [client receiveMessages:@[message1, message2]];
    
    NSOrderedSet *messages = [client messagesForConversation:conversation];
    expect(messages.count).to.equal(2);
    expect([messages[0] index]).to.equal(1);
    expect([messages[1] index]).to.equal(2);
    expect(conversation.lastMessage).to.equal(message2);
}

- (void)testDeletingMessagesReindexesIndexOrder
{
    LYRClientMock *client = [LYRClientMock layerClientMockWithAuthenticatedUserID:@"Alice"];
    LYRConversationMock *conversation = [LYRConversationMock conversationWithParticipants:[NSSet setWithObjects:@"Alice", @"Bob", @"Carol", nil]];
    LYRMessageMock *message1 = [LYRMessageMock messageWithConversation:conversation parts:@[[LYRMessagePart messagePartWithText:@"sup, buddy?"]]];
    LYRMessageMock *message2 = [LYRMessageMock messageWithConversation:conversation parts:@[[LYRMessagePart messagePartWithText:@"you there?"]]];
    [client receiveMessages:@[message1, message2]];
    
    [client receiveMessageDeletion:message1];
    
    NSOrderedSet *messages = [client messagesForConversation:conversation];
    expect(messages.count).to.equal(1);
    expect([messages[0] index]).to.equal(1);
    expect(messages[0]).to.equal(message2);
    expect(conversation.lastMessage).to.equal(message2);
}

- (void)testFetchingConversationByIdentifier
{
    LYRClientMock *client = [LYRClientMock layerClientMockWithAuthenticatedUserID:@"Alice"];
    LYRConversationMock *conversation1 = [LYRConversationMock conversationWithParticipants:[NSSet setWithObjects:@"Alice", @"Bob", @"Carol", nil]];
    LYRMessageMock *message1 = [LYRMessageMock messageWithConversation:conversation1 parts:@[[LYRMessagePart messagePartWithText:@"sup, buddy?"]]];

    LYRConversationMock *conversation2 = [LYRConversationMock conversationWithParticipants:[NSSet setWithObjects:@"Alice", @"Carol", nil]];
    LYRMessageMock *message2 = [LYRMessageMock messageWithConversation:conversation2 parts:@[[LYRMessagePart messagePartWithText:@"you there?"]]];
    [client receiveMessages:@[message1, message2]];
    
    LYRConversationMock *fetchedConversation = [client conversationForIdentifier:conversation1.identifier];
    expect(conversation1).to.equal(fetchedConversation);
    
    LYRConversationMock *fetchedConversation2 = [client conversationForIdentifier:conversation2.identifier];
    expect(conversation2).to.equal(fetchedConversation2);
}

- (void)testFetchingConversationForParticipants
{
    LYRClientMock *client = [LYRClientMock layerClientMockWithAuthenticatedUserID:@"Alice"];
    LYRConversationMock *conversation1 = [LYRConversationMock conversationWithParticipants:[NSSet setWithObjects:@"Alice", @"Bob", @"Carol", nil]];
    LYRMessageMock *message1 = [LYRMessageMock messageWithConversation:conversation1 parts:@[[LYRMessagePart messagePartWithText:@"sup, buddy?"]]];
    
    LYRConversationMock *conversation2 = [LYRConversationMock conversationWithParticipants:[NSSet setWithObjects:@"Alice", @"Carol", nil]];
    LYRMessageMock *message2 = [LYRMessageMock messageWithConversation:conversation2 parts:@[[LYRMessagePart messagePartWithText:@"you there?"]]];
    [client receiveMessages:@[message1, message2]];
    
    NSSet *conversations1 = [client conversationsForParticipants:[NSSet setWithObjects:@"Alice", @"Bob", @"Carol", nil]];
    expect(conversations1.count).to.equal(1);
    
    LYRConversationMock *fetchedConversation = conversations1.anyObject;
    expect(conversation1).to.equal(fetchedConversation);
    
    NSSet *conversations2 = [client conversationsForParticipants:[NSSet setWithObjects:@"Alice", @"Carol", nil]];
    expect(conversations2.count).to.equal(1);
    
    LYRConversationMock *fetchedConversation2 = conversations2.anyObject;
    expect(conversation2).to.equal(fetchedConversation2);
    
    NSSet *noConversations = [client conversationsForParticipants:[NSSet setWithObjects:@"Alice", @"Carol", @"Foobar", nil]];
    expect(conversations2.count).to.equal(1);
    
    noConversations = [client conversationsForParticipants:[NSSet setWithObjects:@"Carol", nil]];
    expect(noConversations.count).to.equal(0);
    
    noConversations = [client conversationsForParticipants:[NSSet setWithObjects:@"Foobar", nil]];
    expect(noConversations.count).to.equal(0);

    noConversations = [client conversationsForParticipants:nil];
    expect(noConversations.count).to.equal(0);
}

@end
