//
//  LYRUITestUtilities.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/16/14.
//
//

#import "LYRUITestInterface.h"

@interface LYRUITestInterface ()

@end

@implementation LYRUITestInterface

+ (instancetype)testIntefaceWithLayerClient:(LYRClientMock *)layerClient
{
    return [[self alloc] initWithLayerClient:layerClient];
}

- (id)initWithLayerClient:(LYRClientMock *)layerClient
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
        [[LYRMockContentStore sharedStore] setShouldBroadcastChanges:YES];
        
    }
    return self;
}

- (LYRConversationMock *)conversationWithParticipants:(NSSet *)participants lastMessageText:(NSString *)lastMessageText
{
    LYRConversationMock *conversation = [self.layerClient newConversationWithParticipants:participants options:nil error:nil];
    if (lastMessageText) {
        LYRMessagePart *part = [LYRMessagePart messagePartWithText:lastMessageText];
        LYRMessageMock *message = [self.layerClient newMessageWithParts:@[part] options:nil error:nil];
        [conversation sendMessage:message error:nil];
    }
    return conversation;
}

- (NSString *)conversationLabelForConversation:(LYRConversationMock *)conversation
{
    if (!self.layerClient.authenticatedUserID) return @"Not auth'd";
    NSMutableSet *participantIdentifiers = [conversation.participants mutableCopy];
    [participantIdentifiers minusSet:[NSSet setWithObject:self.layerClient.authenticatedUserID]];
    
    if (!participantIdentifiers.count > 0) return @"Personal Conversation";
    
    NSMutableSet *participants = [[LYRUserMock participantsForIdentifiers:conversation.participants] mutableCopy];
    if (!participants.count > 0) return @"No Matching Participants";
    
    // Put the latest message sender's name first
    LYRUserMock *firstUser;
    if (![conversation.lastMessage.sentByUserID isEqualToString:self.layerClient.authenticatedUserID]){
        if (conversation.lastMessage) {
            NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.userID IN %@", conversation.lastMessage.sentByUserID];
            LYRUserMock *lastMessageSender = [[[participants filteredSetUsingPredicate:searchPredicate] allObjects] lastObject];
            if (lastMessageSender) {
                firstUser = lastMessageSender;
                [participants removeObject:lastMessageSender];
            }
        }
    } else {
        firstUser = [[participants allObjects] objectAtIndex:0];
    }
    
    NSString *conversationLabel = firstUser.fullName;
    for (int i = 1; i < [[participants allObjects] count]; i++) {
        LYRUserMock *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
}

- (void)setRootViewController:(UIViewController *)controller
{
    LYRUIAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (!delegate.window) {
        delegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [delegate.window makeKeyAndVisible];
    }
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [delegate.window setRootViewController:navigationController];
    [delegate.window makeKeyAndVisible];
}

- (void)pushViewController:(UIViewController *)controller
{
    LYRUIAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if (!delegate.window.rootViewController) {
        delegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        delegate.window.rootViewController = controller;
        [delegate.window makeKeyAndVisible];
    }
    [delegate.window setRootViewController:controller];
    [delegate.window makeKeyAndVisible];
}

@end