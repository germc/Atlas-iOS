//
//  LYRUIDataSourceChange.h
//  Pods
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import <Foundation/Foundation.h>

/**
*  An enum that defines the change type.
*/

typedef NS_ENUM(NSInteger, LYRUIDataSourceChangeType) {
    /**
     *  The item was inserted. The `newIndex` will be the index in which it was inserted.
     */
    LYRUIDataSourceChangeTypeInsert,
    /**
     *  The item was moved from `oldIndex` to `newIndex`.
     */
    LYRUIDataSourceChangeTypeMove,
    /**
     *  The item was updated.
     */
    LYRUIDataSourceChangeTypeUpdate,
    /**
     *  The item was deleted.
     */
    LYRUIDataSourceChangeTypeDelete,
    /**
     *  All items were deleted.
     */
    LYRUIDataSourceChangeTypeDeleteAll,
};

@interface LYRUIDataSourceChange : NSObject

+ (instancetype)changeObjectWithType:(LYRUIDataSourceChangeType)type newIndex:(NSUInteger)newIndex oldIndex:(NSUInteger)oldIndex;

@property (nonatomic) LYRUIDataSourceChangeType type;

@property (nonatomic) NSInteger newIndex;

@property (nonatomic) NSInteger oldIndex;

@end
