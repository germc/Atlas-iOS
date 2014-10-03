//
//  LYRUIConversationListNotificationObserver.h
//  Pods
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "LYRUIChangeNotificationObserver.h"

@interface LYRUIConversationNotificationObserver : LYRUIChangeNotificationObserver

- (instancetype)initWithLayerClient:(LYRClient *)layerClient conversations:(NSArray *)conversations;

@property (nonatomic) NSArray *conversationIdentifiers;

@end
