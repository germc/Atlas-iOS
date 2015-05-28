//
//  ATLUIConversationViewTest.m
//  Atlas
//
//  Created by Kevin Coleman on 9/16/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
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
#import "ATLUserMock.h"

extern NSString *const ATLAvatarImageViewAccessibilityLabel;

@interface ATLConversationViewController ()

@property (nonatomic) ATLConversationDataSource *conversationDataSource;

@end

@interface ATLConversationViewControllerTest : XCTestCase

@property (nonatomic) ATLTestInterface *testInterface;
@property (nonatomic) ATLConversationViewController *viewController;
@property (nonatomic) LYRConversationMock *conversation;

@end

@implementation ATLConversationViewControllerTest

extern NSString *const ATLMessageInputToolbarTextInputView;
extern NSString *const ATLMessageInputToolbarSendButton;

- (void)setUp
{
    [super setUp];

    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [ATLTestInterface testIntefaceWithLayerClient:layerClient];
    
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    self.conversation = [self.testInterface conversationWithParticipants:[NSSet setWithObject:mockUser1.participantIdentifier] lastMessageText:nil];
}

- (void)tearDown
{
    [tester waitForAnimationsToFinish];
    [self.testInterface dismissPresentedViewController];
    self.viewController.conversationDataSource = nil;
    self.viewController = nil;
    
    [[LYRMockContentStore sharedStore] resetContentStore];
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
    LYRMessageMock *message = [LYRMessageMock newMessageWithParts:@[part] senderID:[ATLUserMock userWithMockUserName:ATLMockUserNameKlemen].participantIdentifier];
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

#pragma mark - ATLConversationViewControllerDelegate

//- (void)conversationViewController:(ATLConversationViewController *)viewController didSendMessage:(LYRMessage *)message;
- (void)testToVerifyDelegateIsNotifiedOfMessageSend
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationViewControllerDelegate));
    self.viewController.delegate = delegateMock;
        
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        ATLConversationViewController *controller;
        [invocation getArgument:&controller atIndex:2];
        expect(controller).to.equal(self.viewController);
        
        LYRMessage *message;
        [invocation getArgument:&message atIndex:3];
        expect(message).to.beKindOf([LYRMessageMock class]);
    }] conversationViewController:[OCMArg any] didSendMessage:[OCMArg any]];
    
    [tester enterText:@"test" intoViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
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
        ATLConversationViewController *controller;
        [invocation getArgument:&controller atIndex:2];
        expect(controller).to.equal(self.viewController);
        
        LYRMessage *message;
        [invocation getArgument:&message atIndex:3];
        expect(message).to.beKindOf([LYRMessageMock class]);
    }] conversationViewController:[OCMArg any] didSelectMessage:[OCMArg any]];
    
    [self sendMessageWithText:@"This is a test"];
    [tester tapViewWithAccessibilityLabel:@"Message: This is a test"];
    [delegateMock verify];
}

//- (CGFloat)conversationViewController:(ATLConversationViewController *)viewController heightForMessage:(LYRMessage *)message withCellWidth:(CGFloat)cellWidth;
- (void)testToVerifyCustomCellHeightForMessage
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        ATLConversationViewController *controller;
        [invocation getArgument:&controller atIndex:2];
        expect(controller).to.equal(self.viewController);
        
        LYRMessage *message;
        [invocation getArgument:&message atIndex:3];
        expect(message).to.beKindOf([LYRMessageMock class]);
        
        CGFloat height = 100;
        [invocation setReturnValue:&height];
    }] conversationViewController:[OCMArg any] heightForMessage:[OCMArg any] withCellWidth:self.viewController.view.bounds.size.width];
    
    [self sendMessageWithText:@"This is a test"];
    [tester tapViewWithAccessibilityLabel:@"Message: This is a test"];
    [delegateMock verify];
}

