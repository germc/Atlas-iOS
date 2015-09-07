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
@property (nonatomic) ATLSampleConversationViewController *controller;

@end

@implementation ATLMessageCollectionViewCellTest

NSString *ATLTestMessageText = @"Test Message Text";

extern NSString *const ATLConversationCollectionViewAccessibilityIdentifier;

- (void)setUp
{
    [super setUp];

    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [ATLTestInterface testIntefaceWithLayerClient:layerClient];
    [self setRootViewController];
    [self resetAppearance];
}

- (void)tearDown
{
    [tester waitForAnimationsToFinish];
    self.conversation = nil;
    self.controller = nil;
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
    LYRMessagePartMock *imagePart = ATLMessagePartWithJPEGImage([UIImage new]);
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[imagePart] options:nil error:nil];
    
    ATLMessageCollectionViewCell *cell = [ATLMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)message];
    expect(cell.bubbleView.bubbleImageView.image).willNot.beNil;
    expect(cell.bubbleView.bubbleViewLabel.text).to.beNil;
}

- (void)testToVerifyMessageBubbleViewWithGIF
{
    LYRMessagePartMock *imagePart = ATLMessagePartWithGIFImage([UIImage new]);
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[imagePart] options:nil error:nil];
    
    ATLMessageCollectionViewCell *cell = [ATLMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)message];
    expect(cell.bubbleView.bubbleImageView.image).willNot.beNil;
    expect(cell.bubbleView.bubbleViewLabel.text).to.beNil;
}

- (void)testToVerifyMessageBubbleViewWithLocation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:37.7833 longitude:122.4167];
    
    LYRMessagePartMock *locationPart = ATLMessagePartWithLocation(location);
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[locationPart] options:nil error:nil];

    ATLMessageCollectionViewCell *cell = [ATLMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)message];
    expect(cell.bubbleView.bubbleImageView.image).toNot.beNil;
    expect(cell.bubbleView.bubbleViewLabel.text).to.beNil;
}

- (void)testToVerifyTextCheckingTypeLink
{
    NSString *link = @"www.layer.com";
    NSString *phoneNumber = @"734-769-6526";
    NSString *linkAndPhoneNumber = [NSString stringWithFormat:@"%@ and %@", link, phoneNumber];
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:linkAndPhoneNumber];    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    
    ATLMessageCollectionViewCell *cell = [ATLMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)message];
    
    NSRange linkRange = [linkAndPhoneNumber rangeOfString:link];
    NSDictionary *linkAttributes = [cell.bubbleView.bubbleViewLabel.attributedText attributesAtIndex:linkRange.location effectiveRange:&linkRange];
    expect(linkAttributes[NSUnderlineStyleAttributeName]).to.equal(NSUnderlineStyleSingle);
    
    NSRange phoneNumberRange = [linkAndPhoneNumber rangeOfString:phoneNumber];
    NSDictionary *phoneNumberAttributes = [cell.bubbleView.bubbleViewLabel.attributedText attributesAtIndex:phoneNumberRange.location effectiveRange:&phoneNumberRange];
    expect(phoneNumberAttributes[NSUnderlineStyleAttributeName]).toNot.equal(NSUnderlineStyleSingle);
}

- (void)testToVerifyTextCheckingTypePhoneNumber
{
    NSString *link = @"www.layer.com";
    NSString *phoneNumber = @"734-769-6526";
    NSString *linkAndPhoneNumber = [NSString stringWithFormat:@"%@ and %@", link, phoneNumber];
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:linkAndPhoneNumber];    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    
    ATLMessageCollectionViewCell *cell = [ATLMessageCollectionViewCell new];
    cell.messageTextCheckingTypes = NSTextCheckingTypePhoneNumber;
    [cell presentMessage:(LYRMessage *)message];
    
    NSRange linkRange = [linkAndPhoneNumber rangeOfString:link];
    NSDictionary *linkAttributes = [cell.bubbleView.bubbleViewLabel.attributedText attributesAtIndex:linkRange.location effectiveRange:&linkRange];
    expect(linkAttributes[NSUnderlineStyleAttributeName]).toNot.equal(NSUnderlineStyleSingle);
    
    NSRange phoneNumberRange = [linkAndPhoneNumber rangeOfString:phoneNumber];
    NSDictionary *phoneNumberAttributes = [cell.bubbleView.bubbleViewLabel.attributedText attributesAtIndex:phoneNumberRange.location effectiveRange:&phoneNumberRange];
    expect(phoneNumberAttributes[NSUnderlineStyleAttributeName]).to.equal(NSUnderlineStyleSingle);
}

