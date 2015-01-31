//
//  LYRUIDataSourceChange.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import "LYRUIDataSourceChange.h"

@interface LYRUIDataSourceChange ()

@end

@implementation LYRUIDataSourceChange

+ (instancetype)changeObjectWithType:(LYRQueryControllerChangeType)type newIndex:(NSUInteger)newIndex currentIndex:(NSUInteger)currentIndex;
{
    return [[self alloc] initWithType:type newIndex:newIndex currentIndex:currentIndex];
}
            
- (id)initWithType:(LYRQueryControllerChangeType)type newIndex:(NSUInteger)newIndex currentIndex:(NSUInteger)currentIndex
{
    self = [super init];
    if (self) {
        _type = type;
        _newIndex = newIndex;
        _currentIndex = currentIndex;
    }
    return self;
}

@end
