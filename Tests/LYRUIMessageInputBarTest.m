//
//  LYRUIMessageInputBarTest.m
//  Atlas
//
//  Created by Kevin Coleman on 10/24/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LYRUITestInterface.h"

#import "LYRUISampleConversationViewController.h"

@interface LYRUIConversationViewController ()

@property (nonatomic) LYRQueryController *queryController;

@end

@interface LYRUIMessageInputBarTest :XCTestCase

@property (nonatomic) LYRUITestInterface *testInterface;
@property (nonatomic) LYRUISampleConversationViewController *viewController;

@end

@implementation LYRUIMessageInputBarTest

static NSString *const LSTextInputViewLabel = @"Text Input View";
static NSString *const LSSendButtonLabel = @"Send Button";
static NSString *const LSCameraButtonLabel = @"Camera Button";

- (void)setUp
{
    [super setUp];

    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [LYRUITestInterface testIntefaceWithLayerClient:layerClient];
    
    LYRUserMock *mockUser1 = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameMarshawn];
    LYRConversationMock *conversation1 = [self.testInterface conversationWithParticipants:[NSSet setWithObject:mockUser1.participantIdentifier] lastMessageText:@"Message1"];
    self.viewController = [LYRUISampleConversationViewController conversationViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.conversation = (LYRConversation *)conversation1;
    [self setRootViewController:self.viewController];
}

- (void)tearDown
{
    [[LYRMockContentStore sharedStore] resetContentStore];
    self.viewController.queryController = nil;
    self.testInterface = nil;
    
    [super tearDown];
}

- (void)testToVerifyMessageEnteredIsConsitentWithMessageToBeSent
{
    LYRUIMessageInputToolbar *toolBar = (LYRUIMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:@"Message Input Toolbar"];
    
    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
    toolBar.inputToolBarDelegate = delegateMock;
    
    __block NSString *testText = @"This is a test";
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSArray *parts = toolBar.messageParts;
        expect(parts.count).to.equal(1);
        expect([parts objectAtIndex:0]).to.equal(testText);
    }] messageInputToolbar:[OCMArg any] didTapRightAccessoryButton:[OCMArg any]];
    
    [tester enterText:testText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
    [delegateMock verify];
}

//Verify that the "Send" button is not enabled until there is content (text, audio, or video) in the message composition field.
- (void)testToVerifyThatSendButtonIsNotEnabledUntilContentIsInput
{
    LYRUIMessageInputToolbar *toolBar = (LYRUIMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:@"Message Input Toolbar"];
    expect(toolBar.rightAccessoryButton.highlighted).to.beFalsy;
    expect(toolBar.rightAccessoryButton.enabled).to.beFalsy;
    
    [tester enterText:@"hi" intoViewWithAccessibilityLabel:@"Message Input Toolbar"];
    expect(toolBar.rightAccessoryButton.highlighted).to.beTruthy;
    expect(toolBar.rightAccessoryButton.enabled).to.beTruthy;
}

- (void)testToVerifyLeftAccessoryButtonFunctionality
{
    LYRUIMessageInputToolbar *toolBar = (LYRUIMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:@"Message Input Toolbar"];
    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
    toolBar.inputToolBarDelegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {

    }] messageInputToolbar:[OCMArg any] didTapLeftAccessoryButton:[OCMArg any]];
    
    [tester tapViewWithAccessibilityLabel:LSCameraButtonLabel];
    [delegateMock verify];
}

- (void)testToVerifySendingMessageWithPhoto
{
    LYRUIMessageInputToolbar *toolBar = self.viewController.messageInputToolbar;
    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
    toolBar.inputToolBarDelegate = delegateMock;
    
    __block NSString *testText = @"This is a test";
    __block UIImage *testImage = [UIImage imageNamed:@"test"];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        LYRUIMessageInputToolbar *newToolbar;
        [invocation getArgument:&newToolbar atIndex:2];
        expect(newToolbar).to.equal(toolBar);
        NSArray *parts = [newToolbar messageParts];
        expect(parts.count).to.equal(2);
        expect([parts objectAtIndex:0]).to.equal(testText);
        expect([parts objectAtIndex:1]).to.equal(testImage);
    }] messageInputToolbar:[OCMArg any] didTapRightAccessoryButton:[OCMArg any]];
    
    [tester enterText:testText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
    [toolBar insertImage:testImage];
    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
    [delegateMock verify];
}

