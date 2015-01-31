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

@interface LYRUIAppDelegate ()

@end

@implementation LYRUIAppDelegate

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    
    LYRUISampleConversationListViewController *controller = [LYRUISampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)layerClient];
    UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
