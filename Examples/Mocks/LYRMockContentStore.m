//
//  ATLMockContentStore.m
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
#import "LYRMockContentStore.h"

@interface LYRMockContentStore ()

@property (nonatomic) NSMutableSet *conversations;
@property (nonatomic) NSMutableSet *messages;
@property (nonatomic) NSMutableArray *mockObjectChanges;

@end

@implementation LYRMockContentStore

+ (id)sharedStore
{
    static LYRMockContentStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] init];
    });
    return sharedStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        _conversations = [NSMutableSet new];
        _messages = [NSMutableSet new];
        _mockObjectChanges = [NSMutableArray new];
        _shouldBroadcastChanges = YES;
    }
    return self;
}

- (void)hydrateConversationsForAuthenticatedUserID:(NSString *)authenticatedUserID count:(NSUInteger)count
{
    self.authenticatedUserID = authenticatedUserID;
    for (int i = 0; i < count; i++) {
        [self hydrateConversationForAuthenticatedUserID:authenticatedUserID];
    }
}

- (void)hydrateConversationForAuthenticatedUserID:(NSString *)authenticatedUserID
{
    self.authenticatedUserID = authenticatedUserID;
    ATLUserMock *user = [ATLUserMock randomUser];
    LYRConversationMock *conversation = [LYRConversationMock newConversationWithParticipants:[NSSet setWithObjects:user.participantIdentifier, self.authenticatedUserID, nil] options:nil];
    [self hydrateMessagesForConversation:conversation];
}

- (void)resetContentStore
{
    [self.conversations removeAllObjects];
    [self.messages removeAllObjects];
    [self.mockObjectChanges removeAllObjects];
}

- (void)hydrateMessagesForConversation:(LYRConversationMock *)conversation
{
    // Get the other participants ID
    NSMutableSet *participantCopy = [conversation.participants mutableCopy];
    [participantCopy minusSet:[NSSet setWithObject:self.authenticatedUserID]];
    NSString *participant = [[participantCopy allObjects] lastObject];
    
    LYRMessagePartMock *messagePart1 = [LYRMessagePartMock messagePartWithText:@"YO!"];
    [self sendMessagePart:messagePart1 toConversation:conversation fromUserID:participant];
    
    LYRMessagePartMock *messagePart2 = [LYRMessagePartMock messagePartWithText:@"Welcome to the Atlas sample project!"];
    [self sendMessagePart:messagePart2 toConversation:conversation fromUserID:participant];
    
    LYRMessagePartMock *messagePart3 = [LYRMessagePartMock messagePartWithText:@"Hey there!"];
    [self sendMessagePart:messagePart3 toConversation:conversation fromUserID:self.authenticatedUserID];
    
    LYRMessagePartMock *messagePart4 = [LYRMessagePartMock messagePartWithText:@"Thank you very much. It looks nice in here!"];
    [self sendMessagePart:messagePart4 toConversation:conversation fromUserID:self.authenticatedUserID];
    
    LYRMessagePartMock *messagePart5 = [LYRMessagePartMock messagePartWithText:@"We like to think so!"];
    [self sendMessagePart:messagePart5 toConversation:conversation fromUserID:participant];
   
    LYRMessagePartMock *messagePart6 = [LYRMessagePartMock messagePartWithText:@"If you are interested in reading more about Atlas, be sure to check out the readme at https://github.com/layerhq/Atlas-iOS!"];
    [self sendMessagePart:messagePart6 toConversation:conversation fromUserID:participant];
    
    LYRMessagePartMock *messagePart7 = [LYRMessagePartMock messagePartWithText:@"I most certainly will. Thank you for the heads up!"];
    [self sendMessagePart:messagePart7 toConversation:conversation fromUserID:self.authenticatedUserID];
    
    LYRMessagePartMock *messagePart8 = [LYRMessagePartMock messagePartWithText:@"Also if you want to learn more about Layer, be sure to check them out."];
    [self sendMessagePart:messagePart8 toConversation:conversation fromUserID:participant];
    
    LYRMessagePartMock *messagePart9 = [LYRMessagePartMock messagePartWithText:@"The website is http://www.layer.com"];
    [self sendMessagePart:messagePart9 toConversation:conversation fromUserID:participant];
    
    LYRMessagePartMock *messagePart10 = [LYRMessagePartMock messagePartWithText:@"And if you have any support issues, feel free to shoot an email to support@layer.com. They will get back to you right away!"];
    [self sendMessagePart:messagePart10 toConversation:conversation fromUserID:participant];
    
    LYRMessagePartMock *messagePart11 = [LYRMessagePartMock messagePartWithText:@"Ok! Thank you very much!"];
    [self sendMessagePart:messagePart11 toConversation:conversation fromUserID:self.authenticatedUserID];
}

