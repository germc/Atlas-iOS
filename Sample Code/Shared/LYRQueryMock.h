//
//  LYRQueryMock.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
//

#import <Foundation/Foundation.h>
#import "LYRPredicateMock.h"

@interface LYRQueryMock : NSObject

+ (instancetype)queryWithClass:(Class<LYRQueryable>)queryableClass;

@property (nonatomic, readonly) Class<LYRQueryable> queryableClass;
@property (nonatomic) LYRPredicateMock *predicate;
@property (nonatomic) NSUInteger limit;
@property (nonatomic) NSUInteger offset;
@property (nonatomic) NSArray *sortDescriptors;
@property (nonatomic) LYRQueryResultType resultType;

@end
