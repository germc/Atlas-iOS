//
//  LYRMessageMock.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
//

#import "LYRMessageMock.h"

@interface LYRMessageMock ()

@property (nonatomic, readwrite) NSURL *identifier;
@property (nonatomic, readwrite) NSUInteger index;
@property (nonatomic, readwrite) LYRConversation *conversation;
@property (nonatomic, readwrite) NSArray *parts;
@property (nonatomic, readwrite) BOOL isSent;
@property (nonatomic, readwrite) BOOL isDeleted;
@property (nonatomic, readwrite) BOOL isUnread;
@property (nonatomic, readwrite) NSDate *sentAt;
@property (nonatomic, readwrite) NSDate *receivedAt;
@property (nonatomic, readwrite) NSString *sentByUserID;
@property (nonatomic, readwrite) NSDictionary *recipientStatusByUserID;

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
    return YES;
}

- (BOOL)delete:(LYRDeletionMode)deletionMode error:(NSError **)error
{
    self.isDeleted = YES;
    return YES;
}

- (LYRRecipientStatus)recipientStatusForUserID:(NSString *)userID
{
    return nil;
}

@end
