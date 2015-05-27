//
//  ATLUISampleConversationRootViewController.m
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

#import "ATLSampleConversationListViewController.h"
#import "ATLSampleConversationViewController.h"
#import "LYRClientMock.h"
#import "ATLParticipant.h"
#import "ATLSampleConversationAvatarItem.h"

@interface ATLSampleConversationListViewController () <ATLConversationListViewControllerDelegate, ATLConversationListViewControllerDataSource>

@end

@implementation ATLSampleConversationListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    self.deletionModes = @[@(LYRDeletionModeAllParticipants), @(LYRDeletionModeLocal)];
    
    UIBarButtonItem *new = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(handleNewTap)];
    self.navigationItem.rightBarButtonItem = new;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)handleNewTap
{
    ATLSampleConversationViewController *controller = [ATLSampleConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
    controller.displaysAddressBar = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Conversation List View Controller Delegate Methods

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    ATLSampleConversationViewController *controller = [ATLSampleConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
    controller.conversation = conversation;
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode
{
    NSLog(@"Conversation deleted");
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didFailDeletingConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode error:(NSError *)error
{
    NSLog(@"Failed to delete conversation with error: %@", error);
}

- (id<ATLAvatarItem>)conversationListViewController:(ATLConversationListViewController *)conversationListViewController avatarItemForConversation:(LYRConversation *)conversation
{
    return [ATLSampleConversationAvatarItem new];
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSearchForText:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    NSSet *participants = [ATLUserMock allMockParticipants];
    NSSet *filteredParticipants = [participants filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS %@", searchText]];
    completion(filteredParticipants);
}

#pragma mark - Conversation List View Controller Data Source Methods

- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController titleForConversation:(LYRConversation *)conversation
{
    if (!self.layerClient.authenticatedUserID) return @"Not auth'd";
    NSMutableSet *participantIdentifiers = [conversation.participants mutableCopy];
    [participantIdentifiers removeObject:self.layerClient.authenticatedUserID];
    
    if (participantIdentifiers.count == 0) return @"Personal Conversation";
    
    NSMutableSet *participants = [[ATLUserMock participantsForIdentifiers:participantIdentifiers] mutableCopy];
    if (participants.count == 0) return @"No Matching Participants";
    
    // Put the latest message sender's name first
    ATLUserMock *firstUser;
    if (![conversation.lastMessage.sender.userID isEqualToString:self.layerClient.authenticatedUserID]) {
        if (conversation.lastMessage) {
            NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.participantIdentifier IN %@", conversation.lastMessage.sender.userID];
            ATLUserMock *lastMessageSender = [[[participants filteredSetUsingPredicate:searchPredicate] allObjects] lastObject];
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
        ATLUserMock *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
}

@end
