//
//  LYRUIChangeNotificationObserver.h
//  Pods
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

@class LYRUIChangeNotificationObserver;

@protocol LYRUIChangeNotificationObserverDelegate<NSObject>

@optional

- (void)observerWillChangeContent:(LYRUIChangeNotificationObserver *)observer;

- (void)observer:(LYRUIChangeNotificationObserver *)observer updateWithChanges:(NSArray *)changes;

- (void)observerdidChangeContent:(LYRUIChangeNotificationObserver *)observer;

@end

@interface LYRUIChangeNotificationObserver : NSObject

@property (nonatomic, weak) id<LYRUIChangeNotificationObserverDelegate>delegate;

@property (nonatomic) LYRClient *layerClient;

@end
