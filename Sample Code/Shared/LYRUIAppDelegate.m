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

static BOOL LYRIsRunningTests()
{
    return (NSClassFromString(@"XCTestCase") || [[[NSProcessInfo processInfo] environment] valueForKey:@"XCInjectBundle"]);
}

@interface LYRUIAppDelegate ()

@end

@implementation LYRUIAppDelegate

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (!LYRIsRunningTests()) {
        LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
        LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
        LYRUISampleConversationListViewController *controller = [LYRUISampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)layerClient];
        UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        // Add the navigation controller to the main window and make it visible
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = rootViewController;
        [self.window makeKeyAndVisible];
    }
    return YES;
}


//// Get app info from Info.plist
//NSBundle *mainBundle = [NSBundle mainBundle];
//NSString *viewControllerClassName = [mainBundle objectForInfoDictionaryKey:@"LYRUILaunchViewControllerClass"];
//
//// Setup the initial view controller
//UIViewController *firstViewController = [[NSClassFromString(viewControllerClassName) alloc] init];
//firstViewController.title = [(NSString *)[mainBundle objectForInfoDictionaryKey:@"CFBundleName"] stringByAppendingString:@" sample"];

@end