- (void)testToVerifytextCheckingTypeLinkAndPhoneNumber
{
    NSString *link = @"www.layer.com";
    NSString *phoneNumber = @"734-769-6526";
    NSString *linkAndPhoneNumber = [NSString stringWithFormat:@"%@ and %@", link, phoneNumber];
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:linkAndPhoneNumber];
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    
    ATLMessageCollectionViewCell *cell = [ATLMessageCollectionViewCell new];
    cell.messageTextCheckingTypes = NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber;
    [cell presentMessage:(LYRMessage *)message];
    
    NSRange linkRange = [linkAndPhoneNumber rangeOfString:link];
    NSDictionary *linkAttributes = [cell.bubbleView.bubbleViewLabel.attributedText attributesAtIndex:linkRange.location effectiveRange:&linkRange];
    expect(linkAttributes[NSUnderlineStyleAttributeName]).to.equal(NSUnderlineStyleSingle);
    
    NSRange phoneNumberRange = [linkAndPhoneNumber rangeOfString:phoneNumber];
    NSDictionary *phoneNumberAttributes = [cell.bubbleView.bubbleViewLabel.attributedText attributesAtIndex:phoneNumberRange.location effectiveRange:&phoneNumberRange];
    expect(phoneNumberAttributes[NSUnderlineStyleAttributeName]).to.equal(NSUnderlineStyleSingle);
}

#pragma mark - Outgoing Customization

- (void)testToVerifyOutgoingCustomMessageTextFont
{
    UIFont *font = [UIFont systemFontOfSize:20];
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageTextFont:font];
    [self sendMessageWithText:ATLTestMessageText];

    ATLOutgoingMessageCollectionViewCell *cell = (ATLOutgoingMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.messageTextFont).to.equal(font);
}

- (void)testToVerifyOutgoingCustomMessageTextColor
{
    UIColor *color = [UIColor redColor];
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageTextColor:color];
    [self sendMessageWithText:ATLTestMessageText];

    ATLOutgoingMessageCollectionViewCell *cell = (ATLOutgoingMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.messageTextColor).to.equal(color);
}

- (void)testToVerifyOutgoingCustomMessageLinkTextColor
{
    NSString *testText = @"www.layer.com";
    UIColor *color = [UIColor redColor];
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageLinkTextColor:color];
    [self sendMessageWithText:testText];

    ATLOutgoingMessageCollectionViewCell *cell = (ATLOutgoingMessageCollectionViewCell *)[tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Message: %@", testText]];
    expect(cell.messageLinkTextColor).to.equal(color);
}

- (void)testToVerifyOutgoingCustomBubbleViewColor
{
     UIColor *color = [UIColor redColor];
    [[ATLOutgoingMessageCollectionViewCell appearance] setBubbleViewColor:color];
    [self sendMessageWithText:ATLTestMessageText];

    ATLOutgoingMessageCollectionViewCell *cell = (ATLOutgoingMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.bubbleViewColor).to.equal(color);
}

- (void)testToVerifyOutgoingCustomBubbleViewCornerRadius
{
    NSUInteger radius = 4;
    [[ATLOutgoingMessageCollectionViewCell appearance] setBubbleViewCornerRadius:4];
    [self sendMessageWithText:ATLTestMessageText];

    ATLOutgoingMessageCollectionViewCell *cell = (ATLOutgoingMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.bubbleViewCornerRadius).to.equal(radius);
}

#pragma mark - Incoming Customization

- (void)testToVerifyIncomingCustomMessageTextFont
{
    UIFont *font = [UIFont systemFontOfSize:20];
    [[ATLIncomingMessageCollectionViewCell appearance] setMessageTextFont:font];
    [self createIncomingMesssageWithText:ATLTestMessageText];
    
    ATLIncomingMessageCollectionViewCell *cell = (ATLIncomingMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                            inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.messageTextFont).to.equal(font);
}

- (void)testToVerifyIncomingCustomMessageTextColor
{
    UIColor *color = [UIColor redColor];
    [[ATLIncomingMessageCollectionViewCell appearance] setMessageTextColor:color];
    [self createIncomingMesssageWithText:ATLTestMessageText];
    
    ATLIncomingMessageCollectionViewCell *cell = (ATLIncomingMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                            inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.messageTextColor).to.equal(color);
}

