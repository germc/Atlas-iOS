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

static BOOL ATLIsRunningTests()
{
    return (NSClassFromString(@"XCTestCase") || [[[NSProcessInfo processInfo] environment] valueForKey:@"XCInjectBundle"]);
}

@interface ProgrammaticAppDelegate ()

@end

@implementation ProgrammaticAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    [[LYRMockContentStore sharedStore] hydrateConversationsForAuthenticatedUserID:layerClient.authenticatedUserID count:1];
    
    UIViewController *controller;
    if (ATLIsRunningTests()) {
        controller = [UIViewController new];
    } else {
        controller = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)layerClient];
        controller.view.backgroundColor = [UIColor whiteColor];
    }
    UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
