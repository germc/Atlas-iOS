//
//  ATLUIMessageInputBarTest.m
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
#import "ATLTestInterface.h"
#import "ATLSampleConversationViewController.h"
#import "ATLMediaAttachment.h"

@interface ATLConversationViewController ()

@property (nonatomic) ATLConversationDataSource *conversationDataSource;

@end

@interface ATLMessageInputBarTest :XCTestCase

@property (nonatomic) ATLTestInterface *testInterface;
@property (nonatomic) ATLSampleConversationViewController *viewController;

@end

@implementation ATLMessageInputBarTest

extern NSString *const ATLMessageInputToolbarAccessibilityLabel;
extern NSString *const ATLMessageInputToolbarTextInputView;
extern NSString *const ATLMessageInputToolbarAccessibilityLabel;
extern NSString *const ATLMessageInputToolbarCameraButton;
extern NSString *const ATLMessageInputToolbarLocationButton;
extern NSString *const ATLMessageInputToolbarSendButton;

- (void)setUp
{
    [super setUp];

    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [ATLTestInterface testIntefaceWithLayerClient:layerClient];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRConversationMock *conversation1 = [self.testInterface conversationWithParticipants:[NSSet setWithObject:mockUser1.participantIdentifier] lastMessageText:nil];
    
    self.viewController = [ATLSampleConversationViewController conversationViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.conversation = (LYRConversation *)conversation1;
    [self setRootViewController:self.viewController];
}

- (void)tearDown
{
    [[LYRMockContentStore sharedStore] resetContentStore];
    self.testInterface = nil;
    
    [super tearDown];
}

- (void)testToVerifyMessageInputToolbarUI
{
    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarCameraButton];
    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarLocationButton];
    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
}

- (void)testToVerifyToVerifyTextChangesLocationButtonToSendButton
{
    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarLocationButton];
    [tester enterText:@"A" intoViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    
    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLMessageInputToolbarLocationButton];
    
    [tester clearTextFromViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    [tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarLocationButton];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
}

- (void)testToVerifyRightAccessoryButtonDelegateFunctionality
{
    ATLMessageInputToolbar *toolBar = (ATLMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
    id delegateMock = OCMProtocolMock(@protocol(ATLMessageInputToolbarDelegate));
    toolBar.inputToolBarDelegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        ATLMessageInputToolbar *toolbar;
        [invocation getArgument:&toolbar atIndex:2];
        expect(toolBar).to.beKindOf([ATLMessageInputToolbar class]);
    }] messageInputToolbar:[OCMArg any] didTapLeftAccessoryButton:[OCMArg any]];

    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarCameraButton];
    [delegateMock verify];
}

- (void)testToVerifyLeftAccessoryButtonDelegateFunctionality
{
    ATLMessageInputToolbar *toolBar = (ATLMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
    id delegateMock = OCMProtocolMock(@protocol(ATLMessageInputToolbarDelegate));
    toolBar.inputToolBarDelegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        ATLMessageInputToolbar *toolbar;
        [invocation getArgument:&toolbar atIndex:2];
        expect(toolBar).to.beKindOf([ATLMessageInputToolbar class]);
    }] messageInputToolbar:[OCMArg any] didTapRightAccessoryButton:[OCMArg any]];
    
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarLocationButton];
    [delegateMock verify];
}

- (void)testToVerifyMessageEnteredIsConsitentWithMessageToBeSent
{
    ATLMessageInputToolbar *toolBar = (ATLMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
    id delegateMock = OCMProtocolMock(@protocol(ATLMessageInputToolbarDelegate));
    toolBar.inputToolBarDelegate = delegateMock;
    
    NSString *testText = @"This is a test";
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        ATLMessageInputToolbar *toolbar;
        [invocation getArgument:&toolbar atIndex:2];
        NSArray *attachments = toolbar.mediaAttachments;
        expect(attachments.count).to.equal(1);
        ATLMediaAttachment *attachment = [attachments objectAtIndex:0];
        expect(attachment).to.beKindOf([ATLMediaAttachment class]);
        expect(attachment.textRepresentation).to.equal(testText);
    }] messageInputToolbar:[OCMArg any] didTapRightAccessoryButton:[OCMArg any]];
    
    [tester enterText:testText intoViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
    [delegateMock verify];
}

