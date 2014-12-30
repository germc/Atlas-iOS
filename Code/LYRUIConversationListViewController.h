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

- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode;

- (void)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController didFailDeletingConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode error:(NSError *)error;

@end

///---------------------------------------
/// @name Data Source
///---------------------------------------

@protocol LYRUIConversationListViewControllerDataSource <NSObject>

/**
 @abstract Asks the data source for a string to display for a given conversation.
 @param conversationListViewController The `LYRConversationListViewController` in which the string will appear.
 @param conversation The `LYRConversation` object.
 @return The string to be displayed for a given conversation in the conversation list.
 */
- (NSString *)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController labelForConversation:(LYRConversation *)conversation;

@optional

/**
 @abstract Asks the delegate for an image to display for a given conversation.
 @param conversationListViewController The `LYRConversationListViewController` in which the image will appear.
 @param conversation The `LYRConversation` object.
 @return The conversation image to be displayed for a given conversation in the conversation list.
 */
- (UIImage *)conversationListViewController:(LYRUIConversationListViewController *)conversationListViewController imageForConversation:(LYRConversation *)conversation;

@end

/**
 @abstract The `LYRUIConversationListViewController` class presents an interface which provides
 for the display and selection of Layer conversations.
 */
@interface LYRUIConversationListViewController : UITableViewController

///---------------------------------------
/// @name Designated Initializer
///---------------------------------------

/**
 @abstract Creates and returns a new conversation list initialized with a given `LYRClient` object.
 @param layerClient The `LYRClient` object from which conversations will be fetched for display.
 @return An `LYRConversationListViewController` object.
 */
+ (instancetype)conversationListViewControllerWithLayerClient:(LYRClient *)layerClient;

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

@property (nonatomic) LYRQueryController *queryController;

/**
 @abstract The `UITableViewCell` subclass for customizing the display of the conversations.
 @discussion If you wish to provide your own custom class, your class must conform to the `LYRUIConversationPresenting` protocol.
 @default `LYRUIConversationTableViewCell`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) Class<LYRUIConversationPresenting> cellClass;

/**
 @abstract Informs the receiver if it should display an image representing a conversation.
 @discussion When `YES`, an image will be displayed for every conversation cell.
 Typically this image will be an avatar image representing the user or group of users.
 @default `YES`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) BOOL displaysConversationImage;

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
 @default `72.0`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) CGFloat rowHeight;

///---------------------------------------
/// @name Public Accessors
///---------------------------------------

/**
 @abstract The `LYRClient` object used to initialize the controller.
 */
@property (nonatomic, readonly) LYRClient *layerClient;

@end
