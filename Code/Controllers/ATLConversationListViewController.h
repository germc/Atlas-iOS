//
//  ATLUIConversationListViewController.h
//  Atlas
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
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
#import "ATLConversationTableViewCell.h"
#import "ATLAvatarItem.h"

@class ATLConversationListViewController;

///---------------------------------------
/// @name Delegate
///---------------------------------------

@protocol ATLConversationListViewControllerDelegate <NSObject>

/**
 @abstract Informs the delegate that an `LYRConversation` was selected from the conversation list.
 @param conversationListViewController The `LYRConversationListViewController` in which the selection occurred.
 @param conversation The `LYRConversation` object that was selected.
 */
- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation;

@optional

/**
 @abstract Informs the delegate that an `LYRConversation` was deleted.
 @param conversationListViewController The `LYRConversationListViewController` in which the deletion occurred.
 @param conversation The `LYRConversation` object that was deleted.
 @param deletionMode The `LYRDeletionMode` with which the conversation was deleted.
 */
- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode;

/**
 @abstract Informs the delegate that an attempt to delete an `LYRConversation` failed.
 @param conversationListViewController The `LYRConversationListViewController` in which the deletion attempt occurred.
 @param conversation The `LYRConversation` object that failed deletion.
 @param deletionMode The `LYRDeletionMode` with which the conversation delete attempt was made.
 @param error An `NSError` object describing the deletion failure.
 */
- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didFailDeletingConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode error:(NSError *)error;

/**
 @abstract Informs the delegate that a search has been made with the given search string.
 @param conversationListViewController The controller in which the search was performed.
 @param searchText The search text that was used for search.
 @param completion The block has has no return value and accepts a single argument: an NSSet of objects conforming to the ATLParticipant protocol that were found to match the search text.
 */
- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSearchForText:(NSString *)searchText completion:(void (^)(NSSet *filteredParticipants))completion;

@end

///---------------------------------------
/// @name Data Source
///---------------------------------------

@protocol ATLConversationListViewControllerDataSource <NSObject>

/**
 @abstract Asks the data source for a title string to display for a given conversation.
 @param conversationListViewController The `LYRConversationListViewController` in which the string will appear.
 @param conversation The `LYRConversation` object.
 @return The string to be displayed as the title for a given conversation in the conversation list.
 */
- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController titleForConversation:(LYRConversation *)conversation;

@optional

/**
 @abstract Asks the delegate for an avatar item representing a conversation.
 @param conversationListViewController The `LYRConversationListViewController` in which the item's data will appear.
 @param conversation The `LYRConversation` object.
 @return An object conforming to the `ATLAvatarItem` protocol. 
 @discussion The data provided by the object conforming to the `ATLAvatarItem` protocol will be displayed in an `LYRAvatarImageView`.
 */
- (id<ATLAvatarItem>)conversationListViewController:(ATLConversationListViewController *)conversationListViewController avatarItemForConversation:(LYRConversation *)conversation;

/**
 @abstract Asks the data source for the table view cell reuse identifier for a conversation.
 @param conversationListViewController The `ATLConversationListViewController` requesting the string.
 @return A string that will be used to dequeue a cell from the table view.
 @discussion Applications that wish to use prototype cells from a UIStoryboard in the ATLConversationListViewController cannot register their cells programmatically.
 The cell must be given a reuse identifier in the UIStoryboard and that string needs to be passed into the ATLConversationListViewController so it can properly dequeue a
 reuseable cell. If 'nil' is returned, the table view will default to internal values for reuse identifiers.
 */
- (NSString *)reuseIdentifierForConversationListViewController:(ATLConversationListViewController *)conversationListViewController;

/**
 @abstract Asks the data source for a string to display on the delete button for a given deletion mode.
 @param conversationListViewController The `LYRConversationListViewController` in which the button title will appear.
 @param deletionMode The `LYRDeletionMode` for which a button has to be displayed.
 @return The string to be displayed on the delete button for a given deletion mode in the conversation list.
 */
- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController textForButtonWithDeletionMode:(LYRDeletionMode)deletionMode;

/**
 @abstract Asks the data source for a color to apply to the delete button for a given deletion mode.
 @param conversationListViewController The `LYRConversationListViewController` in which the button title will appear.
 @param deletionMode The `LYRDeletionMode` for which a button has to be displayed.
 @return The color to apply on the delete button for a given deletion mode in the conversation list.
 */