- (void)testToVerifyIncomingCustomMessageLinkTextColor
{
    NSString *testText = @"www.layer.com";
    UIColor *color = [UIColor redColor];
    [[ATLIncomingMessageCollectionViewCell appearance] setMessageLinkTextColor:color];
    [self createIncomingMesssageWithText:testText];
    
    ATLIncomingMessageCollectionViewCell *cell = (ATLIncomingMessageCollectionViewCell *)[tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"Message: %@", testText]];
    expect(cell.messageLinkTextColor).to.equal(color);
}

- (void)testToVerifyIncomingCustomBubbleViewColor
{
    UIColor *color = [UIColor redColor];
    [[ATLIncomingMessageCollectionViewCell appearance] setBubbleViewColor:color];
    [self createIncomingMesssageWithText:ATLTestMessageText];
    
    ATLIncomingMessageCollectionViewCell *cell = (ATLIncomingMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                            inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.bubbleViewColor).to.equal(color);
}

- (void)testToVerifyIncomingCustomBubbleViewCornerRadius
{
    NSUInteger radius = 4;
    [[ATLIncomingMessageCollectionViewCell appearance] setBubbleViewCornerRadius:4];
    [self createIncomingMesssageWithText:ATLTestMessageText];
    
    ATLIncomingMessageCollectionViewCell *cell = (ATLIncomingMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                            inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.bubbleViewCornerRadius).to.equal(radius);
}

- (void)testToVerifyAvatarImageDiameter
{
    [[ATLAvatarImageView appearance] setAvatarImageViewDiameter:40];
    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:@"test"];
    LYRMessageMock *message = [layerClient newMessageWithParts:@[part] options:nil error:nil];
    [tester waitForTimeInterval:0.5];
    [self.conversation sendMessage:message error:nil];
    
    ATLMessageCollectionViewCell *cell = (ATLMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                     inCollectionViewWithAccessibilityIdentifier:ATLConversationCollectionViewAccessibilityIdentifier];
    expect(cell.avatarImageView.avatarImageViewDiameter).to.equal(40);
}

- (void)testToVerifyAvatarImageBackgroundColor
{
    [tester waitForTimeInterval:1];
    [[ATLAvatarImageView appearance] setImageViewBackgroundColor:[UIColor redColor]];
    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:@"test"];
    LYRMessageMock *message = [layerClient newMessageWithParts:@[part] options:nil error:nil];
    [tester waitForTimeInterval:0.5];
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

- (void)createIncomingMesssageWithText:(NSString *)text
{
    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameKevin];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:text];
    LYRMessageMock *message = [layerClient newMessageWithParts:@[part] options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
    [tester waitForAnimationsToFinish];
}

- (void)setRootViewController
{
    ATLUserMock *mockUser1 = [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    ATLUserMock *mockUser2 = [ATLUserMock userWithMockUserName:ATLMockUserNameKevin];
    self.conversation = [self.testInterface conversationWithParticipants:[NSSet setWithObjects:mockUser1.participantIdentifier, mockUser2.participantIdentifier, nil] lastMessageText:nil];
    
    self.controller = [ATLSampleConversationViewController conversationViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];;
    self.controller.conversation = (LYRConversation *)self.conversation;
    [self.testInterface presentViewController:self.controller];
    [tester waitForAnimationsToFinish];
}

- (void)resetAppearance
{
    [[ATLIncomingMessageCollectionViewCell appearance] setMessageTextFont:[UIFont systemFontOfSize:14]];
    [[ATLIncomingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor blackColor]];
    [[ATLIncomingMessageCollectionViewCell appearance] setMessageLinkTextColor:[UIColor blueColor]];
    [[ATLIncomingMessageCollectionViewCell appearance] setBubbleViewColor:ATLLightGrayColor()];
    [[ATLIncomingMessageCollectionViewCell appearance] setBubbleViewCornerRadius:12];
    
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageTextFont:[UIFont systemFontOfSize:14]];
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor whiteColor]];
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageLinkTextColor:[UIColor whiteColor]];
    [[ATLOutgoingMessageCollectionViewCell appearance] setBubbleViewColor:ATLBlueColor()];
    [[ATLOutgoingMessageCollectionViewCell appearance] setBubbleViewCornerRadius:12];
    
    [[ATLAvatarImageView appearance] setBackgroundColor:ATLLightGrayColor()];
}

@end