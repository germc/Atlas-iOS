//
//  ATLConversationMock.h
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
#import "LYRMessageMock.h"
#import <LayerKit/LayerKit.h>

@class LYRMessageMock;

@interface LYRConversationMock : NSObject <LYRQueryable>

@property (nonatomic, readonly) NSURL *identifier LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) NSSet *participants LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) NSDate *createdAt LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) LYRMessageMock *lastMessage LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) BOOL hasUnreadMessages LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) BOOL isDeleted;
@property (nonatomic, readonly) NSDictionary *metadata;

+ (instancetype)newConversationWithParticipants:(NSSet *)participants options:(NSDictionary *)options;

- (BOOL)sendMessage:(LYRMessageMock *)message error:(NSError **)error;

- (BOOL)addParticipants:(NSSet *)participants error:(NSError **)error;

- (BOOL)removeParticipants:(NSSet *)participants error:(NSError **)error;

- (void)setValue:(NSString *)value forMetadataAtKeyPath:(NSString *)keyPath;

- (void)setValuesForMetadataKeyPathsWithDictionary:(NSDictionary *)metadata merge:(BOOL)merge;

- (void)deleteValueForMetadataAtKeyPath:(NSString *)keyPath;

- (void)sendTypingIndicator:(LYRTypingIndicator)typingIndicator;

- (BOOL)delete:(LYRDeletionMode)deletionMode error:(NSError **)error;

- (BOOL)markAllMessagesAsRead:(NSError **)error;

@end