//- (NSOrderedSet *)conversationViewController:(ATLConversationViewController *)viewController messagesForMediaAttachments:(NSArray *)mediaAttachments;
- (void)testToVerifyCustomMessageObjects
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    NSString *testMessageText = @"This is a test message";
    LYRMessagePart *part = [LYRMessagePart messagePartWithText:testMessageText];
    LYRMessageMock *newMessage = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    __block NSOrderedSet *messages = [[NSOrderedSet alloc] initWithObject:newMessage];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        ATLConversationViewController *controller;
        [invocation getArgument:&controller atIndex:2];
        expect(controller).to.equal(self.viewController);
        
        NSArray *array;
        [invocation getArgument:&array atIndex:3];
        expect(array.count).to.equal(1);
        
        [invocation setReturnValue:&messages];
    }] conversationViewController:[OCMArg any] messagesForMediaAttachments:[OCMArg any]];
    
    [tester enterText:testMessageText intoViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
    [delegateMock verify];
    
    [tester waitForViewWithAccessibilityLabel:testMessageText];
}

- (void)testToVerityControllerDisplaysCorrectDataFromTheDataSource
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    __block NSAttributedString *dateString = [[NSAttributedString alloc] initWithString:@"Test Date" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    __block NSAttributedString *recipientString = [[NSAttributedString alloc] initWithString:@"Recipient Status" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    
    [[[delegateMock stub] andDo:^(NSInvocation *invocation) {
        [invocation setReturnValue:&dateString];
    }] conversationViewController:[OCMArg any] attributedStringForDisplayOfDate:[OCMArg any]];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        [invocation setReturnValue:&recipientString];
    }] conversationViewController:[OCMArg any] attributedStringForDisplayOfRecipientStatus:[OCMArg any]];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        [invocation setReturnValue:&recipientString];
    }] conversationViewController:[OCMArg any] attributedStringForDisplayOfRecipientStatus:[OCMArg any]];
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        [invocation setReturnValue:&recipientString];
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
    ATLUserMock *mockUser2 = [ATLUserMock userWithMockUserName:ATLMockUserNameKevin];
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
    ATLUserMock *mockUser2 = [ATLUserMock userWithMockUserName:ATLMockUserNameKevin];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser2.participantIdentifier];
    [self.conversation addParticipants:[NSSet setWithObject:mockUser2.participantIdentifier] error:nil];
    
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:@"Test"];
    LYRMessageMock *message = [layerClient newMessageWithParts:@[part] options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
    
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    [tester waitForTimeInterval:10];
    [tester waitForViewWithAccessibilityLabel:ATLAvatarImageViewAccessibilityLabel];
}

- (void)testToVerifyCustomAvatarImageDiameter
{
    [[ATLAvatarImageView appearance] setAvatarImageViewDiameter:40];
    
    ATLUserMock *mockUser2 = [ATLUserMock userWithMockUserName:ATLMockUserNameKevin];
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

- (void)testtoVerifyReloadingCellsDuringQueryControllerAnimationDoesNotRaise
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        ATLConversationViewController *controller;
        [invocation getArgument:&controller atIndex:2];
        expect(controller).to.equal(self.viewController);
        
        LYRMessage *message;
        [invocation getArgument:&message atIndex:3];
        expect(message).to.beKindOf([LYRMessageMock class]);
        
        expect(^{[self.viewController reloadCellForMessage:message];}).toNot.raise(NSInternalInconsistencyException);
    }] conversationViewController:[OCMArg any] didSendMessage:[OCMArg any]];
    
    [tester enterText:@"test" intoViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
    [delegateMock verify];
}

- (void)testToVerifyReloadingCellsForMutlitpleMessagesDoesNotRaise
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    [tester enterText:@"test" intoViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
    
    [tester enterText:@"test" intoViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
    
    [tester enterText:@"test" intoViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationViewControllerDelegate));
    self.viewController.delegate = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        ATLConversationViewController *controller;
        [invocation getArgument:&controller atIndex:2];
        expect(controller).to.equal(self.viewController);
        
        LYRMessage *message;
        [invocation getArgument:&message atIndex:3];
        expect(message).to.beKindOf([LYRMessageMock class]);
        
        expect(^{[self.viewController reloadCellsForMessagesSentByParticipantWithIdentifier:self.viewController.layerClient.authenticatedUserID];}).toNot.raise(NSInternalInconsistencyException);
    }] conversationViewController:[OCMArg any] didSendMessage:[OCMArg any]];
    
    [tester enterText:@"test" intoViewWithAccessibilityLabel:ATLMessageInputToolbarTextInputView];
    [tester tapViewWithAccessibilityLabel:ATLMessageInputToolbarSendButton];
    [delegateMock verify];
}

