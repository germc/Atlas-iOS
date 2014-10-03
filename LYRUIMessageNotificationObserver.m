//
//  LYRUIConversationNotificationObeserver.m
//  Pods
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import "LYRUIMessageNotificationObserver.h"
#import "LYRUIDataSourceChange.h"

@interface LYRUIMessageNotificationObserver ()

@property (nonatomic) LYRConversation *conversation;

@end

@implementation LYRUIMessageNotificationObserver

- (id)initWithClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation
{
    self = [super init];
    if (self) {
        
        self.layerClient = layerClient;
        self.conversation = conversation;
        [self refreshIdentifiers];
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

- (void)refreshIdentifiers
{
    self.messageIdentifiers = [[self.layerClient messagesForConversation:self.conversation] valueForKeyPath:@"identifier"];
}

- (void)didReceiveLayerObjectsDidChangeNotification:(NSNotification *)notification;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self processLayerChangeNotification:notification completion:^(NSMutableArray *messageArray) {
            if (messageArray.count > 0) {
                [self processMessageChanges:messageArray completion:^(NSArray *messageChanges) {
                    [self dispatchChanges:messageChanges];
                }];
            }
        }];
    });
}

- (void)processLayerChangeNotification:(NSNotification *)notification completion:(void(^)(NSMutableArray *messageArray))completion
{
    NSMutableArray *messageArray = [[NSMutableArray alloc] init];
    NSArray *changes = [notification.userInfo objectForKey:LYRClientObjectChangesUserInfoKey];
    for (NSDictionary *change in changes) {
        if ([[change objectForKey:LYRObjectChangeObjectKey]isKindOfClass:[LYRMessage class]]) {
            [messageArray addObject:change];
        }
    }
    completion(messageArray);
}

- (void)processMessageChanges:(NSMutableArray *)messageChanges completion:(void(^)(NSArray *messageChanges))completion
{
    NSMutableArray *changeObjects = [[NSMutableArray alloc] init];
    for (NSDictionary *messageChange in messageChanges) {
        LYRMessage *message = [messageChange objectForKey:LYRObjectChangeObjectKey];
        if ([message.conversation.identifier.absoluteString isEqualToString:self.conversation.identifier.absoluteString]) {
            LYRObjectChangeType updateKey = (LYRObjectChangeType)[[messageChange objectForKey:LYRObjectChangeTypeKey] integerValue];
            switch (updateKey) {
                case LYRObjectChangeTypeCreate:
                    NSLog(@"Insert Conversation");
                    [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeInsert newIndex:message.index oldIndex:0]];
                    break;
                    
                case LYRObjectChangeTypeUpdate: {
                    if ([[messageChange objectForKey:LYRObjectChangePropertyKey] isEqualToString:@"index"]) {
                        NSUInteger oldIndex = [[messageChange objectForKey:LYRObjectChangeOldValueKey] integerValue];
                        NSUInteger newIndex = [[messageChange objectForKey:LYRObjectChangeNewValueKey] integerValue];
                        [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeMove newIndex:newIndex oldIndex:oldIndex]];
                    } else {
                        [changeObjects addObject:[LYRUIDataSourceChange changeObjectWithType:LYRUIDataSourceChangeTypeUpdate newIndex:message.index oldIndex:0]];
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
    completion(changeObjects);
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
