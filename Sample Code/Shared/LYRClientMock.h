//
//  LYRClientMock.h
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
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
- (NSOrderedSet *)executeQuery:(LYRQuery *)query error:(NSError **)error;
- (NSUInteger)countForQuery:(LYRQuery *)query error:(NSError **)error;
- (LYRQueryControllerMock *)queryControllerWithQuery:(LYRQuery *)query;

@end