- (void)testToVerifyButtonEnablement
{
    ATLMessageInputToolbar *toolBar = (ATLMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
    expect(toolBar.rightAccessoryButton.highlighted).to.beTruthy;
    expect(toolBar.rightAccessoryButton.enabled).to.beTruthy;
    
    expect(toolBar.leftAccessoryButton.highlighted).to.beTruthy;
    expect(toolBar.leftAccessoryButton.enabled).to.beTruthy;
}

- (void)testToVerifyTextEnterendDoesNotEnableButtons
{
    self.viewController.conversation = nil;
    
    ATLMessageInputToolbar *toolBar = (ATLMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
    toolBar.rightAccessoryButton.enabled = NO;
    toolBar.leftAccessoryButton.enabled = NO;
    
    expect(toolBar.rightAccessoryButton.enabled).to.beFalsy;
    expect(toolBar.leftAccessoryButton.enabled).to.beFalsy;
    
    [tester enterText:@"hi" intoViewWithAccessibilityLabel:@"Message Input Toolbar"];
    expect(toolBar.rightAccessoryButton.enabled).to.beFalsy;
    expect(toolBar.leftAccessoryButton.enabled).to.beFalsy;
}

- (void)testToVerifySendingMessageWithPhoto
{
    ATLMessageInputToolbar *toolBar = self.viewController.messageInputToolbar;
    id delegateMock = OCMProtocolMock(@protocol(ATLMessageInputToolbarDelegate));
    toolBar.inputToolBarDelegate = delegateMock;
    
    __block NSString *testText = @"This is a test";
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        ATLMessageInputToolbar *newToolbar;
        [invocation getArgument:&newToolbar atIndex:2];
        expect(newToolbar).to.equal(toolBar);
        
        NSArray *parts = newToolbar.mediaAttachments;
        expect(parts.count).to.equal(2);
        expect([parts objectAtIndex:0]).to.beKindOf([ATLMediaAttachment class]);
        expect([parts objectAtIndex:1]).to.beKindOf([ATLMediaAttachment class]);
    }] messageInputToolbar:[OCMArg any] didTapRightAccessoryButton:[OCMArg any]];
    
    [tester enterText:testText intoViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    
    UIImage *image = [UIImage imageNamed:@"test-logo"];
    ATLMediaAttachment *imageAttachment = [ATLMediaAttachment mediaAttachmentWithImage:image metadata:nil thumbnailSize:100];
    [toolBar insertMediaAttachment:imageAttachment];
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
    [delegateMock verify];
}

- (void)testToVerifySending1LineOfTextWith2Photos
{
    ATLMessageInputToolbar *toolBar = (ATLMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:@"Message Input Toolbar"];
    id delegateMock = OCMProtocolMock(@protocol(ATLMessageInputToolbarDelegate));
    toolBar.inputToolBarDelegate = delegateMock;
    
    __block NSString *testText = @"This is a test";
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSArray *parts = toolBar.mediaAttachments;
        expect(parts.count).to.equal(3);
        expect([parts objectAtIndex:0]).to.beKindOf([ATLMediaAttachment class]);
        expect([parts objectAtIndex:1]).to.beKindOf([ATLMediaAttachment class]);
        expect([parts objectAtIndex:1]).to.beKindOf([ATLMediaAttachment class]);
    }] messageInputToolbar:toolBar didTapRightAccessoryButton:[OCMArg any]];
    
    [tester enterText:testText intoViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    UIImage *image = [UIImage imageNamed:@"test-logo"];
    ATLMediaAttachment *imageAttachment = [ATLMediaAttachment mediaAttachmentWithImage:image metadata:nil thumbnailSize:100];
    [toolBar insertMediaAttachment:imageAttachment];
    [toolBar insertMediaAttachment:imageAttachment];
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
    [delegateMock verify];
}

- (void)testToVerifySending5Photos
{
    ATLMessageInputToolbar *toolBar = (ATLMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:@"Message Input Toolbar"];
    id delegateMock = OCMProtocolMock(@protocol(ATLMessageInputToolbarDelegate));
    toolBar.inputToolBarDelegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        NSArray *parts = toolBar.mediaAttachments;
        expect(parts.count).to.equal(5);
        expect([parts objectAtIndex:0]).to.beKindOf([ATLMediaAttachment class]);
        expect([parts objectAtIndex:1]).to.beKindOf([ATLMediaAttachment class]);
        expect([parts objectAtIndex:2]).to.beKindOf([ATLMediaAttachment class]);
        expect([parts objectAtIndex:3]).to.beKindOf([ATLMediaAttachment class]);
        expect([parts objectAtIndex:4]).to.beKindOf([ATLMediaAttachment class]);
    }] messageInputToolbar:toolBar didTapRightAccessoryButton:[OCMArg any]];
    
    UIImage *image = [UIImage imageNamed:@"test-logo"];
    ATLMediaAttachment *imageAttachment = [ATLMediaAttachment mediaAttachmentWithImage:image metadata:nil thumbnailSize:100];
    [toolBar insertMediaAttachment:imageAttachment];
    [toolBar insertMediaAttachment:imageAttachment];
    [toolBar insertMediaAttachment:imageAttachment];
    [toolBar insertMediaAttachment:imageAttachment];
    [toolBar insertMediaAttachment:imageAttachment];
    
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
    [delegateMock verify];
}

- (void)testToVerifyHeightOfInputBarIsCapped
{
    ATLMessageInputToolbar *toolBar = (ATLMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:@"Message Input Toolbar"];
    CGFloat toolbarHeight = toolBar.frame.size.height;
    CGFloat toolbarNewHeight;
    toolBar.maxNumberOfLines = 3;
    
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    [tester enterText:@"" intoViewWithAccessibilityLabel:ATLMessageInputToolbarAccessibilityLabel];
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
    ATLMessageInputToolbar *toolBar = (ATLMessageInputToolbar *)[tester waitForViewWithAccessibilityLabel:@"Message Input Toolbar"];
    UIFont *font = toolBar.textInputView.font;
    
    UIImage *image = [UIImage imageNamed:@"test-logo"];
    ATLMediaAttachment *imageAttachment = [ATLMediaAttachment mediaAttachmentWithImage:image metadata:nil thumbnailSize:100];
    [toolBar insertMediaAttachment:imageAttachment];

    [tester clearTextFromViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    expect(font).to.equal(toolBar.textInputView.font);
}

- (void)setRootViewController:(UIViewController *)controller
{
    [self.testInterface presentViewController:controller];
    [tester waitForTimeInterval:1];
}

@end
