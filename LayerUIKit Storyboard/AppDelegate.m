//
//  AppDelegate.m
//  LayerUIKit Storyboard
//
//  Created by Kevin Coleman on 2/11/15.
//
//

#import "AppDelegate.h"
#import "LYRUIAppDelegate.h"
#import "LayerKitMock.h"
#import "LYRUISampleConversationListViewController.h"
#import "LYRUISampleConversationViewController.h"

#import <LayerUIKit/LayerUIKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    
    UINavigationController *rootNavigationController = (UINavigationController *)[[[application delegate] window] rootViewController];
    LYRUIParticipantTableViewController *controller = rootNavigationController.viewControllers[0];
    controller.participants = [LYRUserMock allMockParticipants];
   // controller.layerClient = (LYRClient *)layerClient;
   // controller.displaysAddressBar = YES;
    
    return YES;
}


@end
