//
//  LYRClientMock.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRClientMock.h"

#pragma mark - LYRClientMock -

@interface LYRClientMock ()

@property (nonatomic, readwrite) NSString *authenticatedUserID;
@property (nonatomic) NSMutableSet *conversations;
@property (nonatomic) NSMutableSet *messages;

@end

@interface LYRConversationMock ()

@property (nonatomic, readwrite) NSURL *identifier;
@property (nonatomic, readwrite) NSSet *participants;
@property (nonatomic, readwrite) NSDate *createdAt;
@property (nonatomic, readwrite) LYRMessageMock *lastMessage;
@property (nonatomic, readwrite) BOOL isDeleted;
@property (nonatomic, readwrite) NSMutableDictionary *mutableMetadata;

@end

@interface LYRMessageMock ()

@property (nonatomic, readwrite) NSURL *identifier;
@property (nonatomic, readwrite) NSUInteger index;
@property (nonatomic, readwrite) LYRConversationMock *conversation;
@property (nonatomic, readwrite) NSArray *parts;
@property (nonatomic, readwrite) BOOL isSent;
@property (nonatomic, readwrite) BOOL isDeleted;
@property (nonatomic, readwrite) NSDate *sentAt;
@property (nonatomic, readwrite) NSDate *receivedAt;
@property (nonatomic, readwrite) NSString *sentByUserID;
@property (nonatomic, readwrite) NSMutableDictionary *mutableRecipientStatuses;
@property (nonatomic, readwrite) NSMutableDictionary *mutableMetadata;

@end

@implementation LYRClientMock

#pragma mark Initializers

- (instancetype)initWithAuthenticatedUserID:(NSString *)authenticatedUserID
{
    self = [super init];
    if (self) {
        _authenticatedUserID = authenticatedUserID;
        _conversations = [NSMutableSet set];
        _messages = [NSMutableSet set];
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Failed to call designated initializer, use +%@", NSStringFromSelector(@selector(layerClientMockWithAuthenticatedUserID:))]  userInfo:nil];
}

+ (instancetype)layerClientMockWithAuthenticatedUserID:(NSString *)authenticatedUserID
{
    return [[LYRClientMock alloc] initWithAuthenticatedUserID:authenticatedUserID];
}

+ (instancetype)layerClientMockWithAuthenticatedUserID:(NSString *)authenticatedUserID conversations:(NSArray *)conversations;
{
    LYRClientMock *layerClientMock = [[LYRClientMock alloc] initWithAuthenticatedUserID:authenticatedUserID];
    [layerClientMock addConversationsFromArray:@[conversations]];
    return layerClientMock;
}

#pragma mark Public API - Conversation & Message retreiving

- (LYRConversationMock *)conversationForIdentifier:(NSURL *)identifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.identifier == %@", identifier];
    return [[self.conversations filteredSetUsingPredicate:predicate] anyObject];
}

- (NSSet *)conversationsForIdentifiers:(NSSet *)conversationIdentifiers
{
    if (conversationIdentifiers == nil) {
        return self.conversations;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY SELF.identifier IN %@", conversationIdentifiers];
    return [self.conversations filteredSetUsingPredicate:predicate];
}

- (NSSet *)conversationsForParticipants:(NSSet *)participants
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.participants == %@", participants];
    return [self.conversations filteredSetUsingPredicate:predicate];
}

- (NSSet *)messagesForIdentifiers:(NSSet *)messageIdentifiers
{
    if (messageIdentifiers == nil) {
        return self.messages;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY SELF.identifier IN %@", messageIdentifiers];
    return [self.messages filteredSetUsingPredicate:predicate];
}

- (NSOrderedSet *)messagesForConversation:(LYRConversationMock *)conversation
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.conversation == %@", conversation];
    NSSet *messages = [self.messages filteredSetUsingPredicate:predicate];
    NSSortDescriptor *messagesSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
    return [NSOrderedSet orderedSetWithArray:[messages sortedArrayUsingDescriptors:@[messagesSortDescriptor]]];
}

#pragma mark Public API - Sending object changes

