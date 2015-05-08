//
//  ATLMessageMock.h
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
#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h> 

@class LYRConversationMock;

@interface LYRActorMock : NSObject

@property (nonatomic, readwrite) NSString *userID;
@property (nonatomic, readwrite) NSString *name;

@end
@interface LYRMessageMock : NSObject <LYRQueryable>

@property (nonatomic, readonly) NSURL *identifier LYR_QUERYABLE_PROPERTY;
@property (nonatomic) NSUInteger position LYR_QUERYABLE_PROPERTY;
@property (nonatomic) LYRConversationMock *conversation LYR_QUERYABLE_PROPERTY;
@property (nonatomic) NSArray *parts;
@property (nonatomic, readonly) BOOL isSent LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) BOOL isDeleted;
@property (nonatomic, readonly) BOOL isUnread LYR_QUERYABLE_PROPERTY;
@property (nonatomic) NSDate *sentAt LYR_QUERYABLE_PROPERTY;
@property (nonatomic) NSDate *receivedAt LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) LYRActorMock *sender;
@property (nonatomic) NSDictionary *recipientStatusByUserID;

+ (instancetype)newMessageWithParts:(NSArray *)messageParts senderID:(NSString *)senderID;

- (BOOL)markAsRead:(NSError **)error;

- (BOOL)delete:(LYRDeletionMode)deletionMode error:(NSError **)error;

- (LYRRecipientStatus)recipientStatusForUserID:(NSString *)userID;

@end
