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
    UIViewController *controller = [[UIViewController alloc] init];
    controller.view.backgroundColor = [UIColor whiteColor];
    UINavigationController *rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
