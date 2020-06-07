//
//  ATLQueryControllerMock.h
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
@property (nonatomic) NSSet *updatableProperties;
@property (nonatomic) NSInteger paginationWindow;
@property (nonatomic, readonly) NSUInteger totalNumberOfObjects;

+ (instancetype)initWithQuery:(LYRQuery *)query;

- (NSUInteger)numberOfSections;

- (NSUInteger)numberOfObjectsInSection:(NSUInteger)section;

- (NSUInteger)count;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForObject:(id<LYRQueryable>)object;

- (BOOL)execute:(NSError **)error;

- (NSDictionary *)indexPathsForObjectsWithIdentifiers:(NSSet *)objectIdentifiers;

@end


