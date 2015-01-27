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
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [LYRUITestInterface testIntefaceWithLayerClient:layerClient];
    
    LYRUserMock *mockUser1 = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameMarshawn];
    self.conversation = [self.testInterface conversationWithParticipants:[NSSet setWithObject:mockUser1.participantIdentifier] lastMessageText:nil];
    LYRUISampleConversationViewController *controller = [LYRUISampleConversationViewController conversationViewControllerWithConversation:(LYRConversation *)self.conversation
                                                                                                                              layerClient:(LYRClient *)self.testInterface.layerClient];
    [self.testInterface setRootViewController:controller];
}

- (void)tearDown
{
    [[LYRMockContentStore sharedStore] resetContentStore];
    [self resetAppearance];
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
    UIFont *font = [UIFont systemFontOfSize:16];
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


- (void)sendMessageWithText:(NSString *)text
{
    LYRMessagePartMock *part = [LYRMessagePartMock messagePartWithText:text];
    self.message = [self.testInterface.layerClient newMessageWithParts:@[part] options:nil error:nil];
    [self.conversation sendMessage:self.message error:nil];
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
