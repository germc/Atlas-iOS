//
//  AppDelegate.m
//  LayerUIKit Storyboard
//
//  Created by Kevin Coleman on 2/11/15.
//
//

#import "AppDelegate.h"
#import "LSAppDelegate.h"
#import "LayerKitMock.h"
#import "LYRUISampleConversationListViewController.h"
#import "LYRUISampleConversationViewController.h"
#import "LYRUITestConversationListViewController.h"
#import <LayerUIKit/LayerUIKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    [[LYRMockContentStore sharedStore] hydrateConversationsForAuthenticatedUserID:layerClient.authenticatedUserID count:10];
    
    LYRUITestConversationListViewController *controller = (LYRUITestConversationListViewController *)[[[application delegate] window] rootViewController];
    [controller setLayerClient:layerClient];
    
    return YES;
}


@end
