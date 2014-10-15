//
//  LYRUIConversationListNotificationObserver.m
//  Pods
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import "LYRUIConversationDataSource.h"
#import "LYRUIDataSourceChange.h"

@interface LYRUIConversationDataSource ()

@property (nonatomic) NSArray *conversations;
@property (nonatomic) NSArray *tempIdentifiers;
@property (nonatomic) dispatch_queue_t conversationOperationQueue;

@end

@implementation LYRUIConversationDataSource

- (instancetype)initWithLayerClient:(LYRClient *)layerClient
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
        _identifiers = [self refreshConversations];
        _conversationOperationQueue = dispatch_queue_create("com.layer.conversationProcess", NULL);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLayerObjectsDidChangeNotification:)
                                                     name:LYRClientObjectsDidChangeNotification
                                                   object:layerClient];
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

- (NSArray *)refreshConversations
{
    NSSet *conversations = [self.layerClient conversationsForIdentifiers:nil];
    NSArray *sortedConversations = [conversations sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.sentAt" ascending:NO]]];
    return [sortedConversations valueForKeyPath:@"identifier"];
}

- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
    dispatch_async(self.conversationOperationQueue, ^{
        NSArray *conversationDelta = [self refreshConversations];
        NSMutableArray *conversationChanges = [self processLayerChangeNotification:notification];
        if (conversationChanges.count > 0) {
            [self dispatchChanges:[self processConversationChanges:conversationChanges withDelta:conversationDelta]];
        }
    });
}

- (NSMutableArray *)processLayerChangeNotification:(NSNotification *)notification
{
    NSMutableArray *conversationChanges = [[NSMutableArray alloc] init];
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        if ([[change objectForKey:LYRObjectChangeObjectKey] isKindOfClass:[LYRConversation class]]) {
            [conversationChanges addObject:change];
        }
    }
    return conversationChanges;
}

- (NSArray *)processConversationChanges:(NSMutableArray *)conversationChanges withDelta:(NSArray *)conversationDelta
{
    NSMutableArray *updateIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *changeObjects = [[NSMutableArray alloc] init];
    for (NSDictionary *conversationChange in conversationChanges) {
        LYRConversation *conversation = [conversationChange objectForKey:LYRObjectChangeObjectKey];
        NSUInteger newIndex = [conversationDelta indexOfObject:conversation.identifier];
        LYRObjectChangeType changeType = (LYRObjectChangeType)[[conversationChange objectForKey:LYRObjectChangeTypeKey] integerValue];
        switch (changeType) {
            case LYRObjectChangeTypeCreate:
                [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeInsert newIndex:newIndex oldIndex:0]];
                break;
                
            case LYRObjectChangeTypeUpdate: {
                NSUInteger oldIndex;
                if ([[conversationChange objectForKey:LYRObjectChangePropertyKey] isEqualToString:@"identifier"]){
                    oldIndex = [self.identifiers indexOfObject:[conversationChange objectForKey:LYRObjectChangeOldValueKey]];
                } else {
                    oldIndex = [self.identifiers indexOfObject:conversation.identifier];
                }
                if (oldIndex != newIndex) {
                    [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeMove newIndex:newIndex oldIndex:oldIndex]];
                } else {
                    if (![updateIndexes containsObject:[NSNumber numberWithInteger:newIndex]]) {
                        [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeUpdate newIndex:newIndex oldIndex:0]];
                        [updateIndexes addObject:[NSNumber numberWithInteger:newIndex]];
                    }
                }
            }
                break;
                
            case LYRObjectChangeTypeDelete:
                [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeDelete newIndex:newIndex oldIndex:0]];
                break;
                
            default:
                break;
        }
    }
    self.identifiers = conversationDelta;
    return changeObjects;
}

- (void)dispatchChanges:(NSArray *)changes
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate observer:self updateWithChanges:changes];
        [self.delegate observer:self didChangeContent:TRUE];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
