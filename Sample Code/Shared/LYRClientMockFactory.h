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
- (instancetype)initWithAuthenticatedUserID:(NSString *)authenticatedUserID;
+ (LYRClientMockFactory *)emptyClientWithAuthenticatedUserID:(NSString *)authenticatedUserID;
+ (LYRClientMockFactory *)emptyClientForAlice;
+ (LYRClientMockFactory *)emptyClientForBob;
+ (LYRClientMockFactory *)emptyClientForCarol;
+ (LYRClientMockFactory *)clientForAliceWithConversation;

#pragma mark - ParticipantID-to-user resolver
+ (LYRUserMock *)userForParticipantIdentifier:(NSString *)participantIdentifier;

#pragma mark - Producing conversations
- (void)addConversationBetweenAliceAndBob;

@end
