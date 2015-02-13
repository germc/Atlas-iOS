//
//  LYRMockContentStore.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
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
    LYRUserMock *user = [LYRUserMock randomUser];
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
    
    LYRMessagePartMock *messagePart1 = [LYRMessagePartMock messagePartWithText:@"Hi"];
    LYRMessagePartMock *messagePart2 = [LYRMessagePartMock messagePartWithText:@"How are you?"];
    LYRMessageMock *message1 = [LYRMessageMock newMessageWithParts:@[messagePart1, messagePart2] senderID:self.authenticatedUserID];
    [conversation sendMessage:message1 error:nil];
    
    LYRMessagePartMock *messagePart3 = [LYRMessagePartMock messagePartWithText:@"Hey Man"];
    LYRMessagePartMock *messagePart4 = [LYRMessagePartMock messagePartWithText:@"I am great, how about you?"];
    LYRMessageMock *message2 = [LYRMessageMock newMessageWithParts:@[messagePart3, messagePart4] senderID:participant];
    [conversation sendMessage:message2 error:nil];
    
    LYRMessagePartMock *messagePart5 = [LYRMessagePartMock messagePartWithText:@"Doing well dude."];
    LYRMessagePartMock *messagePart6 = [LYRMessagePartMock messagePartWithText:@"Ready to dominate the niners this weekend!"];
    LYRMessageMock *message3 = [LYRMessageMock newMessageWithParts:@[messagePart5, messagePart6] senderID:self.authenticatedUserID];
    [conversation sendMessage:message3 error:nil];
    
    LYRMessagePartMock *messagePart7 = [LYRMessagePartMock messagePartWithText:@"Me too man."];
    LYRMessagePartMock *messagePart8 = [LYRMessagePartMock messagePartWithText:@"This is going to be fantastic!"];
    LYRMessageMock *message4 = [LYRMessageMock newMessageWithParts:@[messagePart7, messagePart8] senderID:participant];
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
    LYRPredicate *predicate = [LYRPredicate predicateWithProperty:@"conversation" operator:LYRPredicateOperatorIsEqualTo value:conversation];
    NSOrderedSet *message = [self fetchObjectsWithClass:[LYRMessage class] predicate:predicate sortDescriptior:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
    [message enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [(LYRMessageMock *)obj setIndex:idx];
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
        NSOrderedSet *filteredSet = [NSOrderedSet new];
        if (predicate) {
            NSPredicate *conversationPredicate = [self constructPredicateForMockPredicate:predicate];
            filteredSet = [[NSOrderedSet alloc] initWithSet:[self.conversations filteredSetUsingPredicate:conversationPredicate]];
        } else {
            filteredSet = [[NSOrderedSet alloc] initWithSet:self.conversations];
        }
        NSArray *sortedArray = [filteredSet.array sortedArrayUsingDescriptors:sortDescriptor];
        return [[NSOrderedSet alloc] initWithArray:sortedArray];;
    } else if ([objectClass isSubclassOfClass:[LYRMessage class]]) {
        NSOrderedSet *filteredSet = [NSOrderedSet new];
        if (predicate) {
            NSPredicate *messagePredicate = [self constructPredicateForMockPredicate:predicate];
            filteredSet = [[NSOrderedSet alloc] initWithSet:[self.messages filteredSetUsingPredicate:messagePredicate]];
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
            NSPredicate *predicatee = [NSPredicate predicateWithFormat:@"%@ IN SELF.%@", predicate.value, predicate.property];
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
    if (self.shouldBroadcastChanges) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LYRMockObjectsDidChangeNotification object:self.mockObjectChanges];
    }
    [self.mockObjectChanges removeAllObjects];
}

@end