- (BOOL)sendMessage:(LYRMessageMock *)message error:(NSError **)error
{
    NSMutableArray *changes = [NSMutableArray array];
    [changes addObject:[self addMessage:message]];
    [self postChanges:changes];

    // Simulate the message being sent.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSString *participant in message.conversation.participants) {
            if ([participant isEqualToString:self.authenticatedUserID]) {
                continue;
            }
            [changes addObject:[self setMessage:message recipientStatus:LYRRecipientStatusSent forParticipant:participant]];
        }
        [changes addObject:[self setMessage:message recipientStatus:LYRRecipientStatusRead forParticipant:self.authenticatedUserID]];
        [changes addObject:[self changesForMessageSent:message]];
        [self postChanges:changes];
    });
    
    // Simulate the message being delivered.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSString *participant in message.conversation.participants) {
            if ([participant isEqualToString:self.authenticatedUserID]) {
                continue;
            }
            [changes addObject:[self setMessage:message recipientStatus:LYRRecipientStatusDelivered forParticipant:participant]];
        }
        [self postChanges:changes];
    });
    return YES;
}

- (BOOL)markMessageAsRead:(LYRMessageMock *)message error:(NSError **)error
{
    [self postChanges:[self setMessage:message recipientStatus:LYRRecipientStatusRead forParticipant:self.authenticatedUserID]];
    return YES;
}

- (BOOL)setMetadata:(NSDictionary *)metadata onObject:(id)object
{
    NSMutableArray *changes = [NSMutableArray array];
    if ([object isKindOfClass:[LYRMessageMock class]]) {
        LYRMessageMock *message = object;
        NSDictionary *metadataBefore = message.metadata;
        for (NSString *key in metadata.allKeys) {
            NSObject *object = metadata[key];
            if ([object isEqual:[NSNull null]]) {
                [message.mutableMetadata removeObjectForKey:key];
            } else {
                [message.mutableMetadata setObject:object forKey:key];
            }
        }
        [changes addObject:[self changesForMessageMetadata:message metadataBefore:metadataBefore]];
    } else {
        LYRConversationMock *conversation = object;
        NSDictionary *metadataBefore = conversation.metadata;
        for (NSString *key in metadata.allKeys) {
            NSObject *object = metadata[key];
            if ([object isEqual:[NSNull null]]) {
                [conversation.mutableMetadata removeObjectForKey:key];
            } else {
                [conversation.mutableMetadata setObject:object forKey:key];
            }
        }
        [changes addObject:[self changesForConversationMetadata:conversation metadataBefore:metadataBefore]];
    }
    [self postChanges:changes];
    return YES;
}

- (BOOL)addParticipants:(NSSet *)participants toConversation:(LYRConversationMock *)conversation error:(NSError *__autoreleasing *)error
{
    [self postChanges:[self addMembers:participants toConversation:conversation]];
    return YES;
}

- (BOOL)removeParticipants:(NSSet *)participants fromConversation:(LYRConversationMock *)conversation error:(NSError *__autoreleasing *)error
{
    [self postChanges:[self removeMembers:participants fromConversation:conversation]];
    return YES;
}

- (BOOL)deleteMessage:(LYRMessageMock *)message mode:(LYRDeletionMode)deletionMode error:(NSError *__autoreleasing *)error
{
    [self postChanges:[self removeMessage:message]];
    return YES;
}

- (BOOL)deleteConversation:(LYRConversationMock *)conversation mode:(LYRDeletionMode)deletionMode error:(NSError *__autoreleasing *)error
{
    [self postChanges:[self removeConversation:conversation]];
    return YES;
}

#pragma mark Receiving changes

- (void)receiveMessage:(LYRMessageMock *)receivedMessage
{
    [self receiveMessages:@[receivedMessage]];
}

- (void)receiveMessages:(NSArray *)receivedMessages
{
    NSMutableArray *changes = [NSMutableArray array];
    for (LYRMessageMock *message in receivedMessages) {
        message.mutableRecipientStatuses[self.authenticatedUserID] = @(LYRRecipientStatusDelivered);
        [changes addObject:[self addMessage:message]];
    }
    [self postChanges:changes];
}

- (void)receiveMessageRecipientStatusChangeForMessage:(LYRMessageMock *)message recipientStatus:(LYRRecipientStatus)recipientStatus userID:(NSString *)userID
{
    [self postChanges:[self setMessage:message recipientStatus:recipientStatus forParticipant:userID]];
}

