//
//  ATLMessageMock.m
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
#import "LYRMessageMock.h"
#import "LYRMockContentStore.h"

@implementation LYRActorMock
@end

@interface LYRMessageMock ()

@property (nonatomic, readwrite) NSURL *identifier;
@property (nonatomic, readwrite) BOOL isSent;
@property (nonatomic, readwrite) BOOL isDeleted;
@property (nonatomic, readwrite) BOOL isUnread;
@property (nonatomic, readwrite) LYRActorMock *sender;

@end

@implementation LYRMessageMock

- (id)initWithMessageParts:(NSArray *)messageParts senderID:(NSString *)senderID
{
    self = [super init];
    if (self) {
        _parts = messageParts;
        _sender = [LYRActorMock new];
        _sender.userID = senderID;
    }
    return self;    
}

- (id)initWithMessageParts:(NSArray *)messageParts senderName:(NSString *)senderName
{
    self = [super init];
    if (self) {
        _parts = messageParts;
        _sender = [LYRActorMock new];
        _sender.name = senderName;
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

+ (instancetype)newMessageWithParts:(NSArray *)messageParts senderName:(NSString *)senderName
{
    LYRMessageMock *mock = [[self alloc] initWithMessageParts:messageParts senderName:senderName];
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
    [[LYRMockContentStore sharedStore] deleteMessage:self];
    [[LYRMockContentStore sharedStore] broadcastChanges];
    return YES;
}

- (LYRRecipientStatus)recipientStatusForUserID:(NSString *)userID
{
    return [[self.recipientStatusByUserID valueForKey:userID] integerValue];
}

@end
