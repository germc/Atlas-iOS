//
//  ATLClientMockTests.m
//  Atlas
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

#import <LayerKit/LayerKit.h>
#import "LYRClientMock.h"
#import "ATLTestInterface.h"

@interface LYRClientMockTests : XCTestCase

@property (nonatomic) ATLTestInterface *testInterface;
@end

@implementation LYRClientMockTests

- (void)setUp
{
    [super setUp];
    [[LYRMockContentStore sharedStore] setShouldBroadcastChanges:NO];
}

- (void)tearDown
{
    [[LYRMockContentStore sharedStore] resetContentStore];
    [super tearDown];
}

- (void)testAddMessages
{
    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    LYRClientMock *client = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    
    NSSet *participants = [NSSet setWithObject:[[ATLUserMock randomUser] participantIdentifier]];
    LYRConversationMock *conversation = [client newConversationWithParticipants:participants options:nil error:nil];
    
    LYRMessagePartMock *messagePart1 = [LYRMessagePartMock messagePartWithText:@"How are you?"];
    LYRMessageMock *message1 = [client newMessageWithParts:@[messagePart1] options:nil error:nil];
    [conversation sendMessage:message1 error:nil];
    
    LYRMessagePartMock *messagePart2 = [LYRMessagePartMock messagePartWithText:@"I am well"];
    LYRMessageMock *message2 = [client newMessageWithParts:@[messagePart2] options:nil error:nil];
    [conversation sendMessage:message2 error:nil];
    
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"conversation" predicateOperator:LYRPredicateOperatorIsEqualTo value:conversation];
    NSOrderedSet *messages = [client executeQuery:query error:nil];
    expect(messages.count).to.equal(2);
}

- (void)testFetchingConversationByIdentifier
{
    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    LYRClientMock *client = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    
    NSSet *participants = [NSSet setWithObject:[[ATLUserMock randomUser] participantIdentifier]];
    LYRConversationMock *conversation1 = [client newConversationWithParticipants:participants options:nil error:nil];
    
    LYRMessagePartMock *messagePart1 = [LYRMessagePartMock messagePartWithText:@"How are you?"];
    LYRMessageMock *message1 = [client newMessageWithParts:@[messagePart1] options:nil error:nil];
    [conversation1 sendMessage:message1 error:nil];
    
    LYRConversationMock *conversation2 = [client newConversationWithParticipants:participants options:nil error:nil];
    
    LYRMessagePartMock *messagePart2 = [LYRMessagePartMock messagePartWithText:@"How are you?"];
    LYRMessageMock *message2 = [client newMessageWithParts:@[messagePart2] options:nil error:nil];
    [conversation2 sendMessage:message2 error:nil];

    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:conversation1.identifier];
    LYRConversationMock *fetchedConversation = [[client executeQuery:query error:nil] lastObject];
    expect(conversation1).to.equal(fetchedConversation);
    
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:conversation2.identifier];
    fetchedConversation = [[client executeQuery:query error:nil] lastObject];
    expect(conversation2).to.equal(fetchedConversation);
}

@end
