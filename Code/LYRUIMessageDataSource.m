//
//  LYRUIConversationNotificationObeserver.m
//  Pods
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import "LYRUIMessageDataSource.h"
#import "LYRUIDataSourceChange.h"

@interface LYRUIMessageDataSource ()

@property (nonatomic) LYRConversation *conversation;
@property (nonatomic) dispatch_queue_t messageOperationQueue;
@property (nonatomic) BOOL newMessageSend;

@end

@implementation LYRUIMessageDataSource

- (id)initWithClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation
{
    self = [super init];
    if (self) {
        _newMessageSend = FALSE;
        _layerClient = layerClient;
        _conversation = conversation;
        _messages = [self fetchMessages];
        _messageOperationQueue = dispatch_queue_create("com.layer.messageProcess", NULL);
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

- (void)sendMessages:(LYRMessage *)message
{
    dispatch_async(self.messageOperationQueue, ^{
        self.newMessageSend = TRUE;
        NSUInteger insertIndex = self.messages.count;
        [self.messages addObject:message];
       
        NSMutableArray *changeObjects = [[NSMutableArray alloc] init];
        [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeInsert newIndex:insertIndex oldIndex:0]];
        if (insertIndex > 0) {
           [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeUpdate newIndex:insertIndex - 1 oldIndex:0]];
        }
        [self dispatchChanges:changeObjects];
    });
}

- (NSMutableArray *)fetchMessages
{
    NSMutableArray *messages = [[[self.layerClient messagesForConversation:self.conversation] array] mutableCopy];
    return messages;
}

- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
    dispatch_async(self.messageOperationQueue, ^{
        NSArray *messageDelta = [self fetchMessages];
        NSMutableArray *messageChanges = [self processLayerChangeNotification:notification];
        if (messageChanges.count > 0) {
            [self dispatchChanges:[self processMessageChanges:messageChanges withDelta:messageDelta]];
        }
    });
}

- (NSMutableArray *)processLayerChangeNotification:(NSNotification *)notification
{
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        if ([[change objectForKey:LYRObjectChangeObjectKey]isKindOfClass:[LYRMessage class]]) {
            LYRMessage *message = [change objectForKey:LYRObjectChangeObjectKey];
            if ([message.conversation.identifier.absoluteString isEqualToString:self.conversation.identifier.absoluteString]) {
                [messageArray addObject:change];
            }
        }
    }
    return messageArray;
}

- (NSMutableArray *)processMessageChanges:(NSMutableArray *)messageChanges withDelta:(NSArray *)messageDelta
{
    NSMutableArray *updateIndexes = [[NSMutableArray alloc] init];
    NSMutableArray *changeObjects = [[NSMutableArray alloc] init];
    for (NSDictionary *messageChange in messageChanges) {
        LYRMessage *message = [messageChange objectForKey:LYRObjectChangeObjectKey];
        if ([message.conversation.identifier.absoluteString isEqualToString:self.conversation.identifier.absoluteString]) {
            LYRObjectChangeType updateKey = (LYRObjectChangeType)[[messageChange objectForKey:LYRObjectChangeTypeKey] integerValue];
            switch (updateKey) {
                case LYRObjectChangeTypeCreate:
                    if (!self.newMessageSend) {
                        [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeInsert newIndex:message.index oldIndex:0]];
                    } else {
                        self.newMessageSend = FALSE;
                    }
                    break;
                    
                case LYRObjectChangeTypeUpdate: {
                    if ([[messageChange objectForKey:LYRObjectChangePropertyKey] isEqualToString:@"index"]) {
                        NSUInteger newIndex = [[messageChange objectForKey:LYRObjectChangeNewValueKey] integerValue];
                        NSUInteger oldIndex = [[messageChange objectForKey:LYRObjectChangeOldValueKey] integerValue];
                        [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeMove newIndex:newIndex oldIndex:oldIndex]];
                    } else {
                        if (![updateIndexes containsObject:[NSNumber numberWithInteger:message.index]]) {
                            [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeUpdate newIndex:message.index oldIndex:0]];
                            [updateIndexes addObject:[NSNumber numberWithInteger:message.index]];
                        }
                    }
                    break;
                }
                    
                case LYRObjectChangeTypeDelete:
                   [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeInsert newIndex:message.index oldIndex:0]];
                    break;
                    
                default:
                    break;
            }
        }
    }
    NSLog(@"Changes %@", changeObjects);
    self.messages = [messageDelta mutableCopy];
     NSLog(@"Message Count: %lu", (unsigned long)self.messages.count);
    return changeObjects;
}

- (void)dispatchChanges:(NSArray *)changes
{
    if (changes.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate observer:self updateWithChanges:changes];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
