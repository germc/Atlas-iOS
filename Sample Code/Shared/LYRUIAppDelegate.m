//
//  LYRUIAppDelegate.m
//  Conversation
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRUIAppDelegate.h"
#import "LayerKitMock.h"
#import "LYRUISampleConversationListViewController.h"
#import <LayerUIKit/LayerUIKit.h>
#import <UIKit/UIKit.h>
#import "LYRUISampleUtilities.h"

@interface LYRUIAppDelegate ()

@end

@implementation LYRUIAppDelegate

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    
    LYRUISampleConversationListViewController *controller = [LYRUISampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)layerClient];
    controller.displaysConversationImage = YES;
    UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    
    [ self configureUserInterface];
    return YES;
}

- (void)configureUserInterface
{
    [[UICollectionView appearance] setBackgroundColor:LFTBackgroundColor()];
    
    [[UINavigationBar appearance] setBarTintColor:LFTNavBarColor()];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTintColor:LFTGrayColor()];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : LFTGrayColor(),
                                                           NSFontAttributeName : LFTFontWithSize(20)}];

    [[LYRUIConversationTableViewCell appearance] setCellBackgroundColor:LFTBackgroundColor()];
    [[LYRUIConversationTableViewCell appearance] setUnreadMessageIndicatorBackgroundColor:LFTPinkColor()];
    [[LYRUIConversationTableViewCell appearance] setConversationLabelFont:LFTFontWithSize(16)];
    [[LYRUIConversationTableViewCell appearance] setConversationLabelColor:LFTGrayColor()];
    [[LYRUIConversationTableViewCell appearance] setLastMessageLabelFont:LFTFontWithSize(14)];
    [[LYRUIConversationTableViewCell appearance] setLastMessageLabelColor:LFTMediumGrayColor()];
    [[LYRUIConversationTableViewCell appearance] setDateLabelColor:LFTMediumGrayColor()];
    [[LYRUIConversationTableViewCell appearance] setDateLabelFont:LFTFontWithSize(14)];
    
    [[LYRUIMessageCollectionViewCell appearance] setMessageTextFont:LFTFontWithSize(14)];
    [[LYRUIMessageCollectionViewCell appearance] setBubbleViewCornerRadius:4];
    
    [[LYRUIOutgoingMessageCollectionViewCell appearance] setBubbleViewColor:LFTLightGrayColor()];
    [[LYRUIOutgoingMessageCollectionViewCell appearance] setMessageTextColor:LFTGreenColor()];
    
    [[LYRUIIncomingMessageCollectionViewCell appearance] setBubbleViewColor:LFTPinkColor()];
    [[LYRUIIncomingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor whiteColor]];
    
    [[LYRUIMessageInputToolbar appearance] setBarTintColor:LFTBackgroundColor()];
    [[LYRUIMessageInputToolbar appearance] setTranslucent:NO];
    
    [[LYRUIAvatarImageView appearance] setBackgroundColor:[UIColor redColor]];
}

@end
