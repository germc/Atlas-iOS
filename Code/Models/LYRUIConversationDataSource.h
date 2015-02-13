//
//  LYRConversationQueryDataSource.h
//  Atlas
//
//  Created by Kevin Coleman on 2/4/15.
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

#import <UIKit/UIKit.h> 
#import <LayerKit/LayerKit.h>

extern NSInteger const LYRUINumberOfSectionsBeforeFirstMessageSection;

/**
 @abstract The `LYRUIConversationDataSource` manages an `LYRQueryController` object whose data is displayed in an
 `LYRUIConversationViewController`. The `LYRUIConversationDataSource` also provides convenience methods for the transalation 
 of index objects between an `LYRQueryController` and an `LYRUIConversationViewController`.
 @discussion The `LYRUIConversationViewController` reserves the section at index 0 for a "Loading Messages" indicator if
 one is needed during pagination. The index translation methods provided by the `LYRUIConversationDataSource` account for
 this offset.
 */
@interface LYRUIConversationDataSource : NSObject

///---------------------------------------
/// @name Initializing a Data Source
///---------------------------------------

/**
 @abstract Creates and returns an `LYRUIConversationDataSource` object.
 @param layerClient An `LYRClient` object used to initialize the `queryController` property.
 @param conversation An `LYRConversation` object used in the predicate of the `queryController` property's `LYRQuery`.
 @return An `LYRUIConversationDataSource` object.
 */
+ (instancetype)dataSourceWithLayerClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation;

/**
 @abstract The `LYRQueryController` object managing data displayed in the `LYRUIConversationViewController`.
 @discussion The `queryController` is hydrated with messages belonging to the `LYRConversation` object
 supplied in the designated initializer.
 */
@property (nonatomic, readonly) LYRQueryController *queryController;

///---------------------------------------
/// @name Pagination
///---------------------------------------

/**
 @abstract Asks the receiver if its `queryController` has more messages to display than are currently displayed on screen.
 @return `YES` if there are more messages to display.
 */
- (BOOL)moreMessagesAvailable;

/**
 @abstract Expands the pagination window of the `queryController` by the `paginationWindow` property if
 more messages are available for display.
 */
- (void)expandPaginationWindow;

/**
 @abstract Returns `YES` if the data source is currently in the process of expanding its pagination window.
 */
@property (nonatomic, readonly, getter=isExpandingPaginationWindow) BOOL expandingPaginationWindow;

///---------------------------------------
/// @name Index Translation Methods
///---------------------------------------

/**
 @abstract Converts an `LYRUIConversationViewController` index path into an `LYRQueryController` index path.
 */
- (NSIndexPath *)queryControllerIndexPathForCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath;

/**
 @abstract Converts an `LYRQueryController` index path into an `LYRUIConversationViewController` index path.
 */
- (NSIndexPath *)collectionViewIndexPathForQueryControllerIndexPath:(NSIndexPath *)collectionViewIndexPath;

/**
 @abstract Converts an `LYRQueryController` row into an `LYRUIConversationViewController` section.
 @discussion The `LYRUIConversationViewController` displays one `LYRMessage` object for each section.
 */
- (NSInteger)collectionViewSectionForQueryControllerRow:(NSInteger)queryControllerRow;

/**
 @abstract Fetches the `LYRMessage` object corresponding to an `LYRUIConversationViewController` index path.
 */
- (LYRMessage *)messageAtCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath;

/**
 @abstract Fetches the `LYRMessage` object corresponding to an `LYRUIConversationViewController` section.
 */
- (LYRMessage *)messageAtCollectionViewSection:(NSInteger)collectionViewSection;

@end
