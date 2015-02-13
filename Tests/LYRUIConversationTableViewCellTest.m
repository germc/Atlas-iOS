//
//  LYRUIConversationTableViewCellTest.m
//  Atlas
//
//  Created by Kevin Coleman on 1/27/15.
//  Copyright (c) 2015 Layer. All rights reserved.
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
#import "LYRUISampleConversationListViewController.h"

@interface LYRUIConversationTableViewCellTest : XCTestCase

@property (nonatomic) LYRUITestInterface *testInterface;
@property (nonatomic) LYRConversationMock *conversation;

@end

@implementation LYRUIConversationTableViewCellTest

NSString *LYRUILastMessageText = @"LYRUILastMessageText";
extern NSString *const LYRUIConversationTableViewAccessibilityIdentifier;
extern NSString *const LYRUIImageMIMETypePlaceholderText;
extern NSString *const LYRUILocationMIMETypePlaceholderText;

- (void)setUp
{
    [super setUp];
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [LYRUITestInterface testIntefaceWithLayerClient:layerClient];
    
    LYRUISampleConversationListViewController *controller = [LYRUISampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)layerClient];
    [self.testInterface setRootViewController:controller];
}

- (void)tearDown
{
    [self resetAppearance];
    [self.conversation delete:LYRDeletionModeAllParticipants error:nil];
    [super tearDown];
}

- (void)testToVerifyCustomConversationLabelFont
{
    UIFont *font = [UIFont systemFontOfSize:16];
    [[LYRUIConversationTableViewCell appearance] setConversationLabelFont:font];
    [self createNewConversation];
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:LYRUIConversationTableViewAccessibilityIdentifier];
    expect(cell.conversationLabelFont).to.equal(font);
}

- (void)testToVerifyCustomConversationLabelColor
{
    UIColor *redColor = [UIColor redColor];
    [[LYRUIConversationTableViewCell appearance] setConversationLabelColor:redColor];
    [self createNewConversation];
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:LYRUIConversationTableViewAccessibilityIdentifier];
    expect(cell.conversationLabelColor).to.equal(redColor);
}

- (void)testToVerifyCustomLastMessageLabelFont
{
    UIFont *font = [UIFont systemFontOfSize:16];
    [[LYRUIConversationTableViewCell appearance] setLastMessageLabelFont:font];
    [self createNewConversation];
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:LYRUIConversationTableViewAccessibilityIdentifier];
    expect(cell.lastMessageLabelFont).to.equal(font);
}

- (void)testToVerifyCustomLastMessageLabelColor
{
    UIColor *redColor = [UIColor redColor];
    [[LYRUIConversationTableViewCell appearance] setLastMessageLabelColor:redColor];
    [self createNewConversation];
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:LYRUIConversationTableViewAccessibilityIdentifier];
    expect(cell.lastMessageLabelColor).to.equal(redColor);
}

- (void)testToVerifyCustomDateLabelFont
{
    UIFont *font = [UIFont systemFontOfSize:16];
    [[LYRUIConversationTableViewCell appearance] setDateLabelFont:font];
    [self createNewConversation];
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:LYRUIConversationTableViewAccessibilityIdentifier];
    expect(cell.dateLabelFont).to.equal(font);
}

- (void)testToVerifyCustomDateLabelColor
{
    UIColor *redColor = [UIColor redColor];
    [[LYRUIConversationTableViewCell appearance] setDateLabelColor:redColor];
    [self createNewConversation];
    
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:LYRUIConversationTableViewAccessibilityIdentifier];
    expect(cell.dateLabelColor).to.equal(redColor);
}

- (void)testToVerifyCustomUnreadMessageIndicatorBackgrounColor
{
    UIColor *redColor = [UIColor redColor];
    [[LYRUIConversationTableViewCell appearance] setUnreadMessageIndicatorBackgroundColor:redColor];
    [self createNewConversation];
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:LYRUIConversationTableViewAccessibilityIdentifier];
    expect(cell.unreadMessageIndicatorBackgroundColor).to.equal(redColor);
}

- (void)testToVerifyCustomCellBackgroundColor
{
    UIColor *redColor = [UIColor redColor];
    [[LYRUIConversationTableViewCell appearance] setCellBackgroundColor:redColor];
    [self createNewConversation];
    LYRUIConversationTableViewCell *cell = (LYRUIConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:LYRUIConversationTableViewAccessibilityIdentifier];
    expect(cell.cellBackgroundColor).to.equal(redColor);
}

- (void)testToVerifyLastMessageTextWhenMessageIsAnImage
{
    [self createNewConversation];
    LYRMessagePart *part = LYRUIMessagePartWithJPEGImage([UIImage imageNamed:@"test"]);
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
    [tester waitForViewWithAccessibilityLabel:LYRUIImageMIMETypePlaceholderText];
}

- (void)testToVerifyLastMessageTextWhenMessageIsALocation
{
    [self createNewConversation];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:123.00 longitude:54.00];
    LYRMessagePart *part = LYRUIMessagePartWithLocation(location);
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
    [tester waitForViewWithAccessibilityLabel:LYRUILocationMIMETypePlaceholderText];
}

- (void)createNewConversation
{
    NSSet *participants = [NSSet setWithObject:[LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby].participantIdentifier];
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:LYRUILastMessageText];
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    self.conversation = [self.testInterface.layerClient newConversationWithParticipants:participants options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
}

- (void)resetAppearance
{
    [[LYRUIConversationTableViewCell appearance] setConversationLabelFont:[UIFont systemFontOfSize:14]];
    [[LYRUIConversationTableViewCell appearance] setConversationLabelColor:[UIColor blackColor]];
    [[LYRUIConversationTableViewCell appearance] setLastMessageLabelFont:[UIFont systemFontOfSize:12]];
    [[LYRUIConversationTableViewCell appearance] setLastMessageLabelColor:[UIColor grayColor]];
    [[LYRUIConversationTableViewCell appearance] setDateLabelFont:[UIFont systemFontOfSize:12]];
    [[LYRUIConversationTableViewCell appearance] setDateLabelColor:[UIColor grayColor]];
    [[LYRUIConversationTableViewCell appearance] setUnreadMessageIndicatorBackgroundColor:LYRUIBlueColor()];
    [[LYRUIConversationTableViewCell appearance] setCellBackgroundColor:[UIColor whiteColor]];
    
}

@end
