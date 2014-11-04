//
//  LYRUISampleConversationRootViewController.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRUISampleConversationRootViewController.h"
#import "LYRUISampleConversationsViewController.h"
#import "LYRClientMock.h"
#import "LYRClientMockFactory.h"
#import "LYRUIParticipant.h"

@interface LYRUISampleConversationRootViewController () <UITableViewDataSource>

@property (nonatomic) NSArray *items;

@end

@implementation LYRUISampleConversationRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup the title for this view controller
    self.title = @"Conversation view controller sample";
    
    self.items = @[@{ @"title": @"Conversation with Bob",
                      @"selector": NSStringFromSelector(@selector(presentStaticConversationViewController))},
                   @{ @"title": @"Receiving incoming messages",
                      @"selector": NSStringFromSelector(@selector(presentConversationViewControllerWithTimedIncomingMessages))},];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
}

#pragma mark - UITableViewDataSource delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.items[indexPath.row][@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectorString = self.items[indexPath.row][@"selector"];
    [self performSelector:NSSelectorFromString(selectorString) withObject:nil afterDelay:0];
}

#pragma mark - LYRUIConversationViewController configuration methods

- (void)presentStaticConversationViewController
{
    // Use factory to create a client with some messages.
    LYRClientMockFactory *clientMockFactory = [LYRClientMockFactory clientForAliceWithConversation];
    LYRConversationMock *conversation = [[clientMockFactory.layerClient conversationsForIdentifiers:nil] anyObject];
    
    // Instantiate and configure LYRUISampleConversationsViewController (which
    // inherits the LYRUIConversationViewController)
    LYRUISampleConversationsViewController *viewController = [LYRUISampleConversationsViewController conversationViewControllerWithConversation:(id)conversation layerClient:(id)clientMockFactory.layerClient];
    
    // Present the viewcontroller
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)presentConversationViewControllerWithTimedIncomingMessages
{
    // Use factory to create a client with some messages.
    LYRClientMockFactory *clientMockFactory = [LYRClientMockFactory emptyClientForAlice];
    LYRConversationMock *conversation = [LYRConversationMock conversationWithParticipants:[NSSet setWithArray:@[@"Alice", @"Bob", @"Carol", @"Dee"]]];
    LYRMessageMock *message = [LYRMessageMock messageWithConversation:conversation parts:@[[LYRMessagePart messagePartWithText:@"First!!1!"]]];
    [clientMockFactory.layerClient sendMessage:message error:nil];
    
    // Instantiate and configure LYRUISampleConversationsViewController (which
    // inherits the LYRUIConversationViewController)
    LYRUISampleConversationsViewController *viewController = [LYRUISampleConversationsViewController conversationViewControllerWithConversation:(id)conversation layerClient:(id)clientMockFactory.layerClient];
    
    // Present the viewcontroller
    [self.navigationController pushViewController:viewController animated:YES];
    
    // Start timer
    [clientMockFactory startTimedIncomingMessages];
}

@end
