//
//  LYRUISampleConversationRootViewController.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRUISampleConversationListViewController.h"
#import "LYRUISampleConversationsViewController.h"
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    LYRUISampleConversationsViewController *controller = [LYRUISampleConversationsViewController conversationViewControllerWithConversation:conversation layerClient:self.layerClient];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode
{
    
}

- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didFailDeletingConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode error:(NSError *)error
{
    
}

#pragma mark - Conversation List View Controller Data Source Methods

- (NSString *)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController labelForConversation:(LYRConversation *)conversation
{
    return @"Sample Conversation";
}

@end