- (void)testToVerifyDefaultQueryConfigurationDataSourceMethod
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        ATLConversationListViewController *controller;
        [invocation getArgument:&controller atIndex:2];
        expect(controller).to.equal(self.viewController);
        
        LYRQuery *query;
        [invocation getArgument:&query atIndex:3];
        expect(query).toNot.beNil();
        
        [invocation setReturnValue:&query];
    }] conversationViewController:[OCMArg any] willLoadWithQuery:[OCMArg any]];

    self.viewController.conversation = [self.viewController.layerClient newConversationWithParticipants:[NSSet setWithObject:@"test"] options:nil error:nil];
    [delegateMock verifyWithDelay:1];
}

- (void)testToVerifyQueryConfigurationTakesEffect
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    __block NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        ATLConversationListViewController *controller;
        [invocation getArgument:&controller atIndex:2];
        expect(controller).to.equal(self.viewController);
        
        LYRQuery *query;
        [invocation getArgument:&query atIndex:3];
        expect(query).toNot.beNil();
        
        query.sortDescriptors = @[sortDescriptor];
        [invocation setReturnValue:&query];
    }] conversationViewController:[OCMArg any] willLoadWithQuery:[OCMArg any]];
    
    self.viewController.conversation = [self.viewController.layerClient newConversationWithParticipants:[NSSet setWithObject:@"test"] options:nil error:nil];
    [delegateMock verifyWithDelay:1];
    
    expect(self.viewController.conversationDataSource.queryController.query.sortDescriptors).to.contain(sortDescriptor);
}

- (void)testToVerifyControllerAssertsIfNoQueryIsReturned
{
    [self setupConversationViewController];
    [self setRootViewController:self.viewController];
    
    id delegateMock = OCMProtocolMock(@protocol(ATLConversationViewControllerDataSource));
    self.viewController.dataSource = delegateMock;
    
    expect(^{
        [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
            ATLConversationListViewController *controller;
            [invocation getArgument:&controller atIndex:2];
            expect(controller).to.equal(self.viewController);
            
            LYRQuery *query;
            [invocation getArgument:&query atIndex:3];
            expect(query).toNot.beNil();
            
        }] conversationViewController:[OCMArg any] willLoadWithQuery:[OCMArg any]];
        
        self.viewController.conversation = [self.viewController.layerClient newConversationWithParticipants:[NSSet setWithObject:@"test"] options:nil error:nil];
        [delegateMock verifyWithDelay:1];
    }).to.raise(NSInvalidArgumentException);
}

- (void)setupConversationViewController
{
    self.viewController = [ATLSampleConversationViewController conversationViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];
    self.viewController.conversation = (LYRConversation *)self.conversation;
}

- (void)sendMessageWithText:(NSString *)messageText
{
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:messageText];
    NSError *error;
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:&error];
    expect(error).to.beNil;
    [self.conversation sendMessage:message error:&error];
    expect(error).to.beNil;
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@", messageText]];
}

- (void)sendPhotoMessage
{
    UIImage *image = [UIImage imageNamed:@"test-logo"];
    ATLMediaAttachment *attachement = [ATLMediaAttachment mediaAttachmentWithImage:image metadata:nil thumbnailSize:100];
    NSError *error;
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:ATLMessagePartsWithMediaAttachment(attachement) options:nil error:&error];
    expect(error).to.beNil;
    [self.conversation sendMessage:message error:&error];
    expect(error).to.beNil;
    [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Message: Image"]];
}

- (void)setRootViewController:(UIViewController *)controller
{
    [self.testInterface presentViewController:controller];
    [tester waitForAnimationsToFinish];
}

@end