- (void)sendMessagePart:(LYRMessagePartMock *)messagePart toConversation:(LYRConversationMock *)conversation fromUserID:(NSString *)userID
{
    LYRMessageMock *message4 = [LYRMessageMock newMessageWithParts:@[messagePart] senderID:userID];
    [conversation sendMessage:message4 error:nil];
}

- (void)insertConversation:(LYRConversationMock *)conversation
{
    [self.conversations addObject:conversation];
    NSDictionary *mockChangeObject = @{LYRMockObjectChangeObjectKey : conversation,
                                       LYRMockObjectChangeChangeTypeKey : [NSNumber numberWithInt:LYRObjectChangeTypeCreate]};
    [self.mockObjectChanges addObject:mockChangeObject];
}

- (void)updateConversation:(LYRConversation *)conversation
{
    NSDictionary *mockChangeObject = @{LYRMockObjectChangeObjectKey : conversation,
                                       LYRMockObjectChangeChangeTypeKey : [NSNumber numberWithInt:LYRObjectChangeTypeUpdate]};
    [self.mockObjectChanges addObject:mockChangeObject];
}

- (void)deleteConversation:(LYRConversation *)conversation
{
    [self.conversations removeObject:conversation];
    NSDictionary *mockChangeObject = @{LYRMockObjectChangeObjectKey : conversation,
                                       LYRMockObjectChangeChangeTypeKey : [NSNumber numberWithInt:LYRObjectChangeTypeDelete]};
    [self.mockObjectChanges addObject:mockChangeObject];
}

- (LYRConversationMock *)conversationForIdentifier:(NSURL *)identifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.identifier == %@", identifier];
    return [[self.conversations filteredSetUsingPredicate:predicate] anyObject];
}

- (NSOrderedSet *)allConversations
{
    return [[NSOrderedSet alloc] initWithSet:self.conversations];
}

#pragma mark - Message Methods

- (void)insertMessage:(LYRMessageMock *)message
{
    [self.messages addObject:message];
    NSDictionary *mockChangeObject = @{LYRMockObjectChangeObjectKey : message,
                                       LYRMockObjectChangeChangeTypeKey : [NSNumber numberWithInt:LYRObjectChangeTypeCreate]};
    [self.mockObjectChanges addObject:mockChangeObject];
    
    if (message.conversation.lastMessage) {
        [self updateMessage:message.conversation.lastMessage];
    }
}

- (void)updateMessage:(LYRMessageMock *)message
{
    NSDictionary *mockChangeObject = @{LYRMockObjectChangeObjectKey : message,
                                        LYRMockObjectChangeChangeTypeKey : [NSNumber numberWithInt:LYRObjectChangeTypeUpdate]};
    [self.mockObjectChanges addObject:mockChangeObject];
}

- (void)deleteMessage:(LYRMessageMock *)message
{
    [self.messages removeObject:message];
    [self reindexMessagesForConversation:message.conversation];
    NSDictionary *mockChangeObject = @{LYRMockObjectChangeObjectKey : message,
                                       LYRMockObjectChangeChangeTypeKey : [NSNumber numberWithInt:LYRObjectChangeTypeDelete]};
    [self.mockObjectChanges addObject:mockChangeObject];
}

- (LYRMessageMock *)messageForIdentifier:(NSURL *)identifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.identifier == %@", identifier];
    return [[self.conversations filteredSetUsingPredicate:predicate] anyObject];
}

- (void)reindexMessagesForConversation:(LYRConversationMock *)conversation
{
    LYRPredicate *predicate = [LYRPredicate predicateWithProperty:@"conversation" predicateOperator:LYRPredicateOperatorIsEqualTo value:conversation];
    NSOrderedSet *message = [self fetchObjectsWithClass:[LYRMessage class] predicate:predicate sortDescriptior:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
    [message enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(LYRMessageMock *)obj setPosition:idx];
    }];
}

