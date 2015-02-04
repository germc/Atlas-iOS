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
 @abstract The `LYRUIConversationDataSource` manages an `LYRQueryController` whose messaging data is displayed
 in a `LYRUICollectionView`. The `LYRUIConversationDataSource` also manages the transalation of `NSIndexPath` objects
 between the `LYRQueryController` and the and `LYRUICollectionView`.
 @discussion The `LYRUIConversationViewController` reserves the section at index 0 for a "Loading Messages" indicator if
 one is needed during pagination. The index path transaltion methods supplied by the `LYRUIConversationDataSource` are convenince methods which
 account for this offset.
 */
@interface LYRUIConversationDataSource : NSObject

///---------------------------------------
/// @name Designated Initializer
///---------------------------------------

/**
 @abstract Creates and returns an `LYRUIConversationDataSource` object.
 @param layerClient The `LYRClient` object needed to initialize and `LYRQueryController`.
 @return An `LYRConversation` object who's messages will ther fetched in `LYRQueryController`.
 */
+ (instancetype)initWithLayerClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation;

/*
 @abstract The `LYRQueryController` object used to fetch and display messages. 
 @disucssion The `queryController` is hydrated with messages belonging to the `LYRConversation` object
 supplied in the designated initializer.
 */
@property (nonatomic) LYRQueryController *queryController;

///---------------------------------------
/// @name Pagination
///---------------------------------------

@property (nonatomic, readonly) NSInteger paginationWindow;

/*
 @abstracts Asks the controller if its' `queryController` has more message than currently displayed on screen.
 @return `YES` is there are more messages to display.
 */
- (BOOL)moreMessagesAvailable;

/*
 @abstract Increments the pagination window by the constant value `LYRUIQueryControllerPaginationWindow` if
 more messages are available for display.
 */
- (void)configurePaginationWindow;

///---------------------------------------
/// @name IndexPath Transalation Methods
///---------------------------------------

/*
 @abstract Converts an `LYRUIConversationViewController` index path into a `LYRQueryController` index path.
 */
- (NSIndexPath *)queryControllerIndexPathForCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath;

/*
 @abstract Converts a `LYRQueryController` index path into a `LYRUIConversationViewController` index path.
 */
- (NSIndexPath *)collectionViewIndexPathForQueryControllerIndexPath:(NSIndexPath *)collectionViewIndexPath;

/*
 @abstract Conversats a `LYRQueryController` row into a `LYQUIConversationViewController` section.
 @discussion The `LYRUIConversationViewController` displays one `LYRMessage` object for each section.
 */
- (NSInteger)collectionViewSectionForQueryControllerRow:(NSInteger)queryControllerRow;

/*
 @abstract Fetches the `LYRMessage` object cooreseponding an `LYRUIConversationViewController` index path.
 */
- (LYRMessage *)messageAtCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath;

/*
 @abstract Fetches the `LYRMessage` object cooreseponding an `LYRUIConversationViewController` section.
 */
- (LYRMessage *)messageAtCollectionViewSection:(NSInteger)collectionViewSection;

@end
