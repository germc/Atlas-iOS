//
//  LYRConversationQueryController.h
//  Pods
//
//  Created by Kevin Coleman on 2/4/15.
//
//

#import <UIKit/UIKit.h> 
#import <LayerKit/LayerKit.h>

NSInteger const LYRUINumberOfSectionsBeforeFirstMessageSection;
NSInteger const LYRUIQueryControllerPaginationWindow;

/**
 @abstract The `LYRUIConversationDataSource` manages an `LYRQueryController` object whose data is displayed in an
 `LYRUIConversationViewController`. The `LYRUIConversationDataSource` also provides convenince methods for the transalation 
 of index objects between an `LYRQueryController` and an `LYRUIConversationViewController`.
 @discussion The `LYRUIConversationViewController` reserves the section at index 0 for a "Loading Messages" indicator if
 one is needed during pagination. The index translation methods provided by the `LYRUIConversationDataSource` account for
 this offset.
 */
@interface LYRUIConversationDataSource : NSObject

///---------------------------------------
/// @name Designated Initializer
///---------------------------------------

/**
 @abstract Creates and returns an `LYRUIConversationDataSource` object.
 @param layerClient An `LYRClient` object used to initialize the `queryController` property.
 @param conversation An `LYRConversation` object used in the predicate of the `queryController` property's `LYRQuery`.
 @return An `LYRUIConversationDataSource` object.
 */
+ (instancetype)initWithLayerClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation;

/*
 @abstract The `LYRQueryController` object managing data displayed in the `LYRUIConversationViewController`.
 @disucssion The `queryController` is hydrated with messages belonging to the `LYRConversation` object
 supplied in the designated initializer.
 */
@property (nonatomic) LYRQueryController *queryController;

///---------------------------------------
/// @name Pagination
///---------------------------------------

/*
 @abstract The pagination window used by the `LYRQueryController` property. Set to 30.
 */
@property (nonatomic, readonly) NSInteger paginationWindow;

/*
 @abstracts Asks the receiver if its `queryController` has more messages to display than are currently displayed on screen.
 @return `YES` if there are more messages to display.
 */
- (BOOL)moreMessagesAvailable;

/*
 @abstract Increments the pagination window of the `queryController` by the `parginationWindow` property if
 more messages are available for display.
 */
- (void)incrementPaginationWindow;

///---------------------------------------
/// @name Index Transalation Methods
///---------------------------------------

/*
 @abstract Converts an `LYRUIConversationViewController` index path into an `LYRQueryController` index path.
 */
- (NSIndexPath *)queryControllerIndexPathForCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath;

/*
 @abstract Converts an `LYRQueryController` index path into an `LYRUIConversationViewController` index path.
 */
- (NSIndexPath *)collectionViewIndexPathForQueryControllerIndexPath:(NSIndexPath *)collectionViewIndexPath;

/*
 @abstract Converts an `LYRQueryController` row into an `LYRUIConversationViewController` section.
 @discussion The `LYRUIConversationViewController` displays one `LYRMessage` object for each section.
 */
- (NSInteger)collectionViewSectionForQueryControllerRow:(NSInteger)queryControllerRow;

/*
 @abstract Fetches the `LYRMessage` object corresponding to an `LYRUIConversationViewController` index path.
 */
- (LYRMessage *)messageAtCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath;

/*
 @abstract Fetches the `LYRMessage` object corresponding to an `LYRUIConversationViewController` section.
 */
- (LYRMessage *)messageAtCollectionViewSection:(NSInteger)collectionViewSection;

@end
