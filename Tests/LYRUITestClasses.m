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
    [super updateWithConversationImage:image];
}

- (void)updateWithLastMessageRecipientStatus:(LYRRecipientStatus)recipientStatus
{
    [super updateWithLastMessageRecipientStatus:recipientStatus];
}

@end

#pragma mark - Test Message Cell Implementaion

@implementation LYRUITestMessageCollectionViewCell

- (void)presentMessage:(LYRMessage *)message
{
    [super presentMessage:message];
}

- (void)updateWithMessageSentState:(BOOL)messageSentState
{
    [super updateWithMessageSentState:messageSentState];
}

- (void)updateWithParticipant:(id<LYRUIParticipant>)participant
{
    [super updateWithParticipant:participant];
}

- (void)shouldDisplayAvatarImage:(BOOL)shouldDisplayAvatarImage
{
    [super shouldDisplayAvatarImage:shouldDisplayAvatarImage];
}

- (void)isGroupConversation:(BOOL)isGroupConversation
{
    [super isGroupConversation:isGroupConversation];
}

@end

@implementation LYRUITestParticipantCell

@end

#pragma mark - Test Participnt Data Source Implementaion

@implementation LYRUITestParticipantDataSource

+ (instancetype)dataSourceWithParticipants:(NSSet *)participants
{
    return [[self alloc] initWithParticipants:participants];
}

- (id)initWithParticipants:(NSSet *)participants
{
    self = [super init];
    if (self) {
        _participants = participants;
    }
    return self;
}

- (NSSet *)participantsForParticipantPickerController:(LYRUIParticipantPickerController *)participantPickerController
{
    return self.participants;
}

- (void)participantPickerController:(LYRUIParticipantPickerController *)participantPickerController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSSet *participants))completion
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS %@", searchText];
    NSSet *set = [self.participants filteredSetUsingPredicate:predicate];
    completion(set);
}

- (void)dealloc
{
    
}

@end