- (void)receiveMessageMetadataChangeForMessage:(LYRMessageMock *)message metadata:(NSDictionary *)metadata
{
    [self setMetadata:metadata onObject:message];
}

- (void)receiveMessageDeletion:(LYRMessageMock *)message
{
    [self deleteMessage:message mode:LYRDeletionModeAllParticipants error:nil];
}

- (void)receiveConversationParticipantsAdded:(NSSet *)participantsAdded toConversation:(LYRConversationMock *)conversation
{
    [self addParticipants:participantsAdded toConversation:conversation error:nil];
}

- (void)receiveConversationParticipantsRemoved:(NSSet *)participantsRemoved fromConversation:(LYRConversationMock *)conversation
{
    [self removeParticipants:participantsRemoved fromConversation:conversation error:nil];
}

- (void)receiveConversationMetadataChangeForMessage:(LYRConversationMock *)conversation metadata:(NSDictionary *)metadata
{
    [self setMetadata:metadata onObject:conversation];
}

- (void)receiveConversationDeletion:(LYRConversationMock *)conversation
{
    [self deleteConversation:conversation mode:LYRDeletionModeAllParticipants error:nil];
}

#pragma mark Conversation management

- (NSArray *)addConversationsFromArray:(NSArray *)conversations
{
    [self.conversations addObjectsFromArray:conversations];
    NSMutableArray *changes = [NSMutableArray array];
    for (LYRConversationMock *conversation in conversations) {
        [changes addObject:[self changesForConversationCreated:conversation]];
    }
    return changes;
}

- (NSArray *)addConversation:(LYRConversationMock *)conversation
{
    return [self addConversationsFromArray:@[conversation]];
}

- (NSArray *)addMembers:(NSSet *)members toConversation:(LYRConversationMock *)conversation
{
    NSMutableArray *changes = [NSMutableArray array];
    NSSet *participantsBefore = conversation.participants.copy;
    NSSet *participants = [conversation.participants setByAddingObjectsFromSet:members];
    conversation.participants = participants;
    [changes addObject:[self changesForConversation:conversation participantsBefore:participantsBefore]];
    return changes;
}

- (NSArray *)removeMembers:(NSSet *)members fromConversation:(LYRConversationMock *)conversation
{
    NSMutableArray *changes = [NSMutableArray array];
    NSSet *participantsBefore = conversation.participants.copy;
    NSMutableSet *participants = conversation.participants.mutableCopy;
    [participants minusSet:members];
    conversation.participants = participants;
    [changes addObject:[self changesForConversation:conversation participantsBefore:participantsBefore]];
    return changes;
}

- (NSArray *)removeConversationsFromArray:(NSArray *)conversations
{
    NSMutableArray *changes = [NSMutableArray array];
    for (LYRConversationMock *conversation in conversations) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.conversation == %@", conversation];
        NSSet *messages = [self.messages filteredSetUsingPredicate:predicate];
        [self removeMessagesFromArray:messages.allObjects];
        [self.conversations removeObject:conversation];
        [changes addObject:[self changesForConversationDeleted:conversation]];
    }
    return changes;
}

- (NSArray *)removeConversation:(LYRConversationMock *)conversation
{
    return [self removeConversationsFromArray:@[conversation]];
}

- (NSArray *)removeAllConversations
{
    NSMutableArray *changes = [NSMutableArray array];
    for (LYRConversationMock *conversation in self.conversations) {
        [changes addObject:[self changesForConversationDeleted:conversation]];
    }
    [self.conversations removeAllObjects];
    [self.messages removeAllObjects];
    return changes;
}

#pragma mark Messages management

