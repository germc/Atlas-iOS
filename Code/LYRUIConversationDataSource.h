//
//  LYRUIConversationListNotificationObserver.h
//  Pods
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

@class LYRUIConversationDataSource;

@protocol LYRUIConversationDataSourceDelegate<NSObject>

@optional

- (void)observerWillChangeContent:(LYRUIConversationDataSource *)observer;

- (void)observer:(LYRUIConversationDataSource *)observer updateWithChanges:(NSArray *)changes;

- (void)observer:(LYRUIConversationDataSource *)observer didChangeContent:(BOOL)didChangeContent;

@end

@interface LYRUIConversationDataSource : NSObject

- (instancetype)initWithLayerClient:(LYRClient *)layerClient;

@property (nonatomic) NSArray *identifiers;

@property (nonatomic) LYRClient *layerClient;

@property (nonatomic) id<LYRUIConversationDataSourceDelegate>delegate;

@end
