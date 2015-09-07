//
//  ATLClientMock.m
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

#import "LYRClientMock.h"
#import "LYRMockContentStore.h"

#pragma mark - LYRClientMock -

NSString *const LYRMockObjectsDidChangeNotification = @"mockObjectsDidChangeNotification";
NSString *const LYRMockObjectChangeObjectKey = @"mockObjectChangeObjectKey";
NSString *const LYRMockObjectChangeNewValueKey = @"mockObjectChangeNewValueKey";
NSString *const LYRMockObjectChangeOldValueKey = @"mockObjectChangeOldValueKey";
NSString *const LYRMockObjectChangeChangeTypeKey = @"mockObjectChangeChangeTypeKey";

@interface LYRClientMock ()

@property (nonatomic, readwrite) NSString *authenticatedUserID;
@property (nonatomic) NSMutableSet *conversations;
@property (nonatomic) NSMutableSet *messages;

@end

@implementation LYRClientMock

#pragma mark Initializer

+ (instancetype)layerClientMockWithAuthenticatedUserID:(NSString *)authenticatedUserID
{
    LYRClientMock *layerClientMock = [[LYRClientMock alloc] initWithAuthenticatedUserID:authenticatedUserID];
    return layerClientMock;
}

- (instancetype)initWithAuthenticatedUserID:(NSString *)authenticatedUserID
{
    self = [super init];
    if (self) {
        _authenticatedUserID = authenticatedUserID;
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Failed to call designated initializer, use +%@", NSStringFromSelector(@selector(layerClientMockWithAuthenticatedUserID:))]  userInfo:nil];
}

#pragma mark Public API

- (LYRConversationMock *)newConversationWithParticipants:(NSSet *)participants options:(NSDictionary *)options error:(NSError *__autoreleasing *)error
{
    NSMutableSet *allParticipants = [participants mutableCopy];
    [allParticipants addObject:self.authenticatedUserID];
    return [LYRConversationMock newConversationWithParticipants:allParticipants options:options];
}

- (LYRMessageMock *)newMessageWithParts:(NSArray *)messageParts options:(NSDictionary *)options error:(NSError *__autoreleasing *)error
{
    return [LYRMessageMock newMessageWithParts:messageParts senderID:self.authenticatedUserID];
}

- (LYRMessageMock *)newPlatformMessageWithParts:(NSArray *)messageParts senderName:(NSString *)senderName options:(NSDictionary *)options error:(NSError *__autoreleasing *)error
{
    return [LYRMessageMock newMessageWithParts:messageParts senderName:senderName];
}

- (NSOrderedSet *)executeQuery:(LYRQuery *)query error:(NSError *__autoreleasing *)error
{
    return [[LYRMockContentStore sharedStore] fetchObjectsWithClass:query.queryableClass predicate:query.predicate sortDescriptior:query.sortDescriptors];
}

- (NSUInteger)countForQuery:(LYRQuery *)query error:(NSError *__autoreleasing *)error
{
    return [[LYRMockContentStore sharedStore] fetchObjectsWithClass:query.queryableClass predicate:query.predicate sortDescriptior:query.sortDescriptors].count;
}

- (LYRQueryControllerMock *)queryControllerWithQuery:(LYRQuery *)query error:(NSError *__autoreleasing *)error
{
    LYRQueryControllerMock *mock = [LYRQueryControllerMock initWithQuery:query];
    mock.layerClient = self;
    return mock;
}

@end
