//
//  LYRUIConversationNotificationObeserver.h
//  Pods
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import "LYRUIChangeNotificationObserver.h"

@interface LYRUIMessageNotificationObserver : LYRUIChangeNotificationObserver

- (id)initWithClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation;

@property (nonatomic)NSArray *messageIdentifiers;

@end