- (NSArray *)addMessagesFromArray:(NSArray *)messages
{
    NSMutableArray *changes = [NSMutableArray array];
    NSMutableDictionary *countForConversationIdentifierDictionary = [NSMutableDictionary dictionary];
    for (LYRConversationMock *conversation in self.conversations) {
        countForConversationIdentifierDictionary[conversation.identifier] = [NSNumber numberWithUnsignedInteger:[self messagesForConversation:conversation].count];
    }
    for (LYRMessageMock *message in messages) {
        if (![self.conversations containsObject:message.conversation]) {
            [changes addObject:[self addConversation:message.conversation]];
        } else {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.object == %@ AND SELF.type == %d AND SELF.property == %@", message.conversation, LYRObjectChangeTypeUpdate, @"lastMessage"];
            NSArray *changeLastMessageForConversation = [changes filteredArrayUsingPredicate:predicate];
            if (changeLastMessageForConversation.count) {
                [changes removeObjectsInArray:changeLastMessageForConversation];
                [changes addObject:[self changesForConversation:message.conversation lastMessageChangeBefore:message.conversation.lastMessage]];
            }
        }
        message.index = [countForConversationIdentifierDictionary[message.conversation.identifier] integerValue] + 1;
        countForConversationIdentifierDictionary[message.conversation.identifier] = [NSNumber numberWithUnsignedInteger:message.index];
        message.conversation.lastMessage = message;
        if (![self.messages containsObject:messages]) {
            [changes addObject:[self changesForMessageCreated:message]];
        }
    }
    [self.messages addObjectsFromArray:messages];
    return changes;
}

- (NSArray *)addMessage:(LYRMessageMock *)message
{
    return [self addMessagesFromArray:@[message]];
}

- (NSArray *)removeMessagesFromArray:(NSArray *)messages
{
    NSMutableArray *changes = [NSMutableArray array];
    for (LYRMessageMock *message in messages) {
        [self.messages removeObject:message];
        [changes addObject:[self changesForMessageDeleted:message]];
    }
    NSSet *affectedConversations = [messages valueForKeyPath:@"conversation"];
    for (LYRConversationMock *conversation in affectedConversations) {
        [changes addObject:[self reindexMessageOrderForConversation:conversation]];
    }
    return changes;
}

- (NSArray *)removeMessage:(LYRMessageMock *)message
{
    return [self removeMessagesFromArray:@[message]];
}

- (NSArray *)setMessage:(LYRMessageMock *)message recipientStatus:(LYRRecipientStatus)recipientStatus forParticipant:(NSString *)participant
{
    NSMutableArray *changes = [NSMutableArray array];
    [changes addObject:[self changesForMessageRecipientStatus:message recipientStatusBefore:message.recipientStatusByUserID.copy]];
    [message setRecipientStatus:recipientStatus forUserID:participant];
    return changes;
}

#pragma mark Message order indexing

- (NSArray *)reindexMessageOrderForConversation:(LYRConversationMock *)conversation
{
    NSUInteger index = 1;
    NSMutableArray *changes = [NSMutableArray array];
    LYRMessageMock *previousLastMessage = conversation.lastMessage;
    for (LYRMessageMock *message in [self messagesForConversation:conversation]) {
        if (message.index != index) {
            [changes addObject:[self changesForMessageIndexChange:message indexBefore:message.index indexAfter:index]];
        }
        message.index = index++;
        message.conversation.lastMessage = message;
    }
    if (![previousLastMessage isEqual:conversation.lastMessage]) {
        [changes addObject:[self changesForConversation:conversation lastMessageChangeBefore:previousLastMessage]];
    }
    return changes;
}

#pragma mark Synchronization changes

- (void)postChanges:(NSArray *)changes
{
    if ([self.delegate respondsToSelector:@selector(layerClient:objectsDidChange:)]) {
        [self.delegate layerClient:(id)self objectsDidChange:changes];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:LYRClientObjectsDidChangeNotification object:self userInfo:@{ LYRClientObjectChangesUserInfoKey: changes }];
}

// Message related sync changes

- (NSArray *)changesForMessageCreated:(LYRMessageMock *)message
{
    return @[@{ LYRObjectChangeTypeKey: @(LYRObjectChangeTypeCreate),
                LYRObjectChangeObjectKey: message,
                LYRObjectChangePropertyKey: [NSNull null],
                LYRObjectChangeOldValueKey: [NSNull null],
                LYRObjectChangeNewValueKey: [NSNull null] }];
}

