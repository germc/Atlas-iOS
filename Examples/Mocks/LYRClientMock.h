//
//  ATLClientMock.h
//  Atlas
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
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
#import "LayerKitMock.h"

extern NSString *const LYRMockObjectsDidChangeNotification;
extern NSString *const LYRMockObjectChangeObjectKey;
extern NSString *const LYRMockObjectChangeNewValueKey;
extern NSString *const LYRMockObjectChangeOldValueKey;
extern NSString *const LYRMockObjectChangeChangeTypeKey;

@class LYRConversationMock, LYRMessageMock, LYRQueryMock, LYRQueryControllerMock;

@interface LYRClientMock : NSObject

@property (nonatomic, readonly) NSString *authenticatedUserID;
@property (nonatomic, weak) id<LYRClientDelegate> delegate;

+ (instancetype)layerClientMockWithAuthenticatedUserID:(NSString *)authenticatedUserID;

///------------------------------------------------
/// @name LYRClient's Public API - Sending changes
///------------------------------------------------

- (LYRConversationMock *)newConversationWithParticipants:(NSSet *)participants options:(NSDictionary *)options error:(NSError **)error;
- (LYRMessageMock *)newMessageWithParts:(NSArray *)messageParts options:(NSDictionary *)options error:(NSError **)error;
- (LYRMessageMock *)newPlatformMessageWithParts:(NSArray *)messageParts senderName:(NSString *)senderName options:(NSDictionary *)options error:(NSError **)error;
- (NSOrderedSet *)executeQuery:(LYRQuery *)query error:(NSError **)error;
- (NSUInteger)countForQuery:(LYRQuery *)query error:(NSError **)error;
- (LYRQueryControllerMock *)queryControllerWithQuery:(LYRQuery *)query error:(NSError **)error;

@end


