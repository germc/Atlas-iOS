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

@interface LYRUIConversationDataSource : NSObject

+ (instancetype)initWithLayerClient:(LYRClient *)layerClient conversation:(LYRConversation *)conversation;

@property (nonatomic) LYRQueryController *queryController;


- (void)configurePaginationWindow;

- (BOOL)moreMessagesAvailable;

- (NSIndexPath *)queryControllerIndexPathForCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath;

- (NSIndexPath *)collectionViewIndexPathForQueryControllerIndexPath:(NSIndexPath *)collectionViewIndexPath;

- (NSInteger)collectionViewSectionForQueryControllerRow:(NSInteger)queryControllerRow;

- (LYRMessage *)messageAtCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath;

- (LYRMessage *)messageAtCollectionViewSection:(NSInteger)collectionViewSection;

@end
