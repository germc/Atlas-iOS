//
//  LYRUITestClasses.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 1/19/15.
//
//

#import "LYRUITestClasses.h"

@implementation LYRUITestClasses

@end

#pragma mark - Test Conversation Cell Implementaion

@implementation LYRUITestConversationCell

- (void)presentConversation:(LYRConversation *)conversation
{
    [super presentConversation:conversation];
}

- (void)updateWithConversationLabel:(NSString *)conversationLabel
{
    [super updateWithConversationLabel:conversationLabel];
}

- (void)updateWithConversationImage:(UIImage *)image
{
    [super updateWithAvatarItem:nil];
}

@end

#pragma mark - Test Message Cell Implementaion

@implementation LYRUITestMessageCollectionViewCell

- (void)presentMessage:(LYRMessage *)message
{
    [super presentMessage:message];
}

- (void)updateWithParticipant:(id<LYRUIParticipant>)participant
{
    [super updateWithParticipant:participant];
}

- (void)shouldDisplayAvatarImage:(BOOL)shouldDisplayAvatarImage
{
    [super shouldDisplayAvatarImage:shouldDisplayAvatarImage];
}

@end

@implementation LYRUITestParticipantCell

@end