- (UIColor *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController colorForButtonWithDeletionMode:(LYRDeletionMode)deletionMode;

/**
 @abstract Asks the data source for the string to display as the conversation's last sent message.
 @params conversation The conversation for which the last message text should be returned.
 @return A string representing the content of the last message.  If `nil` is returned the controller will fall back to default behavior.
 @discussion This is used when the application uses custom `MIMEType`s and wants to customize how they are displayed.
 */
- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController lastMessageTextForConversation:(LYRConversation *)conversation;

/**
 @abstract Asks the data source to configure the query used to fetch content for the controller if necessary.
 @discussion The `LYRConversationListViewController` uses the following default query:
 
     LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
     query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsIn value:self.layerClient.authenticatedUserID];
     query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.receivedAt" ascending:NO]];
 
 Applications that require advanced query configuration can do so by implementing this data source method.
 
 @param viewController The `ATLConversationViewController` requesting the configuration.
 @param defaultQuery An `LYRQuery` object with the default configuration for the controller.
 @return An `LYRQuery` object with any additional configuration.
@raises `NSInvalidArgumentException` if an `LYRQuery` object is not returned.
 */
- (LYRQuery *)conversationListViewController:(ATLConversationListViewController *)viewController willLoadWithQuery:(LYRQuery *)defaultQuery;

@end

/**
 @abstract The `ATLConversationListViewController` class presents an interface which provides
 for the display and selection of Layer conversations.
 */
@interface ATLConversationListViewController : UITableViewController

///-------------------------------------------------------
/// @name Initializing a Conversation List View Controller
///-------------------------------------------------------

/**
 @abstract Creates and returns a new conversation list initialized with a given `LYRClient` object.
 @param layerClient The `LYRClient` object from which conversations will be fetched for display.
 @return An `LYRConversationListViewController` object.
 */
+ (instancetype)conversationListViewControllerWithLayerClient:(LYRClient *)layerClient;

/**
 @abstract Initializes a new `ATLConversationListViewController` object with the given `LYRClient` object.
 @param layerClient The `LYRClient` object from which conversations will be fetched for display.
 @return An `LYRConversationListViewController` object initialized with the given `LYRClient` object.
 */
- (instancetype)initWithLayerClient:(LYRClient *)layerClient;

///-------------------------------------------------------
/// @name Configuring Layer Client, Delegate & Data Source
///-------------------------------------------------------

/**
 @abstract The `LYRClient` object used to initialize the controller. 
 @discussion If using storyboards, the property must be set explicitly.
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) LYRClient *layerClient;

/**
 @abstract The object that is informed when specific events occur
 within the `LYRConversationListViewController`.
 */
@property (nonatomic, weak) id<ATLConversationListViewControllerDelegate> delegate;

/**
 @abstract The object provides information to be displayed in the `LYRConversationListViewController`.
 */
@property (nonatomic, weak) id<ATLConversationListViewControllerDataSource> dataSource;

///----------------------------------------
/// @name Configuring the Conversation List
///----------------------------------------

/**
 @abstract The `UITableViewCell` subclass for customizing the display of the conversations.
 @discussion If you wish to provide your own custom class, your class must conform to the `ATLConversationPresenting` protocol.
 @default `ATLConversationTableViewCell`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) Class<ATLConversationPresenting> cellClass;


/**
 @abstract Informs the receiver of the deletion modes that it should support.
 @discussion See `LYRDeletionMode` in `LayerKit`. `LYRDeletionMode` must be wrapped as an `NSNumber` object prior to insertion in an array.
 @default `LYRDeletionModeLocal` and `LYRDeletionModeAllParticipants.
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) NSArray *deletionModes;

/**
 @abstract Informs the receiver if it should display an avatar item representing a conversation.
 @discussion When `YES`, an avatar item will be displayed for every conversation cell.
 Typically, this image will be an avatar image representing the user or group of users.
 @default `NO`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) BOOL displaysAvatarItem;

/**
 @abstract A boolean value that determines if editing is enabled.
 @discussion When `YES`, an Edit button item will be displayed on the left hand side of the receiver's navigation 
 item which toggles the editing state of the receiver and swiping to delete cells will be enabled.
 @default `YES`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) BOOL allowsEditing;

/**
 @abstract Sets the height for cells within the receiver.
 @default `76.0`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) CGFloat rowHeight;

///-------------
/// @name Search
///-------------

/**
 @abstract The controller used to display search results.
 */
@property (nonatomic, readonly) UISearchDisplayController *searchController;


///------------------------------
/// @name Reloading Conversations
///------------------------------

/**
 @abstract Reloads the cell for the given Conversation.
 @param conversation The Conversation object to reload the corresponding cell of. Cannot be `nil`.
 */
- (void)reloadCellForConversation:(LYRConversation *)conversation;

@end
