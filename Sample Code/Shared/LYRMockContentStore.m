//
//  LYRMockContentStore.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
//

#import "LYRMockContentStore.h"

@interface LYRMockContentStore ()

@property (nonatomic) NSMutableSet *conversations;

@end

@implementation LYRMockContentStore

+ (id)sharedStore
{
    static LYRMockContentStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] init];
    });
    return sharedStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        _conversations = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)insertConversation:(LYRConversationMock *)conversation
{
    [self.conversations addObject:conversation];
}

- (void)updateConversation:(LYRConversation *)conversation
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.identifier == %@", conversation.identifier];
    LYRConversationMock *conversationToRemove = [[self.conversations filteredSetUsingPredicate:predicate] anyObject];
    [self.conversations removeObject:conversationToRemove];
    [self.conversations addObject:conversation];
}

- (void)deleteConversation:(LYRConversation *)conversation
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.identifier == %@", conversation.identifier];
    LYRConversationMock *conversationToRemove = [[self.conversations filteredSetUsingPredicate:predicate] anyObject];
    [self.conversations removeObject:conversationToRemove];
}

- (LYRConversationMock *)conversationForIdentifier:(NSURL *)identifier
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.identifier == %@", identifier];
    return [[self.conversations filteredSetUsingPredicate:predicate] anyObject];
}

- (NSOrderedSet *)allConversations
{
    //return self.conversations;
    return nil;
}

- (void)hydrateConversationsWithCount:(NSUInteger)count
{
    for (int i = 0; i < count; i++) {
        int randomUser = arc4random_uniform(6);
        LYRUserMock *user = [LYRUserMock userWithMockUserName:randomUser];
        LYRConversationMock *conversation = [LYRConversationMock newConversationWithParticipants:[NSSet setWithObject:user] options:nil];
        [self.conversations addObject:conversation];
    }
}

@end
