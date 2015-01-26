//
//  LYRUITestUtilities.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/16/14.
//
//

#import <Foundation/Foundation.h>
#import "LYRClientMock.h"

// Testing Imports
#import <OCMock/OCMock.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "LYRCountDownLatch.h"
#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import <LayerUIKit/LayerUIKit.h>
#import "LYRUIAppDelegate.h"
#import "LYRUITestClasses.h"
#import "LYRMockContentStore.h"

@interface LYRUITestInterface : NSObject

@property (nonatomic)LYRClientMock *layerClient;

+ (instancetype)testIntefaceWithLayerClient:(LYRClientMock *)layerClient;

- (LYRConversationMock *)conversationWithParticipants:(NSSet *)participants lastMessageText:(NSString *)lastMessageText;

- (NSString *)conversationLabelForConversation:(LYRConversationMock *)conversation;

- (void)setRootViewController:(UIViewController *)controller;

- (void)pushViewController:(UIViewController *)controller;


@end
