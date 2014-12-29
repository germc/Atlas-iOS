//
//  LYRQueryControllerMock.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
//

#import "LYRQueryControllerMock.h"

@implementation LYRQueryControllerMock

+ (instancetype)initWithQuery:(LYRQueryMock *)query
{
    return [[self alloc] initWithQuery:query];
}

- (id)initWithQuery:(LYRQueryMock *)query
{
    self = [super init];
    if (self) {
        _query = query;
    }
    return self;
}

- (NSUInteger)numberOfSections
{
    
}

- (NSUInteger)numberOfObjectsInSection:(NSUInteger)section
{
    
}

- (NSUInteger)count
{
    
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSIndexPath *)indexPathForObject:(id<LYRQueryable>)object
{
    
}

- (BOOL)execute:(NSError **)error
{
    if ([self.query.class isSubclassOfClass:[LYRMessageMock class]]) {
        
    }
}

@end
