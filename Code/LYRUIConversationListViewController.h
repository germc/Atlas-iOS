//
//  LYRUIConversationListViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "LYRUIConversationTableViewCell.h"

@class LYRUIConversationListViewController;

@protocol LYRUIConversationListViewControllerDelegate <NSObject>

/**
 @abstract Tells the delegate that a conversation was selected from a conversation list.
 @param conversationListViewController The conversation list in which the selection occurred.
 @param conversation The conversation that was selected.
 */
- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation;

@end

@protocol LYRUIConversationListViewControllerDataSource <NSObject>

/**
 @abstract Asks the delegate for the Conversation Label for a given set of participants in a conversation.
 @param participants The identifiers for participants in a conversation within the conversation list.
 @param conversationListViewController The conversation list in which the participant appears.
 @return The conversation label to be displayed for a given conversation in the conversation list.
 */
- (NSString *)conversationLabelForParticipants:(NSSet *)participants inConversationListViewController:(LYRUIConversationListViewController *)conversationListViewController;

/**
 @abstract Informs the data source that a search has been made with the following search string. After the completion block is called, the `comversationListViewController:presenterForConversationAtIndex:` method will be called for each search result.  
 @param conversationListViewController An object representing the conversation list view controller.
 @param searchString The search string that was just used for search.
 @param completion The completion block that should be called when the results are fetched from the search.
 */
- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didSearchWithString:(NSString *)searchString completion:(void (^)())completion;

@end

/**
 @abstract The `LYRUIConversationListViewController` class presents an interface allowing
 for the display, selection, and searching of Layer conversations.
 */
@interface LYRUIConversationListViewController : UITableViewController

///---------------------------------------
/// @name Initializing a Conversation List
///---------------------------------------

/**
 @abstract Creates and returns a new conversation list initialized with the given Layer client.
 @param layerClient The Layer client from which to retrieve the conversations for display.
 @return A new conversation list controller.
 */
+ (instancetype)conversationListViewControllerWithLayerClient:(LYRClient *)layerClient;

/**
 @abstract The `LYRUIConversationViewControllerDelegate` class informs the reciever to specific events that occured within the controller.
 */
@property (nonatomic, weak) id<LYRUIConversationListViewControllerDelegate> delegate;

/**
 @abstract The `LYRUIConversationListViewControllerDataSource` class presents an interface allowing
 for the display of information pertaining to specific converations in the view controller
 */
@property (nonatomic, weak) id<LYRUIConversationListViewControllerDataSource> dataSource;

///----------------------------------------
/// @name Customizing the Conversation List
///----------------------------------------

/**
 @abstract A Boolean value that determines if editing is enabled.
 @discussion When `YES`, an Edit button item will be displayed on the left hand side of the
 receiver's navigation item that toggles the editing state of the receiver.
 @default `YES`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) BOOL allowsEditing;

/**
 @abstract The table view cell class for customizing the display of the conversations.
 @default `[LYRUIConversationTableViewCell class]`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) Class<LYRUIConversationPresenting> cellClass;

/**
 @abstract Sets the height for cells within the receiver.
 @default `80.0`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) CGFloat rowHeight;

/**
 @abstract Tells the receiver if is should display an image representing a conversation
 @discussion Typically, this image will be an avatar image representing the user;
 @default TRUE
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) BOOL showsConversationImage;


@property (nonatomic) LYRClient *layerClient;

@end