- (NSArray *)changesForMessageSent:(LYRMessageMock *)message
{
    return @[@{ LYRObjectChangeTypeKey: @(LYRObjectChangeTypeUpdate),
                LYRObjectChangeObjectKey: message,
                LYRObjectChangePropertyKey: @"sentAt",
                LYRObjectChangeOldValueKey: [NSNull null],
                LYRObjectChangeNewValueKey: [NSDate date] },
             @{ LYRObjectChangeTypeKey: @(LYRObjectChangeTypeUpdate),
                LYRObjectChangeObjectKey: message,
                LYRObjectChangePropertyKey: @"receivedAt",
                LYRObjectChangeOldValueKey: [NSNull null],
                LYRObjectChangeNewValueKey: [NSDate date] },];
}

- (NSArray *)changesForMessageRecipientStatus:(LYRMessageMock *)message recipientStatusBefore:(NSDictionary *)recipientStatusBefore
{
    return @[@{ LYRObjectChangeTypeKey: @(LYRObjectChangeTypeUpdate),
                LYRObjectChangeObjectKey: message,
                LYRObjectChangePropertyKey: @"recipientStatusByUserID",
                LYRObjectChangeOldValueKey: recipientStatusBefore,
                LYRObjectChangeNewValueKey: message.recipientStatusByUserID.copy }];
}

- (NSArray *)changesForMessageMetadata:(LYRMessageMock *)message metadataBefore:(NSDictionary *)metadataBefore
{
    return @[@{ LYRObjectChangeTypeKey: @(LYRObjectChangeTypeUpdate),
                LYRObjectChangeObjectKey: message,
                LYRObjectChangePropertyKey: @"metadata",
                LYRObjectChangeOldValueKey: metadataBefore,
                LYRObjectChangeNewValueKey: message.metadata.copy }];
}

- (NSArray *)changesForMessageIndexChange:(LYRMessageMock *)message indexBefore:(NSUInteger)indexBefore indexAfter:(NSUInteger)indexAfter
{
    return @[@{ LYRObjectChangeTypeKey: @(LYRObjectChangeTypeUpdate),
                LYRObjectChangeObjectKey: message,
                LYRObjectChangePropertyKey: @"index",
                LYRObjectChangeOldValueKey: @(indexBefore),
                LYRObjectChangeNewValueKey: @(indexAfter) }];
}

- (NSArray *)changesForMessageDeleted:(LYRMessageMock *)message
{
    return @[@{ LYRObjectChangeTypeKey: @(LYRObjectChangeTypeDelete),
                LYRObjectChangeObjectKey: message,
                LYRObjectChangePropertyKey: [NSNull null],
                LYRObjectChangeOldValueKey: [NSNull null],
                LYRObjectChangeNewValueKey: [NSNull null] }];
}

// Conversation related sync changes

- (NSArray *)changesForConversationCreated:(LYRConversationMock *)conversation
{
    return @[@{ LYRObjectChangeTypeKey: @(LYRObjectChangeTypeCreate),
                LYRObjectChangeObjectKey: conversation,
                LYRObjectChangePropertyKey: [NSNull null],
                LYRObjectChangeOldValueKey: [NSNull null],
                LYRObjectChangeNewValueKey: [NSNull null] }];
}

- (NSArray *)changesForConversationMetadata:(LYRConversationMock *)conversation metadataBefore:(NSDictionary *)metadataBefore
{
    return @[@{ LYRObjectChangeTypeKey: @(LYRObjectChangeTypeUpdate),
                LYRObjectChangeObjectKey: conversation,
                LYRObjectChangePropertyKey: @"metadata",
                LYRObjectChangeOldValueKey: metadataBefore,
                LYRObjectChangeNewValueKey: conversation.metadata.copy }];
}

- (NSArray *)changesForConversation:(LYRConversationMock *)conversation lastMessageChangeBefore:(LYRMessageMock *)lastMessageBefore
{
    return @[@{ LYRObjectChangeTypeKey: @(LYRObjectChangeTypeUpdate),
                LYRObjectChangeObjectKey: conversation,
                LYRObjectChangePropertyKey: @"lastMessage",
                LYRObjectChangeOldValueKey: lastMessageBefore,
                LYRObjectChangeNewValueKey: conversation.lastMessage }];
}

