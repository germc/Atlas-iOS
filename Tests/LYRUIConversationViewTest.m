//
//  LYRUIConversationViewTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/16/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.


#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LYRUITestInterface.h"
#import "LYRUISampleConversationViewController.h"
#import "LYRUserMock.h"

@interface LYRUIConversationViewTest : XCTestCase

@property (nonatomic) LYRUITestInterface *testInterface;
@property (nonatomic) LYRUISampleConversationViewController *viewController;
@property (nonatomic) LYRConversationMock *conversation;

@end

@implementation LYRUIConversationViewTest

- (void)setUp
{
    [super setUp];
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [LYRUITestInterface testIntefaceWithLayerClient:layerClient];
    
    NSString *message1 = @"Message1";
    LYRUserMock *mockUser1 = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameMarshawn];
    self.conversation = [self.testInterface conversationWithParticipants:[NSSet setWithObject:mockUser1.participantIdentifier] lastMessageText:message1];
    self.viewController = [LYRUISampleConversationViewController conversationViewControllerWithConversation:(LYRConversation *)self.conversation layerClient:(LYRClient *)self.testInterface.layerClient];
    [self setRootViewController:self.viewController];
}

- (void)tearDown
{
    [super tearDown];
    [[LYRMockContentStore sharedStore] resetContentStore];
    [[UIApplication sharedApplication] delegate].window.rootViewController = nil;
    self.testInterface = nil;
}

//Send a new message a verify it appears in the view.
- (void)testToVerifySentMessageAppearsInConversationView
{
    [self sendMessageWithText:@"This is a test"];
}

//Synchronize a new message and verify it appears in the view.
- (void)testToVerifyRecievedMessageAppearsInConversationView
{
    LYRMessagePart *part = [LYRMessagePart messagePartWithText:@"Hey Dude"];
    LYRMessageMock *message = [LYRMessageMock newMessageWithParts:@[part] senderID:[LYRUserMock userWithMockUserName:LYRClientMockFactoryNameMarshawn].participantIdentifier];
    [self.conversation sendMessage:message error:nil];
    
    [tester waitForViewWithAccessibilityLabel:@"Hey Dude"];
}

//Add an image to a message and verify that it sends.
- (void)testToVerifySentImageAppearsInConversationView
{
    [self sendPhotoMessage];
}

//- (void)conversationViewController:(LYRUIConversationViewController *)viewController didSendMessage:(LYRMessage *)message;
- (void)testToVerifyDelegateIsNotifiedOfMessageSend
{
    id delegateMock = OCMProtocolMock(@protocol(LYRUIConversationViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {

    }] conversationViewController:[OCMArg any] didSendMessage:[OCMArg any]];
    
    [self sendMessageWithText:@"This is a test"];
    [delegateMock verify];

}
//- (void)conversationViewController:(LYRUIConversationViewController *)viewController didFailSendingMessage:(LYRMessage *)message error:(NSError *)error;
- (void)testToVerifyDelegateIsNotifiedOfFailedMessageSend
{

}

//- (void)conversationViewController:(LYRUIConversationViewController *)viewController didSelectMessage:(LYRMessage *)message;
- (void)testToVerifyDelegateIsNotifiedOfMessageSelection
{
    id delegateMock = OCMProtocolMock(@protocol(LYRUIConversationViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
       
    }] conversationViewController:[OCMArg any] didSelectMessage:[OCMArg any]];
    
    [self sendMessageWithText:@"This is a test"];
    [tester tapViewWithAccessibilityLabel:@"This is a test"];
    [delegateMock verify];
}

//- (CGFloat)conversationViewController:(LYRUIConversationViewController *)viewController heightForMessage:(LYRMessage *)message withCellWidth:(CGFloat)cellWidth;
- (void)testToVerifyDataSourceCanSetCellHeight
{
    id delegateMock = OCMProtocolMock(@protocol(LYRUIConversationViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        [invocation setReturnValue:(void *)100];
        UICollectionViewCell *cell = (UICollectionViewCell *)[tester waitForViewWithAccessibilityLabel:@"This is a test"];
        expect(cell.frame.size.height).to.equal(100);
    }] conversationViewController:[OCMArg any] heightForMessage:[OCMArg any] withCellWidth:0];
    
    [self sendMessageWithText:@"This is a test"];
    [delegateMock verify];
}

//- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier;
- (void)testToVerityControllerShowCorrectParticipantSuppliedByTheDataSource
{
     [OCMockObject partialMockForObject:anObject]
    id delegateMock = OCMProtocolMock(@protocol(LYRUIConversationViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        LYRUserMock *mock = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby];
        [invocation setReturnValue:&mock];
    }] conversationViewController:[OCMArg any] participantForIdentifier:[OCMArg any]];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        LYRUserMock *mock = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby];
        [invocation setReturnValue:&mock];
    }] conversationViewController:[OCMArg any] participantForIdentifier:[OCMArg any]];
    
    [self sendMessageWithText:@"This is a test"];
    [delegateMock verify];
}

//- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date;
//- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus;
- (void)testToVerityControllerShowCorrectDateSuppliedByTheDataSource
{
    id delegateMock = OCMProtocolMock(@protocol(LYRUIConversationViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Gift"];
        [invocation setReturnValue:&string];
    }] conversationViewController:[OCMArg any] attributedStringForDisplayOfRecipientStatus:[OCMArg any]];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Gift"];
        [invocation setReturnValue:&string];
    }] conversationViewController:[OCMArg any] attributedStringForDisplayOfDate:[OCMArg any]];
    
    [self sendMessageWithText:@"This is a test"];
    [delegateMock verify];
}

//- (BOOL)conversationViewController:(LYRUIConversationViewController *)conversationViewController shouldUpdateRecipientStatusForMessage:(LYRMessage *)message;
- (void)testToVerifyThatDataSourceDeterminesWhenRecipientStatusIsUpdated
{
    id delegateMock = OCMProtocolMock(@protocol(LYRUIConversationViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        LYRUserMock *mock = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby];
        [invocation setReturnValue:&mock];
    }] conversationViewController:[OCMArg any] participantForIdentifier:[OCMArg any]];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        LYRUserMock *mock = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby];
        [invocation setReturnValue:&mock];
    }] conversationViewController:[OCMArg any] participantForIdentifier:[OCMArg any]];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        float yes = 1.0f;
        [invocation setReturnValue:&yes];
    }] conversationViewController:[OCMArg any] shouldUpdateRecipientStatusForMessage:[OCMArg any]];
    
    [self sendMessageWithText:@"This is a test"];
    [delegateMock verify];
}

//- (NSString *)conversationViewController:(LYRUIConversationViewController *)viewController reuseIdentifierForMessage:(LYRMessage *)message;
- (void)testToVerityProvidingCellClassForReuseIdentifier
{
    id delegateMock = OCMProtocolMock(@protocol(LYRUIConversationViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        
    }] conversationViewController:[OCMArg any] reuseIdentifierForMessage:[OCMArg any]];
    
    [self sendMessageWithText:@"This is a test"];
    [delegateMock verify];
}

- (void)sendMessageWithText:(NSString *)messageText
{
    [tester enterText:messageText intoViewWithAccessibilityLabel:@"Text Input View"];
    [tester tapViewWithAccessibilityLabel:@"Send Button"];
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@", messageText]];
}

- (void)sendPhotoMessage
{
    [tester tapViewWithAccessibilityLabel:@"Camera Button"];
    [tester tapViewWithAccessibilityLabel:@"Photo Library"];
    [tester tapViewWithAccessibilityLabel:@"Camera Roll"];
    [tester tapViewWithAccessibilityLabel:@"Photo, Landscape, July 13, 9:28 PM"];
    [tester tapViewWithAccessibilityLabel:@"Send Button"];
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Message: Photo"]];
}

- (void)setRootViewController:(UIViewController *)controller
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [[UIApplication sharedApplication] delegate].window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:navigationController];
    [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
    [tester waitForTimeInterval:1];
}

@end
