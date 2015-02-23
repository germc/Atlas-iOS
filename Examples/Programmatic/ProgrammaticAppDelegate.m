//
//  ProgrammaticAppDelegate.m
//  Atlas
//
//  Created by Kevin Coleman on 2/14/15.
//
//

#import "ProgrammaticAppDelegate.h"
#import "ATLSampleConversationListViewController.h"
#import "LayerKitMock.h"
#import <Atlas/Atlas.h>

@interface ProgrammaticAppDelegate ()

@end

@implementation ProgrammaticAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    [[LYRMockContentStore sharedStore] hydrateConversationsForAuthenticatedUserID:layerClient.authenticatedUserID count:10];
    
    ATLSampleConversationListViewController *controller = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)layerClient];
    controller.view.backgroundColor = [UIColor whiteColor];
    UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
