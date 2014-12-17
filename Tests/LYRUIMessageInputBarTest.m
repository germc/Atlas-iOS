//
//  LYRUIMessageInputBarTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 10/24/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import <XCTest/XCTest.h>
//#import "LYRUITestInterface.h"
//
//#import "LYRUIConversationViewController.h"
//#import "LYRUIMessageInputToolbar.h"
//#import "LYRUIMessageComposeTextView.h"
//#import "LYRUIMessageInputToolBarTestViewController.h"
//
//@interface LYRUIMessageInputBarTest :XCTestCase
//
//@property (nonatomic) LYRUITestInterface *testInterface;
//@property (nonatomic) LYRUIMessageInputToolBarTestViewController *viewController;
//
//@end
//
//@implementation LYRUIMessageInputBarTest
//
//static NSString *const LSTextInputViewLabel = @"Text Input View";
//static NSString *const LSSendButtonLabel = @"Send Button";
//static NSString *const LSCameraButtonLabel = @"Camera Button";
//
//- (void)setUp
//{
//    [super setUp];
//
//    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
//    self.testInterface = [LYRUITestInterface testInterfaceWithApplicationController:applicationController];
//    
//    self.viewController = [[LYRUIMessageInputToolBarTestViewController alloc] init];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
//    [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:navController animated:YES completion:nil];
//}
//
//- (void)tearDown
//{
//    [[[[UIApplication sharedApplication] delegate] window].rootViewController dismissViewControllerAnimated:YES completion:nil];
//    [super tearDown];
//}
//
//- (void)testToVerifyMessageEnteredIsConsitentWithMessageToBeSent
//{
//    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
//    self.viewController.toolBar.inputToolBarDelegate = delegateMock;
//    
//    __block NSString *testText = @"This is a test";
//    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
//        NSArray *parts = self.viewController.toolBar.messageParts;
//        expect(parts.count).to.equal(1);
//        expect([parts objectAtIndex:0]).to.equal(testText);
//    }] messageInputToolbar:[OCMArg any] didTapRightAccessoryButton:[OCMArg any]];
//    
//    [tester enterText:testText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
//    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
//    [delegateMock verify];
//}
//
//- (void)testToVerifyEmptyStringEnteredDoesNotInvokeDelegate
//{
//    id protocolMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
//    self.viewController.toolBar.delegate = protocolMock;
//
//    [[protocolMock reject] messageInputToolbar:[OCMArg any] didTapRightAccessoryButton:[OCMArg any]];
//    [protocolMock verify];
//    [tester tapViewWithAccessibilityLabel:@"Send Button"];
//}
//
//- (void)testToVerifyLeftAccessoryButtonFunctionality
//{
//    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
//    self.viewController.toolBar.inputToolBarDelegate = delegateMock;
//    
//    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
//
//    }] messageInputToolbar:[OCMArg any] didTapLeftAccessoryButton:[OCMArg any]];
//    
//    [tester tapViewWithAccessibilityLabel:LSCameraButtonLabel];
//    [delegateMock verify];
//}
//
//- (void)testToVerifySendingMessageWithPhoto
//{
//    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
//    self.viewController.toolBar.inputToolBarDelegate = delegateMock;
//    
//    __block NSString *testText = @"This is a test";
//    __block UIImage *testImage = [UIImage imageNamed:@"testImage"];
//    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
//        NSArray *parts = self.viewController.toolBar.messageParts;
//        expect(parts.count).to.equal(2);
//        expect([parts objectAtIndex:0]).to.equal(testText);
//        expect([parts objectAtIndex:1]).to.equal(testImage);
//    }] messageInputToolbar:self.viewController.toolBar didTapRightAccessoryButton:[OCMArg any]];
//    
//    [tester enterText:testText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
//    [self.viewController.toolBar insertImage:testImage];
//    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
//    [delegateMock verify];
//}
//
//- (void)testToVerifySending1LineOfTextWith2Photos
//{
//    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
//    self.viewController.toolBar.inputToolBarDelegate = delegateMock;
//    
//    __block NSString *testText = @"This is a test";
//    __block UIImage *testImage = [UIImage imageNamed:@"testImage"];
//    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
//        NSArray *parts = self.viewController.toolBar.messageParts;
//        expect(parts.count).to.equal(3);
//        expect([parts objectAtIndex:0]).to.equal(testText);
//        expect([parts objectAtIndex:1]).to.equal(testImage);
//        expect([parts objectAtIndex:1]).to.equal(testImage);
//    }] messageInputToolbar:self.viewController.toolBar didTapRightAccessoryButton:[OCMArg any]];
//    
//    [tester enterText:testText intoViewWithAccessibilityLabel:LSTextInputViewLabel];
//    [self.viewController.toolBar insertImage:testImage];
//    [self.viewController.toolBar insertImage:testImage];
//    
//    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
//    [delegateMock verify];
//}
//
//- (void)testToVerifySending5Photos
//{
//    id delegateMock = OCMProtocolMock(@protocol(LYRUIMessageInputToolbarDelegate));
//    self.viewController.toolBar.inputToolBarDelegate = delegateMock;
//
//    __block UIImage *testImage = [UIImage imageNamed:@"testImage"];
//    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
//        NSArray *parts = self.viewController.toolBar.messageParts;
//        expect(parts.count).to.equal(5);
//        expect([parts objectAtIndex:0]).to.equal(testImage);
//        expect([parts objectAtIndex:1]).to.equal(testImage);
//        expect([parts objectAtIndex:2]).to.equal(testImage);
//        expect([parts objectAtIndex:3]).to.equal(testImage);
//        expect([parts objectAtIndex:4]).to.equal(testImage);
//    }] messageInputToolbar:self.viewController.toolBar didTapRightAccessoryButton:[OCMArg any]];
//    
//    [self.viewController.toolBar insertImage:testImage];
//    [self.viewController.toolBar insertImage:testImage];
//    [self.viewController.toolBar insertImage:testImage];
//    [self.viewController.toolBar insertImage:testImage];
//    [self.viewController.toolBar insertImage:testImage];
//    [tester tapViewWithAccessibilityLabel:LSSendButtonLabel];
//    [delegateMock verify];
//}
//
//- (void)testToVerifyHeightOfInputBarIsCapped
//{
//    CGFloat toolbarHeight = self.viewController.toolBar.frame.size.height;
//    CGFloat toolbarNewHeight;
//    self.viewController.toolBar.maxNumberOfLines = 3;
//    
//    [tester tapViewWithAccessibilityLabel:LSTextInputViewLabel];
//    [tester tapViewWithAccessibilityLabel:@"RETURN"];
//    toolbarNewHeight = self.viewController.toolBar.frame.size.height;
//    expect(toolbarNewHeight).to.beGreaterThan(toolbarHeight);
//    toolbarHeight = self.viewController.toolBar.frame.size.height;
//    
//    [tester tapViewWithAccessibilityLabel:@"RETURN"];
//    toolbarNewHeight = self.viewController.toolBar.frame.size.height;
//    expect(toolbarNewHeight).to.beGreaterThan(toolbarHeight);
//    toolbarHeight = self.viewController.toolBar.frame.size.height;
//    
//    [tester tapViewWithAccessibilityLabel:@"RETURN"];
//    toolbarNewHeight = self.viewController.toolBar.frame.size.height;
//    expect(toolbarNewHeight).to.equal(toolbarHeight);
//    toolbarHeight = self.viewController.toolBar.frame.size.height;
//    
//    [tester tapViewWithAccessibilityLabel:@"RETURN"];
//    toolbarNewHeight = self.viewController.toolBar.frame.size.height;
//    expect(toolbarNewHeight).to.equal(toolbarHeight);
//}
//
//- (void)testToVerifySelectingAndRemovingAnImageKeepsFontConsistent
//{
//    UIFont *font = self.viewController.toolBar.textInputView.font;
//    [self.viewController.toolBar insertImage:[UIImage imageNamed:@"testImage"]];
//    [tester clearTextFromViewWithAccessibilityLabel:LSTextInputViewLabel];
//    expect(font).to.equal(self.viewController.toolBar.textInputView.font);
//}
//
//@end
