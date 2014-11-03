//
//  LYRUIAppDelegate.m
//  Conversation
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRUIAppDelegate.h"

@interface LYRUIAppDelegate ()

@end

@implementation LYRUIAppDelegate

#pragma mark - UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Get app info from Info.plist
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *viewControllerClassName = [mainBundle objectForInfoDictionaryKey:@"LYRUILaunchViewControllerClass"];
    
    // Setup the initial view controller
    UIViewController *firstViewController = [[NSClassFromString(viewControllerClassName) alloc] init];
    firstViewController.title = [(NSString *)[mainBundle objectForInfoDictionaryKey:@"CFBundleName"] stringByAppendingString:@" sample"];
    
    // Setup a navigation controller to be the root view controller
    // and have the initial view be the fisrt on the navigation stack.
    UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController:firstViewController];
    
    // Add the navigation controller to the main window and make it visible
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
