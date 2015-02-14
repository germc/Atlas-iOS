//
//  LYRUIConversationListViewController.h
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
#import "LYRUIConversationTableViewCell.h"
#import "LYRUIAvatarItem.h"

@class LYRUIConversationListViewController;

///---------------------------------------
/// @name Delegate
///---------------------------------------

@protocol LYRUIConversationListViewControllerDelegate <NSObject>

/**
 @abstract Informs the delegate that an `LYRConversation` was selected from the conversation list.
 @param conversationListViewController The `LYRConversationListViewController` in which the selection occurred.
 @param conversation The `LYRConversation` object that was selected.
 */
- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation;

@optional

/**
 @abstract Informs the delegate that an `LYRConversation` was deleted.
 @param conversationListViewController The `LYRConversationListViewController` in which the deletion occurred.
 @param conversation The `LYRConversation` object that was deleted.
 @param deletionMode The `LYRDeletionMode` with which the conversation was deleted.
 */
- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode;

/**
 @abstract Informs the delegate that an attempt to delete an `LYRConversation` failed.
 @param conversationListViewController The `LYRConversationListViewController` in which the deletion attempt occurred.
 @param conversation The `LYRConversation` object that failed deletion.
 @param deletionMode The `LYRDeletionMode` with which the conversation delete attempt was made.
 @param error An `NSError` object describing the deletion failure.
 */
- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didFailDeletingConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode error:(NSError *)error;

/**
 @abstract Informs the delegate that a search has been made with the following search string.
 @param conversationListViewController The controller in which the search was made.
 @param searchString The search string that was just used for search.
 @param completion The completion block that should be called when the results are fetched from the search. `filteredParticipants` shoud be an `NSSet` of participants whose `fullName` contains the search string.
 */
- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *filteredParticipants))completion;

@end

///---------------------------------------
/// @name Data Source
///---------------------------------------

@protocol LYRUIConversationListViewControllerDataSource <NSObject>

/**
 @abstract Asks the data source for a title string to display for a given conversation.
 @param conversationListViewController The `LYRConversationListViewController` in which the string will appear.
 @param conversation The `LYRConversation` object.
 @return The string to be displayed as the title for a given conversation in the conversation list.
 */
- (NSString *)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController titleForConversation:(LYRConversation *)conversation;

@optional

/**
 @abstract Asks the delegate for an avatar item representing a conversation.
 @param conversationListViewController The `LYRConversationListViewController` in which the item's data will appear.
 @param conversation The `LYRConversation` object.
 @return An object conforming to the `LYRUIAvatarItem` protocol. 
 @discussion The data provided by the object conforming to the `LYRUIAvatarItem` protocol will be displayed in an `LYRAvatarImageView`.
 */
- (id<LYRUIAvatarItem>)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController avatarItemForConversation:(LYRConversation *)conversation;

@end

/**
 @abstract The `LYRUIConversationListViewController` class presents an interface which provides
 for the display and selection of Layer conversations.
 */
@interface LYRUIConversationListViewController : UITableViewController

///---------------------------------------
/// @name Initializing a Controller
///---------------------------------------

/**
 @abstract Creates and returns a new conversation list initialized with a given `LYRClient` object.
 @param layerClient The `LYRClient` object from which conversations will be fetched for display.
 @return An `LYRConversationListViewController` object.
 */
+ (instancetype)conversationListViewControllerWithLayerClient:(LYRClient *)layerClient;

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
@property (nonatomic, weak) id<LYRUIConversationListViewControllerDelegate> delegate;

/**
 @abstract The object provides information to be displayed in the `LYRConversationListViewController`.
 */
@property (nonatomic, weak) id<LYRUIConversationListViewControllerDataSource> dataSource;

///----------------------------------------
/// @name Configuration
///----------------------------------------

/**
 @abstract The `UITableViewCell` subclass for customizing the display of the conversations.
 @discussion If you wish to provide your own custom class, your class must conform to the `LYRUIConversationPresenting` protocol.
 @default `LYRUIConversationTableViewCell`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) Class<LYRUIConversationPresenting> cellClass;


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
 @default `YES`
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

@end
