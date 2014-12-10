//
//  LYRConversationMock.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
//

#import "LYRConversationMock.h"
#import "LYRMockContentStore.h"

@interface LYRConversationMock ()

@property (nonatomic, readwrite) NSURL *identifier;
@property (nonatomic, readwrite) NSSet *participants;
@property (nonatomic, readwrite) NSDate *createdAt;
@property (nonatomic, readwrite) LYRMessageMock *lastMessage;
@property (nonatomic, readwrite) BOOL hasUnreadMessages;
@property (nonatomic, readwrite) BOOL isDeleted;
@property (nonatomic, readwrite) NSDictionary *metadata;

@end

@implementation LYRConversationMock

+ (instancetype)newConversationWithParticipants:(NSSet *)participants options:(NSDictionary *)options
{
    LYRConversationMock *mock = [[self alloc] initWithParticipants:participants];
    mock.metadata = [options valueForKey:LYRConversationOptionsMetadataKey];
    return mock;
}

- (id)initWithParticipants:(NSSet *)participants
{
    self = [super init];
    if (self) {
        _participants = participants;
    }
    return self;
}

#pragma mark - Sending Message

- (BOOL)sendMessage:(LYRMessageMock *)message error:(NSError **)error
{
    NSAssert([message isKindOfClass:[LYRMessageMock class]], @"Cannot send an object that is not a `LYRMessageMock`");
    [self updateMessage:message];
    self.lastMessage = message;
    self.hasUnreadMessages = YES;
    self.isDeleted = NO;
    if (!self.identifier) {
        self.identifier = [NSURL URLWithString:[[NSUUID UUID] UUIDString]];
        self.createdAt = [NSDate date];
        [[LYRMockContentStore sharedStore] insertConversation:self];
    }
    [[LYRMockContentStore sharedStore] broadCastChanges];
    return YES;
}

- (void)updateMessage:(LYRMessageMock *)message
{
    if (!self.lastMessage) {
        message.index = 0;
    } else {
        message.index = ((int)self.lastMessage.index + 1);
    }
    message.conversation = self;
    message.sentAt = [NSDate date];
    
    NSMutableDictionary *recipientStatus = [NSMutableDictionary new];
    [self.participants enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [recipientStatus setValue:[NSNumber numberWithInteger:LYRRecipientStatusRead] forKey:obj];
    }];
    
    message.recipientStatusByUserID = recipientStatus;
    [[LYRMockContentStore sharedStore] insertMessage:message];
}

#pragma mark - Public Mutating Participants

- (BOOL)addParticipants:(NSSet *)participants error:(NSError **)error
{
    NSAssert(participants.count, @"Cannot send add null participants to a conversation");
    NSMutableSet *participantCopy = [self.participants copy];
    [participantCopy unionSet:participants];
    self.participants = participantCopy;
    [[LYRMockContentStore sharedStore] broadCastChanges];
    return YES;
}

- (BOOL)removeParticipants:(NSSet *)participants error:(NSError **)error
{
    NSAssert(participants.count, @"Cannot send add null participants to a conversation");
    NSMutableSet *participantCopy = [self.participants copy];
    [participantCopy minusSet:participants];
    self.participants = participantCopy;
    [[LYRMockContentStore sharedStore] broadCastChanges];
    return YES;
}

#pragma mark - Metadata

- (void)setValue:(NSString *)value forMetadataAtKeyPath:(NSString *)keyPath
{
    [self.metadata setValue:value forKeyPath:keyPath];
    [[LYRMockContentStore sharedStore] broadCastChanges];
}

- (void)setValuesForMetadataKeyPathsWithDictionary:(NSDictionary *)metadata merge:(BOOL)merge
{
    [self.metadata setValuesForKeysWithDictionary:metadata];
    [[LYRMockContentStore sharedStore] broadCastChanges];
}

- (void)deleteValueForMetadataAtKeyPath:(NSString *)keyPath
{
    [self.metadata setValue:nil forKeyPath:keyPath];
    [[LYRMockContentStore sharedStore] broadCastChanges];
}

#pragma mark - Typing Indicator

- (void)sendTypingIndicator:(LYRTypingIndicator)typingIndicator
{
    //
}

#pragma mark - Deleting

- (BOOL)delete:(LYRDeletionMode)deletionMode error:(NSError **)error
{
    self.isDeleted = YES;
    [[LYRMockContentStore sharedStore] broadCastChanges];
    return YES;
}

#pragma mark - Marking As Read

- (BOOL)markAllMessagesAsRead:(NSError **)error
{
    self.hasUnreadMessages = NO;
    [[LYRMockContentStore sharedStore] broadCastChanges];
    return YES;
}

@end
