//
//  LYRClientMockFactory.h
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/31/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRClientMock.h"
#import "LYRUserMock.h"

@interface LYRClientMockFactory : NSObject

@property (nonatomic, readonly) LYRClientMock *layerClient;
@property (nonatomic, readonly) NSString *authenticatedUserID;

#pragma mark - Producing LYRClientMock

+ (id)sharedFactory;

- (void)hydrateConversationsWithCount:(NSUInteger)count;

#pragma mark - Producing conversations
- (void)addConversationBetweenAliceAndBob;

#pragma mark - Producing timed incoming messages
- (void)startTimedIncomingMessages;
- (void)stopTimedIncomingMessages;

@end
