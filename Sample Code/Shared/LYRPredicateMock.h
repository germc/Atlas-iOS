//
//  LYRPredicateMock.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
//

#import <Foundation/Foundation.h>
#import "LayerKitMock.h"

@interface LYRPredicateMock : NSObject

+ (instancetype)predicateWithProperty:(NSString *)property operator:(LYRPredicateOperator)predicateOperator value:(id)value;

@property (nonatomic, copy, readonly) NSString *property;
@property (nonatomic, readonly) LYRPredicateOperator predicateOperator;
@property (nonatomic, readonly) id value;

@end

@interface LYRCompoundPredicateMock : LYRPredicateMock <NSCopying, NSCoding>

+ (instancetype)compoundPredicateWithType:(LYRCompoundPredicateType)compoundPredicateType subpredicates:(NSArray *)subpredicates;

@property (nonatomic, readonly) LYRCompoundPredicateType compoundPredicateType;
@property (nonatomic, readonly) NSArray *subpredicates;

@end