- (NSArray *)changesForConversation:(LYRConversationMock *)conversation participantsBefore:(NSSet *)participantsBefore
{
    return @[@{ LYRObjectChangeTypeKey: @(LYRObjectChangeTypeUpdate),
                LYRObjectChangeObjectKey: conversation,
                LYRObjectChangePropertyKey: @"participants",
                LYRObjectChangeOldValueKey: participantsBefore,
                LYRObjectChangeNewValueKey: conversation.participants }];
}

- (NSArray *)changesForConversationDeleted:(LYRConversationMock *)conversation
{
    return @[@{ LYRObjectChangeTypeKey: @(LYRObjectChangeTypeDelete),
                LYRObjectChangeObjectKey: conversation,
                LYRObjectChangePropertyKey: [NSNull null],
                LYRObjectChangeOldValueKey: [NSNull null],
                LYRObjectChangeNewValueKey: [NSNull null] }];
}

@end

#pragma mark - LYRConversationMock -

@implementation LYRConversationMock

- (instancetype)init
{
    self = [super init];
    if (self) {
        _identifier = [NSURL URLWithString:[NSString stringWithFormat:@"layer:///conversations/%@", NSUUID.UUID.UUIDString.lowercaseString]];
        _createdAt = [NSDate date];
        _isDeleted = NO;
        _participants = [NSSet set];
        _mutableMetadata = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)conversationWithParticipants:(NSSet *)participants
{
    LYRConversationMock *conversation = [[LYRConversationMock alloc] init];
    conversation.participants = participants;
    return conversation;
}

- (NSDictionary *)metadata
{
    return [self mutableMetadata];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[LYRConversationMock class]]) return NO;
    if (self == object) return YES;
    return [self.identifier isEqual:[(LYRConversationMock *)object identifier]];
}

- (NSUInteger)hash
{
    return self.identifier.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p identifier=%@ isDeleted=%@ participants=%@>", [self class], self, self.identifier, self.isDeleted ? @"YES" : @"NO", self.participants];
}

@end

#pragma mark - LYRMessageMock -

@implementation LYRMessageMock

- (instancetype)init
{
    self = [super init];
    if (self) {
        _identifier = [NSURL URLWithString:[NSString stringWithFormat:@"layer:///messages/%@", NSUUID.UUID.UUIDString.lowercaseString]];
        _index = 0;
        _isSent = NO;
        _isDeleted = NO;
        _mutableRecipientStatuses = [NSMutableDictionary dictionary];
        _mutableMetadata = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)messageWithConversation:(LYRConversationMock *)conversation parts:(NSArray *)messageParts userID:(NSString *)userID
{
    LYRMessageMock *message = [[LYRMessageMock alloc] init];
    message.conversation = conversation;
    message.parts = messageParts;
    message.sentByUserID = userID;
    for (NSString *participant in conversation.participants) {
        [message setRecipientStatus:LYRRecipientStatusInvalid forUserID:participant];
    }
    return message;
}

+ (instancetype)messageWithConversation:(LYRConversationMock *)conversation parts:(NSArray *)messageParts
{
    return [LYRMessageMock messageWithConversation:conversation parts:messageParts userID:nil];
}

- (NSDictionary *)recipientStatusByUserID
{
    return self.mutableRecipientStatuses;
}

- (LYRRecipientStatus)recipientStatusForUserID:(NSString *)userID
{
    NSNumber *numericState = self.mutableRecipientStatuses[userID];
    return (LYRRecipientStatus) (numericState ? [numericState unsignedIntegerValue] : LYRRecipientStatusInvalid);
}

- (void)setRecipientStatus:(LYRRecipientStatus)recipientStatus forUserID:(NSString *)userID
{
    self.mutableRecipientStatuses[userID] = @(recipientStatus);
}

- (NSDictionary *)metadata
{
    return [self mutableMetadata];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[LYRMessageMock class]]) return NO;
    if (self == object) return YES;
    return [self.identifier isEqual:[(LYRMessageMock *)object identifier]];
}

- (NSUInteger)hash
{
    return self.identifier.hash;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@:%p identifier=%@ index=%@ isDeleted=%@ parts=%@ conversation=%@>", [self class], self, self.identifier, self.index == NSNotFound ? @"N/A" : @(self.index), self.isDeleted ? @"YES" : @"NO", self.parts, self.conversation];
}

@end
