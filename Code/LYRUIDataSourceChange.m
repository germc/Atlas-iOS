//
//  LYRUIDataSourceChange.m
//  Pods
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import "LYRUIDataSourceChange.h"

@interface LYRUIDataSourceChange ()

@end

@implementation LYRUIDataSourceChange

+ (instancetype)changeObjectWithType:(LYRUIDataSourceChangeType)type newIndex:(NSUInteger)newIndex oldIndex:(NSUInteger)oldIndex;
{
    return [[self alloc] initWithType:type newIndex:newIndex oldIndex:oldIndex];
}
            
- (id)initWithType:(LYRUIDataSourceChangeType)type newIndex:(NSUInteger)newIndex oldIndex:(NSUInteger)oldIndex
{
    self = [super init];
    if (self) {
        
        _type = type;
        _newIndex = newIndex;
        _oldIndex = oldIndex;
        
    }
    return self;
}

- (NSString *)description
{
    NSString *stringChangeType = [NSString new];
    if (self.type == LYRUIDataSourceChangeTypeInsert) {
        stringChangeType = @"insert";
    } else if (self.type == LYRUIDataSourceChangeTypeUpdate) {
        stringChangeType = @"update";
    } else if (self.type == LYRUIDataSourceChangeTypeDelete) {
        stringChangeType = @"delete";
    } else if (self.type == LYRUIDataSourceChangeTypeMove) {
        stringChangeType = @"move";
    } else if (self.type == LYRUIDataSourceChangeTypeDeleteAll) {
        stringChangeType = @"truncate";
    }
    return [NSString stringWithFormat:@"<%@:%p type:%@ index:%ld oldIndex:%ld>", self.class, self, stringChangeType, (long)self.newIndex, (long)self.oldIndex];
}

@end
