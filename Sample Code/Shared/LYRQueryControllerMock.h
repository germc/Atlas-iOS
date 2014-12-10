//
//  LYRQueryControllerMock.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
//

#import <Foundation/Foundation.h>
#import "LYRClientMock.h"

@class LYRQueryControllerMock, LYRClientMock;

@protocol LYRQueryControllerMockDelegate <NSObject>

@optional

- (void)queryControllerWillChangeContent:(LYRQueryControllerMock *)queryController;

- (void)queryControllerDidChangeContent:(LYRQueryControllerMock *)queryController;

- (void)queryController:(LYRQueryControllerMock *)controller didChangeObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(LYRQueryControllerChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

@end

@interface LYRQueryControllerMock : NSObject

@property (nonatomic, readonly) LYRQuery *query;
@property (nonatomic, weak) id<LYRQueryControllerMockDelegate> delegate;
@property (nonatomic) LYRClientMock *layerClient;

+ (instancetype)initWithQuery:(LYRQuery *)query;

- (NSUInteger)numberOfSections;

- (NSUInteger)numberOfObjectsInSection:(NSUInteger)section;

- (NSUInteger)count;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForObject:(id<LYRQueryable>)object;

- (BOOL)execute:(NSError **)error;

@end


