//
//  ATLConversationMock.m
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
#import "LYRConversationMock.h"
#import "LYRMockContentStore.h"

NSData *MediaAttachmentDataFromInputStream(NSInputStream *inputStream)
{
    if (!inputStream) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"inputStream cannot be `nil`." userInfo:nil];
    }
    NSMutableData *dataFromStream = [NSMutableData data];
    
    // Open stream
    [inputStream open];
    if (inputStream.streamError) {
        NSLog(@"Failed to stream image content with %@", inputStream.streamError);
        return nil;
    }
    
    // Start streaming
    uint8_t *buffer = malloc(1024*1024);
    do {
        NSUInteger bytesRead = [inputStream read:buffer maxLength:(unsigned long)1024*1024];
        [dataFromStream appendBytes:buffer length:bytesRead];
    } while ([inputStream streamStatus] != NSStreamStatusAtEnd);
    free(buffer);
    
    // Close stream
    [inputStream close];
    
    // Done
    return dataFromStream;
}

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
    mock.identifier = [NSURL URLWithString:@"test"];
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
    [[LYRMockContentStore sharedStore] broadcastChanges];
    return YES;
}

- (void)updateMessage:(LYRMessageMock *)message
{
    message.conversation = self;
    message.sentAt = [NSDate date];
    message.receivedAt = message.sentAt;
    
    if (!self.lastMessage) {
        message.position = 0;
    } else {
        message.position = ((int)self.lastMessage.position + 1);
    }
    if (![message.parts.firstObject data] && [message.parts.firstObject inputStream]) {
        NSMutableArray *parts = [NSMutableArray new];
        for (LYRMessagePart *part in message.parts) {
            NSData *data = MediaAttachmentDataFromInputStream(part.inputStream);
            LYRMessagePartMock *mock = [LYRMessagePartMock messagePartWithMIMEType:part.MIMEType data:data];
            mock.fileURL = part.fileURL;
            [parts addObject:mock];
        }
        message.parts = parts;
    }
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
    NSMutableSet *participantsCopy = [self.participants mutableCopy];
    [participantsCopy unionSet:participants];
    self.participants = participantsCopy;
    [[LYRMockContentStore sharedStore] broadcastChanges];
    return YES;
}

- (BOOL)removeParticipants:(NSSet *)participants error:(NSError **)error
{
    NSAssert(participants.count, @"Cannot send add null participants to a conversation");
    NSMutableSet *participantsCopy = [self.participants mutableCopy];
    [participantsCopy minusSet:participants];
    self.participants = participantsCopy;
    [[LYRMockContentStore sharedStore] broadcastChanges];
    return YES;
}

#pragma mark - Metadata

- (void)setValue:(NSString *)value forMetadataAtKeyPath:(NSString *)keyPath
{
    [self.metadata setValue:value forKeyPath:keyPath];
    [[LYRMockContentStore sharedStore] broadcastChanges];
}

- (void)setValuesForMetadataKeyPathsWithDictionary:(NSDictionary *)metadata merge:(BOOL)merge
{
    [self.metadata setValuesForKeysWithDictionary:metadata];
    [[LYRMockContentStore sharedStore] broadcastChanges];
}

- (void)deleteValueForMetadataAtKeyPath:(NSString *)keyPath
{
    [self.metadata setValue:nil forKeyPath:keyPath];
    [[LYRMockContentStore sharedStore] broadcastChanges];
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
    [[LYRMockContentStore sharedStore] deleteConversation:self];
    [[LYRMockContentStore sharedStore] broadcastChanges];
    return YES;
}

#pragma mark - Marking As Read

- (BOOL)markAllMessagesAsRead:(NSError **)error
{
    self.hasUnreadMessages = NO;
    [[LYRMockContentStore sharedStore] broadcastChanges];
    return YES;
}

@end