- (void)testToVerifySending1LineOfTextWith2Photos
{
    LYRUIMessageInputToolbar *toolBar = (LYRUIMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:@"Message Input Toolbar"];
    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
    toolBar.inputToolBarDelegate = delegateMock;
    
    __block NSString *testText = @"This is a test";
    __block UIImage *testImage = [UIImage imageNamed:@"test"];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSArray *parts = toolBar.messageParts;
        expect(parts.count).to.equal(3);
        expect([parts objectAtIndex:0]).to.equal(testText);
        expect([parts objectAtIndex:1]).to.equal(testImage);
        expect([parts objectAtIndex:1]).to.equal(testImage);
    }] messageInputToolbar:toolBar didTapRightAccessoryButton:[OCMArg any]];
    
    [tester enterText:testText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
    [toolBar insertImage:testImage];
    [toolBar insertImage:testImage];
    
    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
    [delegateMock verify];
}

- (void)testToVerifySending5Photos
{
    LYRUIMessageInputToolbar *toolBar = (LYRUIMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:@"Message Input Toolbar"];
    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
    toolBar.inputToolBarDelegate = delegateMock;

    __block UIImage *testImage = [UIImage imageNamed:@"test"];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSArray *parts = toolBar.messageParts;
        expect(parts.count).to.equal(5);
        expect([parts objectAtIndex:0]).to.equal(testImage);
        expect([parts objectAtIndex:1]).to.equal(testImage);
        expect([parts objectAtIndex:2]).to.equal(testImage);
        expect([parts objectAtIndex:3]).to.equal(testImage);
        expect([parts objectAtIndex:4]).to.equal(testImage);
    }] messageInputToolbar:toolBar didTapRightAccessoryButton:[OCMArg any]];
    
    [toolBar insertImage:testImage];
    [toolBar insertImage:testImage];
    [toolBar insertImage:testImage];
    [toolBar insertImage:testImage];
    [toolBar insertImage:testImage];
    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
    [delegateMock verify];
}

- (void)testToVerifyHeightOfInputBarIsCapped
{
    LYRUIMessageInputToolbar *toolBar = (LYRUIMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:@"Message Input Toolbar"];
    CGFloat toolbarHeight = toolBar.frame.size.height;
    CGFloat toolbarNewHeight;
    toolBar.maxNumberOfLines = 3;
    
    [tester tapViewWithAccessibilityLabel:LSTextInputViewLabel];
    [tester tapViewWithAccessibilityLabel:@"RETURN"];
    toolbarNewHeight = toolBar.frame.size.height;
    expect(toolbarNewHeight).to.beGreaterThan(toolbarHeight);
    toolbarHeight = toolBar.frame.size.height;
    
    [tester tapViewWithAccessibilityLabel:@"RETURN"];
    toolbarNewHeight = toolBar.frame.size.height;
    expect(toolbarNewHeight).to.beGreaterThan(toolbarHeight);
    toolbarHeight = toolBar.frame.size.height;
    
    [tester tapViewWithAccessibilityLabel:@"RETURN"];
    toolbarNewHeight = toolBar.frame.size.height;
    expect(toolbarNewHeight).to.equal(toolbarHeight);
    toolbarHeight = toolBar.frame.size.height;
    
    [tester tapViewWithAccessibilityLabel:@"RETURN"];
    toolbarNewHeight = toolBar.frame.size.height;
    expect(toolbarNewHeight).to.equal(toolbarHeight);
}

- (void)testToVerifySelectingAndRemovingAnImageKeepsFontConsistent
{
    LYRUIMessageInputToolbar *toolBar = (LYRUIMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:@"Message Input Toolbar"];
    UIFont *font = toolBar.textInputView.font;
    [toolBar insertImage:[UIImage imageNamed:@"testImage"]];
    [tester clearTextFromViewWithAccessibilityLabel:LSTextInputViewLabel];
    expect(font).to.equal(toolBar.textInputView.font);
}

- (void)setRootViewController:(UIViewController *)controller
{
    [self.testInterface setRootViewController:controller];
    [tester waitForTimeInterval:1];
}

@end
