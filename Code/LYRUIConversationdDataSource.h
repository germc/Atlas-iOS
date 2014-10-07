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

@interface LYRUIConversationdDataSource : LYRUIChangeNotificationObserver

- (instancetype)initWithLayerClient:(LYRClient *)layerClient;

@property (nonatomic) NSArray *identifiers;

@end
