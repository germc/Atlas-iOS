//
//  LYRUITestUtilities.m
//  Atlas
//
//  Created by Kevin Coleman on 12/16/14.
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
#import "LYRUITestInterface.h"

@interface LYRUITestInterface ()

@end

@implementation LYRUITestInterface

+ (instancetype)testIntefaceWithLayerClient:(LYRClientMock *)layerClient
{
    return [[self alloc] initWithLayerClient:layerClient];
}

- (id)initWithLayerClient:(LYRClientMock *)layerClient
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
        [[LYRMockContentStore sharedStore] setShouldBroadcastChanges:YES];
        
    }
    return self;
}

- (LYRConversationMock *)conversationWithParticipants:(NSSet *)participants lastMessageText:(NSString *)lastMessageText
{
    LYRConversationMock *conversation = [self.layerClient newConversationWithParticipants:participants options:nil error:nil];
    if (lastMessageText) {
        LYRMessagePart *part = [LYRMessagePart messagePartWithText:lastMessageText];
        LYRMessageMock *message = [self.layerClient newMessageWithParts:@[part] options:nil error:nil];
        [conversation sendMessage:message error:nil];
    }
    return conversation;
}

- (NSString *)conversationLabelForConversation:(LYRConversationMock *)conversation
{
    if (!self.layerClient.authenticatedUserID) return @"Not auth'd";
    NSMutableSet *participantIdentifiers = [conversation.participants mutableCopy];
    [participantIdentifiers minusSet:[NSSet setWithObject:self.layerClient.authenticatedUserID]];
    
    if (!participantIdentifiers.count > 0) return @"Personal Conversation";
    
    NSMutableSet *participants = [[LYRUserMock participantsForIdentifiers:conversation.participants] mutableCopy];
    if (!participants.count > 0) return @"No Matching Participants";
    
    // Put the latest message sender's name first
    LYRUserMock *firstUser;
    if (![conversation.lastMessage.sentByUserID isEqualToString:self.layerClient.authenticatedUserID]){
        if (conversation.lastMessage) {
            NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.userID IN %@", conversation.lastMessage.sentByUserID];
            LYRUserMock *lastMessageSender = [[[participants filteredSetUsingPredicate:searchPredicate] allObjects] lastObject];
            if (lastMessageSender) {
                firstUser = lastMessageSender;
                [participants removeObject:lastMessageSender];
            }
        }
    } else {
        firstUser = [[participants allObjects] objectAtIndex:0];
    }
    
    NSString *conversationLabel = firstUser.fullName;
    for (int i = 1; i < [[participants allObjects] count]; i++) {
        LYRUserMock *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
}

- (void)setRootViewController:(UIViewController *)controller
{
    LSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (!delegate.window) {
        delegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [delegate.window makeKeyAndVisible];
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [delegate.window setRootViewController:navigationController];
    [delegate.window makeKeyAndVisible];
}

- (void)pushViewController:(UIViewController *)controller
{
    LSAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (!delegate.window.rootViewController) {
        delegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        delegate.window.rootViewController = controller;
        [delegate.window makeKeyAndVisible];
    }
    [delegate.window setRootViewController:controller];
    [delegate.window makeKeyAndVisible];
}

@end