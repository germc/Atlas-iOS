//
//  LYRClientMock.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
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
    return [LYRConversationMock newConversationWithParticipants:participants options:options];
}

- (LYRMessageMock *)newMessageWithParts:(NSArray *)messageParts options:(NSDictionary *)options error:(NSError *__autoreleasing *)error
{
    return [LYRMessageMock newMessageWithParts:messageParts senderID:self.authenticatedUserID];
}

- (NSOrderedSet *)executeQuery:(LYRQuery *)query error:(NSError *__autoreleasing *)error
{
    return [[LYRMockContentStore sharedStore] fetchObjectsWithClass:query.queryableClass predicate:query.predicate sortDescriptior:query.sortDescriptors];
}

- (NSUInteger)countForQuery:(LYRQuery *)query error:(NSError *__autoreleasing *)error
{
    return [[LYRMockContentStore sharedStore] fetchObjectsWithClass:query.queryableClass predicate:query.predicate sortDescriptior:query.sortDescriptors].count;
}

- (LYRQueryControllerMock *)queryControllerWithQuery:(LYRQuery *)query
{
    return [LYRQueryControllerMock initWithQuery:query];
}

@end
