//
//  LYRMessageMock.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
//

#import "LYRMessageMock.h"
#import "LYRMockContentStore.h"

@interface LYRMessageMock ()

@property (nonatomic, readwrite) NSURL *identifier;
@property (nonatomic, readwrite) NSArray *parts;
@property (nonatomic, readwrite) BOOL isSent;
@property (nonatomic, readwrite) BOOL isDeleted;
@property (nonatomic, readwrite) BOOL isUnread;
@property (nonatomic, readwrite) NSDate *receivedAt;
@property (nonatomic, readwrite) NSString *sentByUserID;

@end

@implementation LYRMessageMock

- (id)initWithMessageParts:(NSArray *)messageParts senderID:(NSString *)senderID
{
    self = [super init];
    if (self) {
        _parts = messageParts;
        _sentByUserID = senderID;
    }
    return self;    
}

+ (instancetype)newMessageWithParts:(NSArray *)messageParts senderID:(NSString *)senderID
{
    LYRMessageMock *mock = [[self alloc] initWithMessageParts:messageParts senderID:senderID];
    mock.identifier = [NSURL URLWithString:[[NSUUID UUID] UUIDString]];
    mock.isSent = NO;
    mock.isDeleted = NO;
    mock.isUnread = YES;
    return mock;
}

- (BOOL)markAsRead:(NSError **)error
{
    self.isUnread = NO;
    [[LYRMockContentStore sharedStore] updateMessage:self];
    [[LYRMockContentStore sharedStore] broadcastChanges];
    return YES;
}

- (BOOL)delete:(LYRDeletionMode)deletionMode error:(NSError **)error
{
    self.isDeleted = YES;
    [[LYRMockContentStore sharedStore] deleteMessage:self];
    [[LYRMockContentStore sharedStore] broadcastChanges];
    return YES;
}

- (LYRRecipientStatus)recipientStatusForUserID:(NSString *)userID
{
    return [[self.recipientStatusByUserID valueForKey:userID] integerValue];
}

@end
