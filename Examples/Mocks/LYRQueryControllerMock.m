//
//  ATLQueryControllerMock.m
//  Atlas
//
//  Created by Kevin Coleman on 12/8/14.
//  Copyright (c) 2015 Layer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
#import "LYRQueryControllerMock.h"

@interface LYRQueryControllerMock ()

@property (nonatomic) NSOrderedSet *objects;
@property (nonatomic) NSOrderedSet *oldObjects;

@end

@implementation LYRQueryControllerMock

+ (instancetype)initWithQuery:(LYRQuery *)query
{
    return [[self alloc] initWithQuery:query];
}

- (id)initWithQuery:(LYRQuery *)query
{
    self = [super init];
    if (self) {
        _query = query;
        _objects = [NSOrderedSet new];
        _objects = [NSOrderedSet new];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mockObjectsDidChange:)
                                                     name:LYRMockObjectsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (NSUInteger)numberOfSections
{
    return 1;
}

- (NSUInteger)numberOfObjectsInSection:(NSUInteger)section
{
    return self.objects.count;
}

- (NSUInteger)count
{
    return self.objects.count;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.objects objectAtIndex:indexPath.row];
}

- (NSIndexPath *)indexPathForObject:(id<LYRQueryable>)object
{
    NSUInteger row = [self.objects indexOfObject:object];
    return [NSIndexPath indexPathForRow:row inSection:0];
}

- (BOOL)execute:(NSError **)error
{
    self.objects = [[LYRMockContentStore sharedStore] fetchObjectsWithClass:self.query.queryableClass predicate:self.query.predicate sortDescriptior:self.query.sortDescriptors];
    return YES;
}

- (void)mockObjectsDidChange:(NSNotification *)notification
{
    self.oldObjects = [self.objects copy];
    [self execute:nil];
    if ([self.delegate respondsToSelector:@selector(queryControllerWillChangeContent:)]) {
        [self.delegate queryControllerWillChangeContent:self];
    }
    for (NSDictionary *change in notification.object) {
        if ([[change valueForKey:LYRMockObjectChangeObjectKey] isKindOfClass:[LYRConversationMock class]]) {
            if ([(Class)self.query.queryableClass isEqual:[LYRConversation class]]) {
                [self broadcastChange:change];
            }
        } else {
            if (self.query.queryableClass == [LYRMessage class]) {
                [self broadcastChange:change];
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(queryControllerDidChangeContent:)]) {
         [self.delegate queryControllerDidChangeContent:self];
    }
}

- (void)broadcastChange:(NSDictionary *)mockObjectChange
{
    id objectMock = [mockObjectChange valueForKey:LYRMockObjectChangeObjectKey];
    LYRObjectChangeType changeType = [[mockObjectChange valueForKey:LYRMockObjectChangeChangeTypeKey] integerValue];
    
    NSUInteger newIndex = [self.objects indexOfObject:objectMock];
    NSUInteger oldIndex = [self.oldObjects indexOfObject:objectMock];
    if ([self.delegate respondsToSelector:@selector(queryController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
        switch (changeType) {
            case LYRObjectChangeTypeCreate:
                if (newIndex == NSNotFound) break;
                [self.delegate queryController:self didChangeObject:objectMock atIndexPath:nil forChangeType:LYRQueryControllerChangeTypeInsert newIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
                break;
            case LYRObjectChangeTypeUpdate:
                [self.delegate queryController:self didChangeObject:objectMock atIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0] forChangeType:LYRQueryControllerChangeTypeUpdate newIndexPath:nil];
                break;
            case LYRObjectChangeTypeDelete:
                [self.delegate queryController:self didChangeObject:objectMock atIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:0] forChangeType:LYRQueryControllerChangeTypeDelete newIndexPath:nil];
                break;
            default:
                break;
        }
    }
}

- (void)setPaginationWindow:(NSInteger)paginationWindow
{
    _paginationWindow = paginationWindow;
}

- (void)setUpdatableProperties:(NSSet *)updatableProperties
{
    _updatableProperties = updatableProperties;
}

- (NSDictionary *)indexPathsForObjectsWithIdentifiers:(NSSet *)objectIdentifiers;
{
    NSUInteger maxIndex = [[LYRMockContentStore sharedStore] allMessages].count - 1;
    return [[NSDictionary alloc] initWithObjects:@[[NSIndexPath indexPathForRow:0 inSection:maxIndex]] forKeys:@[self.layerClient.authenticatedUserID]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
