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
    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    [[LYRMockContentStore sharedStore] hydrateConversationsForAuthenticatedUserID:layerClient.authenticatedUserID count:1];
    
    ATLSampleConversationListViewController *controller = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)layerClient];
    controller.view.backgroundColor = [UIColor whiteColor];
    UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController:[UIViewController new]];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageTextFont:[UIFont systemFontOfSize:22]];
    [[ATLIncomingMessageCollectionViewCell appearance] setMessageTextFont:[UIFont systemFontOfSize:22]];
    
    return YES;
}

@end
