//
//  ATLUIConversationViewTest.m
//  Atlas
//
//  Created by Kevin Coleman on 9/16/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.


#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ATLTestInterface.h"
#import "ATLSampleConversationViewController.h"
#import "LYRUserMock.h"

extern NSString *const ATLAvatarImageViewAccessibilityLabel;

@interface ATLConversationViewController ()

@property (nonatomic) LYRQueryController *queryController;

@end

@interface ATLConversationViewTest : XCTestCase

@property (nonatomic) ATLTestInterface *testInterface;
@property (nonatomic) ATLSampleConversationViewController *viewController;
@property (nonatomic) LYRConversationMock *conversation;

@end

@implementation ATLConversationViewTest

- (void)setUp
{
    [super setUp];

    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [ATLTestInterface testIntefaceWithLayerClient:layerClient];
    
    LYRUserMock *mockUser1 = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameMarshawn];
    self.conversation = [self.testInterface conversationWithParticipants:[NSSet setWithObject:mockUser1.participantIdentifier] lastMessageText:nil];
}

- (void)tearDown
{
    [[LYRMockContentStore sharedStore] resetContentStore];
    self.viewController.queryController = nil;
    self.testInterface = nil;
    
    [super tearDown];
}

//Send a new message a verify it appears in the view.
- (void)testToVerifySentMessageAppearsInConversationView
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    [self sendMessageWithText:@"This is a test"];
}

//Synchronize a new message and verify it appears in the view.
- (void)testToVerifyRecievedMessageAppearsInConversationView
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    LYRMessagePart *part = [LYRMessagePart messagePartWithText:@"Hey Dude"];
    LYRMessageMock *message = [LYRMessageMock newMessageWithParts:@[part] senderID:[LYRUserMock userWithMockUserName:LYRClientMockFactoryNameMarshawn].participantIdentifier];
    [self.conversation sendMessage:message error:nil];
    
    [tester waitForViewWithAccessibilityLabel:@"Hey Dude"];
}

//Add an image to a message and verify that it sends.
- (void)testToVerifySentImageAppearsInConversationView
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    [self sendPhotoMessage];
}

- (void)testToVerifyCorrectCellIsReturnedForMessage
{
    LYRMessagePartMock *messagePart1 = [LYRMessagePartMock messagePartWithText:@"How are you1?"];
    LYRMessageMock *message1 = [self.testInterface.layerClient newMessageWithParts:@[messagePart1] options:nil error:nil];
    [self.conversation sendMessage:message1 error:nil];
    
    LYRMessagePartMock *messagePart2 = [LYRMessagePartMock messagePartWithText:@"How are you2?"];
    LYRMessageMock *message2 = [self.testInterface.layerClient newMessageWithParts:@[messagePart2] options:nil error:nil];
    [self.conversation sendMessage:message2 error:nil];

    LYRMessagePartMock *messagePart3 = [LYRMessagePartMock messagePartWithText:@"How are you3?"];
    LYRMessageMock *message3 = [self.testInterface.layerClient newMessageWithParts:@[messagePart3] options:nil error:nil];
    [self.conversation sendMessage:message3 error:nil];

    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    id cell = [self.viewController collectionViewCellForMessage:(LYRMessage *)message3];
    expect([cell class]).to.beSubclassOf([ATLMessageCollectionViewCell class]);
    expect([cell accessibilityLabel]).to.equal(@"Message: How are you3?");
}

//- (void)conversationViewController:(ATLConversationViewController *)viewController didSendMessage:(LYRMessage *)message;
- (void)testToVerifyDelegateIsNotifiedOfMessageSend
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {

    }] conversationViewController:[OCMArg any] didSendMessage:[OCMArg any]];
    
    [self sendMessageWithText:@"This is a test"];
    [delegateMock verify];
}

//- (void)conversationViewController:(ATLConversationViewController *)viewController didSelectMessage:(LYRMessage *)message;
- (void)testToVerifyDelegateIsNotifiedOfMessageSelection
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
       
    }] conversationViewController:[OCMArg any] didSelectMessage:[OCMArg any]];
    
    [self sendMessageWithText:@"This is a test"];
    [tester tapViewWithAccessibilityLabel:@"Message: This is a test"];
    [delegateMock verify];
}

- (void)testToVerityControllerDisplaysCorrectDataFromTheDataSource
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Gift"];
        [invocation setReturnValue:&string];
    }] conversationViewController:[OCMArg any] attributedStringForDisplayOfDate:[OCMArg any]];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Recipient Status"];
        [invocation setReturnValue:&string];
    }] conversationViewController:[OCMArg any] attributedStringForDisplayOfRecipientStatus:[OCMArg any]];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"Recipient Status"];
        [invocation setReturnValue:&string];
    }] conversationViewController:[OCMArg any] attributedStringForDisplayOfRecipientStatus:[OCMArg any]];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSString *identifer = @"ATLOutgoingMessageCellIdentifier";
        [invocation setReturnValue:&identifer];
    }] conversationViewController:[OCMArg any] reuseIdentifierForMessage:[OCMArg any]];
    
    [self sendMessageWithText:@"This is a test"];
    [delegateMock verify];
}

- (void)testToVerifyAvatarImageIsNotDisplayedInOneOnOneConversation
{
    LYRUserMock *mockUser2 = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameEarl];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser2.participantIdentifier];
    self.conversation = [self.testInterface conversationWithParticipants:[NSSet setWithObject:mockUser2.participantIdentifier] lastMessageText:nil];
    
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:@"Test"];
    LYRMessageMock *message = [layerClient newMessageWithParts:@[part] options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
    
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLAvatarImageViewAccessibilityLabel];
}


- (void)testToVerifyAvatarImageIsDisplayedInGroupConversation
{
    LYRUserMock *mockUser2 = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameEarl];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser2.participantIdentifier];
    [self.conversation addParticipants:[NSSet setWithObject:mockUser2.participantIdentifier] error:nil];
    
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:@"Test"];
    LYRMessageMock *message = [layerClient newMessageWithParts:@[part] options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
    
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    [tester waitForViewWithAccessibilityLabel:ATLAvatarImageViewAccessibilityLabel];
}

- (void)testToVerifyCustomAvatarImageDiameter
{
    [[ATLAvatarImageView appearance] setAvatarImageViewDiameter:40];
    
    LYRUserMock *mockUser2 = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameEarl];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser2.participantIdentifier];
    [self.conversation addParticipants:[NSSet setWithObject:mockUser2.participantIdentifier] error:nil];
    
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:@"Test"];
    LYRMessageMock *message = [layerClient newMessageWithParts:@[part] options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
    
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    ATLAvatarImageView *imageView = (ATLAvatarImageView *)[tester waitForViewWithAccessibilityLabel:ATLAvatarImageViewAccessibilityLabel];
    expect(imageView.avatarImageViewDiameter).to.equal(40);
}

- (void)setupConversationViewController
{
    self.viewController = [ATLSampleConversationViewController conversationViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.conversation = (LYRConversation *)self.conversation;
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
    [tester tapViewWithAccessibilityLabel:@"Photo, Landscape, July 13, 2014, 9:28 PM"];
    [tester tapViewWithAccessibilityLabel:@"Send Button"];
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Message: Photo"]];
}

- (void)setRootViewController:(UIViewController *)controller
{
    [self.testInterface setRootViewController:controller];
    [tester waitForTimeInterval:1];
}

@end
