//
//  LYRUIMessageCollectionViewCellTest.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 1/26/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LYRUITestInterface.h"
#import "LYRUISampleConversationViewController.h"

@interface LYRUIMessageCollectionViewCellTest : XCTestCase

@property (nonatomic) LYRUITestInterface *testInterface;
@property (nonatomic) LYRConversationMock *conversation;
@property (nonatomic) LYRMessageMock *message;

@end

@implementation LYRUIMessageCollectionViewCellTest

NSString *LYRUITestMessageText = @"Test Message Text";

extern NSString *const LYRUIConversationCollectionViewAccessibilityIdentifier;

- (void)setUp
{
    [super setUp];
    [[LYRMockContentStore sharedStore] resetContentStore];
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [LYRUITestInterface testIntefaceWithLayerClient:layerClient];
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
    LYRUIMessageCollectionViewCell *cell = [LYRUIMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)self.message];
    expect(cell.bubbleViewColor).toNot.beNil;
}

- (void)testToVerifyAvatarImageViewViewIsNotNil
{
    LYRUIMessageCollectionViewCell *cell = [LYRUIMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)self.message];
    expect(cell.avatarImageView).toNot.beNil;
}

- (void)testToVerifyMessageBubbleViewWithText
{
    NSString *test = @"test";
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:@"test"];
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    
    LYRUIMessageCollectionViewCell *cell = [LYRUIMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)message];
    expect(cell.bubbleView.bubbleViewLabel.text).to.equal(test);
    expect(cell.bubbleView.bubbleImageView.image).to.beNil;
}

- (void)testToVerifyMessageBubbleViewWithImage
{
    UIImage *image = [UIImage imageNamed:@"test"];
    LYRMessagePartMock *part = (LYRMessagePartMock *)LYRUIMessagePartWithJPEGImage(image);
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    
    LYRUIMessageCollectionViewCell *cell = [LYRUIMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)message];
    expect(cell.bubbleView.bubbleImageView.image).toNot.beNil;
    expect(cell.bubbleView.bubbleViewLabel.text).to.beNil;
}

- (void)testToVerifyMessageBubbleViewWithLocation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:37.7833 longitude:122.4167];
    LYRMessagePartMock *part = (LYRMessagePartMock *)LYRUIMessagePartWithLocation(location);
    LYRMessageMock *message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];

    LYRUIMessageCollectionViewCell *cell = [LYRUIMessageCollectionViewCell new];
    [cell presentMessage:(LYRMessage *)message];
    expect(cell.bubbleView.bubbleImageView.image).toNot.beNil;
    expect(cell.bubbleView.bubbleViewLabel.text).to.beNil;
}

- (void)testToVerifyCustomMessageTextFont
{
    UIFont *font = [UIFont systemFontOfSize:20];
    [[LYRUIMessageCollectionViewCell appearance] setMessageTextFont:font];
    [self sendMessageWithText:LYRUITestMessageText];

    LYRUIMessageCollectionViewCell *cell = (LYRUIMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:LYRUIConversationCollectionViewAccessibilityIdentifier];
    expect(cell.messageTextFont).to.equal(font);
}

- (void)testToVerifyCustomMessageTextColor
{
    UIColor *color = [UIColor redColor];
    [[LYRUIMessageCollectionViewCell appearance] setMessageTextColor:color];
    [self sendMessageWithText:LYRUITestMessageText];

    LYRUIMessageCollectionViewCell *cell = (LYRUIMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:LYRUIConversationCollectionViewAccessibilityIdentifier];
    expect(cell.messageTextColor).to.equal(color);
}

- (void)testToVerifyCustomMessageLinkTextColor
{
    UIColor *color = [UIColor redColor];
    [[LYRUIMessageCollectionViewCell appearance] setMessageLinkTextColor:color];
    [self sendMessageWithText:@"www.layer.com"];

    LYRUIMessageCollectionViewCell *cell = (LYRUIMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:LYRUIConversationCollectionViewAccessibilityIdentifier];
    expect(cell.messageLinkTextColor).to.equal(color);
}

- (void)testToVerifyCustomBubbleViewColor
{
     UIColor *color = [UIColor redColor];
    [[LYRUIMessageCollectionViewCell appearance] setBubbleViewColor:color];
    [self sendMessageWithText:LYRUITestMessageText];

    LYRUIMessageCollectionViewCell *cell = (LYRUIMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:LYRUIConversationCollectionViewAccessibilityIdentifier];
    expect(cell.bubbleViewColor).to.equal(color);
}

- (void)testToVerifyCustomBubbleViewCornerRadius
{
    NSUInteger radius = 4;
    [[LYRUIMessageCollectionViewCell appearance] setBubbleViewCornerRadius:4];
    [self sendMessageWithText:LYRUITestMessageText];

    LYRUIMessageCollectionViewCell *cell = (LYRUIMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                inCollectionViewWithAccessibilityIdentifier:LYRUIConversationCollectionViewAccessibilityIdentifier];
    expect(cell.bubbleViewCornerRadius).to.equal(radius);
}

- (void)testToVerifyAvatarImageDiameter
{
    [[LYRUIAvatarImageView appearance] setAvatarImageViewDiameter:40];
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameEarl];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:@"test"];
    LYRMessageMock *message = [layerClient newMessageWithParts:@[part] options:nil error:nil];
    [self.conversation sendMessage:message error:nil];
    
    LYRUIMessageCollectionViewCell *cell = (LYRUIMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                     inCollectionViewWithAccessibilityIdentifier:LYRUIConversationCollectionViewAccessibilityIdentifier];
    expect(cell.avatarImageView.avatarImageViewDiameter).to.equal(40);
}

- (void)testToVerifyAvatarImageBackgroundColor
{
    [tester waitForTimeInterval:1];
    [[LYRUIAvatarImageView appearance] setImageViewBackgroundColor:[UIColor redColor]];
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameEarl];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:@"test"];
    LYRMessageMock *message = [layerClient newMessageWithParts:@[part] options:nil error:nil];
    
    [self.conversation sendMessage:message error:nil];

    LYRUIMessageCollectionViewCell *cell = (LYRUIMessageCollectionViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]
                                                                     inCollectionViewWithAccessibilityIdentifier:LYRUIConversationCollectionViewAccessibilityIdentifier];
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
    LYRUISampleConversationViewController *controller = [LYRUISampleConversationViewController conversationViewControllerWithLayerClient:(LYRClient *)self.testInterface.layerClient];;
    controller.conversation = (LYRConversation *)self.conversation;
    [self.testInterface setRootViewController:controller];
}

- (void)resetAppearance
{
    [[LYRUIMessageCollectionViewCell appearance] setMessageTextFont:[UIFont systemFontOfSize:14]];
    [[LYRUIMessageCollectionViewCell appearance] setMessageTextColor:[UIColor blueColor]];
    [[LYRUIMessageCollectionViewCell appearance] setMessageLinkTextColor:[UIColor blueColor]];
    [[LYRUIMessageCollectionViewCell appearance] setBubbleViewColor:[UIColor lightGrayColor]];
    [[LYRUIMessageCollectionViewCell appearance] setBubbleViewCornerRadius:12];
}

@end