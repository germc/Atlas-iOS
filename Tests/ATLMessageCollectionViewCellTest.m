//
//  ATLUIMessageCollectionViewCellTest.m
//  Atlas
//
//  Created by Kevin Coleman on 1/26/15.
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
#import "ATLSampleConversationViewController.h"

@interface ATLMessageCollectionViewCellTest : XCTestCase

@property (nonatomic) ATLTestInterface *testInterface;
@property (nonatomic) LYRConversationMock *conversation;
@property (nonatomic) LYRMessageMock *message;

@end

@implementation ATLMessageCollectionViewCellTest

NSString *ATLTestMessageText = @"Test Message Text";

extern NSString *const ATLConversationCollectionViewAccessibilityIdentifier;

- (void)setUp
{
    [super setUp];
    [[LYRMockContentStore sharedStore] resetContentStore];
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [ATLTestInterface testIntefaceWithLayerClient:layerClient];
    [self setRootViewController];
   
}

- (void)tearDown
{
    [self resetAppearance];
    [[LYRMockContentStore sharedStore] resetContentStore];
    [super tearDown];
}

- (void)testToVerifyMessageBubbleViewIsNotNil
{
    ATLMessageCollectionViewCell *cell = [ATLMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)self.message];
    expect(cell.bubbleViewColor).toNot.beNil;
}

- (void)testToVerifyAvatarImageViewViewIsNotNil
{
    ATLMessageCollectionViewCell *cell = [ATLMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)self.message];
    expect(cell.avatarImageView).toNot.beNil;
}

- (void)testToVerifyMessageBubbleViewWithText
{
    NSString *test = @"test";
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:@"test"];
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    
    ATLMessageCollectionViewCell *cell = [ATLMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)message];
    expect(cell.bubbleView.bubbleViewLabel.text).to.equal(test);
    expect(cell.bubbleView.bubbleImageView.image).to.beNil;
}

- (void)testToVerifyMessageBubbleViewWithImage
{
    UIImage *image = [UIImage imageNamed:@"test"];
    LYRMessagePartMock *part = (LYRMessagePartMock *)ATLMessagePartWithJPEGImage(image);
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    
    ATLMessageCollectionViewCell *cell = [ATLMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)message];
    expect(cell.bubbleView.bubbleImageView.image).toNot.beNil;
    expect(cell.bubbleView.bubbleViewLabel.text).to.beNil;
}

- (void)testToVerifyMessageBubbleViewWithLocation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:37.7833 longitude:122.4167];
    LYRMessagePartMock *part = (LYRMessagePartMock *)ATLMessagePartWithLocation(location);
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];

    ATLMessageCollectionViewCell *cell = [ATLMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)message];
    expect(cell.bubbleView.bubbleImageView.image).toNot.beNil;
    expect(cell.bubbleView.bubbleViewLabel.text).to.beNil;
}

- (void)testToVerifyCustomMessageTextFont
{
    UIFont *font = [UIFont systemFontOfSize:20];
    [[ATLMessageCollectionViewCell appearance] setMessageTextFont:font];
    [self sendMessageWithText:ATLTestMessageText];

    ATLMessageCollectionViewCell *cell = (ATLMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.messageTextFont).to.equal(font);
}

- (void)testToVerifyCustomMessageTextColor
{
    UIColor *color = [UIColor redColor];
    [[ATLMessageCollectionViewCell appearance] setMessageTextColor:color];
    [self sendMessageWithText:ATLTestMessageText];

    ATLMessageCollectionViewCell *cell = (ATLMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.messageTextColor).to.equal(color);
}

- (void)testToVerifyCustomMessageLinkTextColor
{
    UIColor *color = [UIColor redColor];
    [[ATLMessageCollectionViewCell appearance] setMessageLinkTextColor:color];
    [self sendMessageWithText:@"www.layer.com"];

    ATLMessageCollectionViewCell *cell = (ATLMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.messageLinkTextColor).to.equal(color);
}

- (void)testToVerifyCustomBubbleViewColor
{
     UIColor *color = [UIColor redColor];
    [[ATLMessageCollectionViewCell appearance] setBubbleViewColor:color];
    [self sendMessageWithText:ATLTestMessageText];

    ATLMessageCollectionViewCell *cell = (ATLMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.bubbleViewColor).to.equal(color);
}

- (void)testToVerifyCustomBubbleViewCornerRadius
{
    NSUInteger radius = 4;
    [[ATLMessageCollectionViewCell appearance] setBubbleViewCornerRadius:4];
    [self sendMessageWithText:ATLTestMessageText];

    ATLMessageCollectionViewCell *cell = (ATLMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.bubbleViewCornerRadius).to.equal(radius);
}

- (void)testToVerifyAvatarImageDiameter
{
    [[ATLAvatarImageView appearance] setAvatarImageViewDiameter:40];
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameEarl];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:@"test"];
    LYRMessageMock *message = [layerClient newMessageWithParts:@[part] options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
    
    ATLMessageCollectionViewCell *cell = (ATLMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                     inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.avatarImageView.avatarImageViewDiameter).to.equal(40);
}

- (void)testToVerifyAvatarImageBackgroundColor
{
    [tester waitForTimeInterval:1];
    [[ATLAvatarImageView appearance] setImageViewBackgroundColor:[UIColor redColor]];
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameEarl];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:@"test"];
    LYRMessageMock *message = [layerClient newMessageWithParts:@[part] options:nil error:nil];
    
    [self.conversation sendMessage:message error:nil];

    ATLMessageCollectionViewCell *cell = (ATLMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                     inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.avatarImageView.imageViewBackgroundColor).to.equal([UIColor redColor]);
}

- (void)sendMessageWithText:(NSString *)text
{
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:text];
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
}

- (void)setRootViewController
{
    LYRUserMock *mockUser1 = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameMarshawn];
    LYRUserMock *mockUser2 = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameEarl];
    self.conversation = [self.testInterface conversationWithParticipants:[NSSet setWithObjects:mockUser1.participantIdentifier, mockUser2.participantIdentifier, nil] lastMessageText:nil];
    
    NSLog(@"Conversation %@", self.conversation);
    ATLSampleConversationViewController *controller = [ATLSampleConversationViewController conversationViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];;
    controller.conversation = (LYRConversation *)self.conversation;
    [self.testInterface setRootViewController:controller];
}

- (void)resetAppearance
{
    [[ATLMessageCollectionViewCell appearance] setMessageTextFont:[UIFont systemFontOfSize:14]];
    [[ATLMessageCollectionViewCell appearance] setMessageTextColor:[UIColor blueColor]];
    [[ATLMessageCollectionViewCell appearance] setMessageLinkTextColor:[UIColor blueColor]];
    [[ATLMessageCollectionViewCell appearance] setBubbleViewColor:[UIColor lightGrayColor]];
    [[ATLMessageCollectionViewCell appearance] setBubbleViewCornerRadius:12];
}

@end