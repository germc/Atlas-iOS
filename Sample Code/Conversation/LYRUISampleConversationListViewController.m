//
//  LYRUISampleConversationRootViewController.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRUISampleConversationListViewController.h"
#import "LYRUISampleConversationViewController.h"
#import "LYRClientMock.h"
#import "LYRUIParticipant.h"

@interface LYRUISampleConversationListViewController () <LYRUIConversationListViewControllerDelegate, LYRUIConversationListViewControllerDataSource>

@end

@implementation LYRUISampleConversationListViewController

#pragma mark - Conversation List View Controller Delegate Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Hydrate" style:UIBarButtonItemStylePlain target:self action:@selector(hydrate)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)hydrate
{
    [[LYRMockContentStore sharedStore] hydrateConversationsForAuthenticatedUserID:self.layerClient.authenticatedUserID count:10];
}

- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    LYRUISampleConversationViewController *controller = [LYRUISampleConversationViewController conversationViewControllerWithConversation:conversation layerClient:self.layerClient];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode
{
    NSLog(@"Conversation deleted");
}

- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didFailDeletingConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode error:(NSError *)error
{
    NSLog(@"Failed to delete conversation with error: %@", error);
}

#pragma mark - Conversation List View Controller Data Source Methods

- (NSString *)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController labelForConversation:(LYRConversation *)conversation
{
    if (!self.layerClient.authenticatedUserID) return @"Not auth'd";
    NSMutableSet *participantIdentifiers = [conversation.participants mutableCopy];
    [participantIdentifiers removeObject:self.layerClient.authenticatedUserID];
    
    if (participantIdentifiers.count == 0) return @"Personal Conversation";
    
    NSMutableSet *participants = [[LYRUserMock participantsForIdentifiers:participantIdentifiers] mutableCopy];
    if (participants.count == 0) return @"No Matching Participants";
    
    // Put the latest message sender's name first
    LYRUserMock *firstUser;
    if (![conversation.lastMessage.sentByUserID isEqualToString:self.layerClient.authenticatedUserID]) {
        if (conversation.lastMessage) {
            NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.participantIdentifier IN %@", conversation.lastMessage.sentByUserID];
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

@end