- (NSOrderedSet *)allMessages
{
    return [[NSOrderedSet alloc] initWithSet:self.messages];
}

#pragma mark - Querying 

- (NSOrderedSet *)fetchObjectsWithClass:(Class)objectClass predicate:(LYRPredicate *)predicate sortDescriptior:(NSArray *)sortDescriptor
{
    if ([objectClass isSubclassOfClass:[LYRConversation class]]) {
        NSOrderedSet *filteredSet;
        if (predicate) {
            if ([predicate isKindOfClass:[LYRCompoundPredicate class]]) {
                filteredSet = [[NSOrderedSet alloc] initWithSet:self.conversations];
            } else {
                NSPredicate *conversationPredicate = [self constructPredicateForMockPredicate:predicate];
                filteredSet = [[NSOrderedSet alloc] initWithSet:[self.conversations filteredSetUsingPredicate:conversationPredicate]];
            }
        } else {
            filteredSet = [[NSOrderedSet alloc] initWithSet:self.conversations];
        }
        NSArray *sortedArray = [filteredSet.array sortedArrayUsingDescriptors:sortDescriptor];
        return [[NSOrderedSet alloc] initWithArray:sortedArray];;
    } else if ([objectClass isSubclassOfClass:[LYRMessage class]]) {
        NSOrderedSet *filteredSet;
        if (predicate) {
            if ([predicate isKindOfClass:[LYRCompoundPredicate class]]) {
                filteredSet = [[NSOrderedSet alloc] initWithSet:self.messages];
            } else {
                NSPredicate *messagePredicate = [self constructPredicateForMockPredicate:predicate];
                filteredSet = [[NSOrderedSet alloc] initWithSet:[self.messages filteredSetUsingPredicate:messagePredicate]];
            }
        } else {
            filteredSet = [[NSOrderedSet alloc] initWithSet:self.messages];
        }
        NSArray *sortedArray = [filteredSet.array sortedArrayUsingDescriptors:sortDescriptor];
        return [[NSOrderedSet alloc] initWithArray:sortedArray];
    }
    return nil;
}

- (NSPredicate *)constructPredicateForMockPredicate:(LYRPredicate *)predicate
{
    switch (predicate.predicateOperator) {
        case LYRPredicateOperatorIsEqualTo:
            return [NSPredicate predicateWithFormat:@"SELF.%@ == %@", predicate.property, predicate.value];

        case LYRPredicateOperatorIsNotEqualTo:
            return [NSPredicate predicateWithFormat:@"SELF.%@ != %@", predicate.property, predicate.value];

        case LYRPredicateOperatorIsLessThan:
            return [NSPredicate predicateWithFormat:@"SELF.%@ > %@", predicate.property, predicate.value];

        case LYRPredicateOperatorIsLessThanOrEqualTo:
            return [NSPredicate predicateWithFormat:@"SELF.%@ >= %@", predicate.property, predicate.value];

        case LYRPredicateOperatorIsGreaterThan:
            return [NSPredicate predicateWithFormat:@"SELF.%@ < %@", predicate.property, predicate.value];

        case LYRPredicateOperatorIsGreaterThanOrEqualTo:
            return [NSPredicate predicateWithFormat:@"SELF.%@ <= %@", predicate.property, predicate.value];

        case LYRPredicateOperatorIsIn: {
            if ([predicate.value isKindOfClass:[NSSet class]]) {
              return [NSPredicate predicateWithFormat:@"ANY SELF.%K IN %@", predicate.property, predicate.value];
            }
            NSPredicate *predicatee = [NSPredicate predicateWithFormat:@"SELF.%@ CONTAINS %@ ", predicate.property,  predicate.value];
            return predicatee;
        }
        case LYRPredicateOperatorIsNotIn:
            return [NSPredicate predicateWithFormat:@"%@ !IN SELF.%@", predicate.value, predicate.property];

        default:
            break;
    }
    return nil;
}

- (void)broadcastChanges
{
    if (self.shouldBroadcastChanges && self.mockObjectChanges.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LYRMockObjectsDidChangeNotification object:self.mockObjectChanges];
    }
    [self.mockObjectChanges removeAllObjects];
}

@end
