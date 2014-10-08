//
//  LYRUIConversationNotificationObeserver.h
//  Pods
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

@class LYRUIMessageDataSource;

@protocol LYRUIMessageDataSourceDelegate <NSObject>

- (void)observer:(LYRUIMessageDataSource *)observer updateWithChanges:(NSArray *)changes;

@end

@interface LYRUIMessageDataSource : NSObject

- (id)initWithClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation;

@property (nonatomic) NSArray *messages;

@property (nonatomic) LYRClient *layerClient;

@property (nonatomic) id<LYRUIMessageDataSourceDelegate>delegate;

@end
