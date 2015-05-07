//
//  ATLUIConversationTableViewCellTest.m
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

#import "ATLTestInterface.h"
#import "ATLSampleConversationListViewController.h"

 NSString *const ATLConversationTableViewAccessibilityLabel;
 NSString *const ATLImageMIMETypePlaceholderText;
 NSString *const ATLLocationMIMETypePlaceholderText;

@interface ATLConversationTableViewCellTest : XCTestCase

@property (nonatomic) ATLTestInterface *testInterface;
@property (nonatomic) LYRConversationMock *conversation;

@end

@implementation ATLConversationTableViewCellTest

NSString *ATLLastMessageText = @"ATLLastMessageText";

- (void)setUp
{
    [super setUp];
    
    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [ATLTestInterface testIntefaceWithLayerClient:layerClient];
    
    ATLSampleConversationListViewController *controller = [ATLSampleConversationListViewController conversationListViewControllerWithLayerClient:(LYRClient *)layerClient];
    [self.testInterface presentViewController:controller];
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
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelFont:font];
    [self createNewConversation];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:ATLConversationTableViewAccessibilityIdentifier];
    expect(cell.conversationTitleLabelFont).to.equal(font);
}

- (void)testToVerifyCustomConversationLabelColor
{
    UIColor *redColor = [UIColor redColor];
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelColor:redColor];
    [self createNewConversation];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:ATLConversationTableViewAccessibilityIdentifier];
    expect(cell.conversationTitleLabelColor).to.equal(redColor);
}

- (void)testToVerifyCustomLastMessageLabelFont
{
    UIFont *font = [UIFont systemFontOfSize:16];
    [[ATLConversationTableViewCell appearance] setLastMessageLabelFont:font];
    [self createNewConversation];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:ATLConversationTableViewAccessibilityIdentifier];
    expect(cell.lastMessageLabelFont).to.equal(font);
}

- (void)testToVerifyCustomLastMessageLabelColor
{
    UIColor *redColor = [UIColor redColor];
    [[ATLConversationTableViewCell appearance] setLastMessageLabelColor:redColor];
    [self createNewConversation];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:ATLConversationTableViewAccessibilityIdentifier];
    expect(cell.lastMessageLabelColor).to.equal(redColor);
}

- (void)testToVerifyCustomDateLabelFont
{
    UIFont *font = [UIFont systemFontOfSize:16];
    [[ATLConversationTableViewCell appearance] setDateLabelFont:font];
    [self createNewConversation];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:ATLConversationTableViewAccessibilityIdentifier];
    expect(cell.dateLabelFont).to.equal(font);
}

- (void)testToVerifyCustomDateLabelColor
{
    UIColor *redColor = [UIColor redColor];
    [[ATLConversationTableViewCell appearance] setDateLabelColor:redColor];
    [self createNewConversation];
    
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:ATLConversationTableViewAccessibilityIdentifier];
    expect(cell.dateLabelColor).to.equal(redColor);
}

- (void)testToVerifyCustomUnreadMessageIndicatorBackgrounColor
{
    UIColor *redColor = [UIColor redColor];
    [[ATLConversationTableViewCell appearance] setUnreadMessageIndicatorBackgroundColor:redColor];
    [self createNewConversation];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:ATLConversationTableViewAccessibilityIdentifier];
    expect(cell.unreadMessageIndicatorBackgroundColor).to.equal(redColor);
}

- (void)testToVerifyCustomCellBackgroundColor
{
    UIColor *redColor = [UIColor redColor];
    [[ATLConversationTableViewCell appearance] setCellBackgroundColor:redColor];
    [self createNewConversation];
    ATLConversationTableViewCell *cell = (ATLConversationTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                     inTableViewWithAccessibilityIdentifier:ATLConversationTableViewAccessibilityIdentifier];
    expect(cell.cellBackgroundColor).to.equal(redColor);
}

- (void)testToVerifyLastMessageTextWhenMessageIsAnImage
{
    [self createNewConversation];
    LYRMessagePartMock *imagePart = ATLMessagePartWithJPEGImage([UIImage new]);
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[imagePart] options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
    [tester waitForViewWithAccessibilityLabel:ATLImageMIMETypePlaceholderText];
}

- (void)testToVerifyLastMessageTextWhenMessageIsALocation
{
    [self createNewConversation];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:123.00 longitude:54.00];
    ATLMediaAttachment *attachement = [ATLMediaAttachment mediaAttachmentWithLocation:location];
    NSArray *parts = ATLMessagePartsWithMediaAttachment(attachement);
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:parts options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
    [tester waitForViewWithAccessibilityLabel:ATLLocationMIMETypePlaceholderText];
}

- (void)createNewConversation
{
    NSSet *participants = [NSSet setWithObject:[ATLUserMock userWithMockUserName:ATLMockUserNameKlemen].participantIdentifier];
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:ATLLastMessageText];
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    self.conversation = [self.testInterface.layerClient newConversationWithParticipants:participants options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
}

- (void)resetAppearance
{
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelFont:[UIFont systemFontOfSize:14]];
    [[ATLConversationTableViewCell appearance] setConversationTitleLabelColor:[UIColor blackColor]];
    [[ATLConversationTableViewCell appearance] setLastMessageLabelFont:[UIFont systemFontOfSize:12]];
    [[ATLConversationTableViewCell appearance] setLastMessageLabelColor:[UIColor grayColor]];
    [[ATLConversationTableViewCell appearance] setDateLabelFont:[UIFont systemFontOfSize:12]];
    [[ATLConversationTableViewCell appearance] setDateLabelColor:[UIColor grayColor]];
    [[ATLConversationTableViewCell appearance] setUnreadMessageIndicatorBackgroundColor:ATLBlueColor()];
    [[ATLConversationTableViewCell appearance] setCellBackgroundColor:[UIColor whiteColor]];
    
}

@end
