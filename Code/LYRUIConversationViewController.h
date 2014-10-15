//
//  LYRUIConversationViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import <MapKit/MapKit.h>
#import "LYRUIParticipant.h"
#import "LYRUIMessageInputToolbar.h"


@class LYRUIConversationViewController;

@protocol LYRUIConversationViewControllerDelegate <NSObject>

@optional
/**
 @abstract Informs the delegate that a user sent the given message
 @param conversationViewController The conversation view controller in which the selection occurred.
 @param message The message object that was sent via Layer.
 */
- (void)conversationViewController:(LYRUIConversationViewController *)viewController didSendMessage:(LYRMessage *)message;

/**
 @abstract Informs the delegate that a message send attempt failed
 @param conversationViewController The conversation view controller in which the selection occurred.
 @param message The error object describing why send failed
 */
- (void)conversationViewController:(LYRUIConversationViewController *)viewController didFailSendingMessageWithError:(NSError *)error;

@end

@protocol LYRUIConversationViewControllerDataSource <NSObject>

@required
/**
 @abstract Asks the data source for an object conforming to the `LYRUIParticipant` protocol for a given identifier
 @param conversationListViewController The conversation view controller requesting the object
 @param conversation The participant identifier
 @return an object conforming to the LYRUIParticpant protocol
 @discussion the returned object will be used to display names in the controller. If there is only one other participant aside from the 
 currently authenticated user, the controller will display the objects `firstName` as the controller title. If there is more that one 
 other participant aside from the currenlty authenticated user, names will be displayed above groups of incoming message cells coming from the 
 same particpant
 */
- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier;

/**
 @abstract Asks the data source for a string representation of a given date
 @param conversationListViewController The conversation view controller requesting the string
 @param conversation The `NSDate` object to be displayed as a string
 @retrun a string representing the given date
 @discussion The date string will be displayed above message cells in section headers. The date represents the `sentAt` date of a message object
 */
- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date;

/**
 @abstract Asks the data source for a string representation of a given `LYRRecipientStatus`
 @param conversationListViewController The conversation view controller requesting the string
 @param conversation The `LYRRecipientStatus` object to be displayed as a string
 @return a string representing the recipient status
 @discussion The date string will be displayed above message cells in section headers. The date represents the `sentAt` date of a message object
 */
- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus;

/**
 @abstract Asks the data source for a to be sent as the push notification alert via Layer
 @param conversationListViewController The conversation view controller requesting the string
 @param message The message object to be sent by the Layer SDK
 @return a string representing the push notification text
 */
- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController pushNotificationTextForMessage:(LYRMessage *)message;

@optional
/**
 @abstract Asks the data source if the LRYRecipientStatus should be updated
 @param conversationListViewController The conversation view controller requesting the string
 @param conversation the LYRMessage object that requires evaluation
 @return a boolean value indicating if the recipient status should be updated
 @discussion As LayerKit only allows for setting messages as read, if the method returns true, the controller will mark the message as read
 */
- (BOOL)conversationViewController:(LYRUIConversationViewController *)conversationViewController shouldUpdateRecipientStatusForMessage:(LYRMessage *)message;

@end

/**
@abstract The `LYRUIConversationViewController` class displays a Layer conversation and provides ability to send messages.
*/
@interface LYRUIConversationViewController : UIViewController

///---------------------------------------
/// @name Initializing a Conversation View
///---------------------------------------

/**
 @abstract Creates and returns a new conversation view controller initialized with the given conversation and Layer client.
 @param conversation The conversation object whose messages are to be displayed in the conversation view controller
 @param layerClient The Layer client from which to retrieve the conversations for display.
 @return A new conversation view controller.
 */
+ (instancetype)conversationViewControllerWithConversation:(LYRConversation *)conversation layerClient:(LYRClient *)layerClient;

/**
 @abstract The `LYRUIConversationViewControllerDelegate` class informs the reciever to specific events that occured within the controller.
 */
@property (nonatomic, weak) id<LYRUIConversationViewControllerDelegate> delegate;

/**
 @abstract The `LYRUIConversationViewControllerDataSource` class presents an interface allowing
 for the display of information pertaining to specific messages in the conversation view controller
 */
@property (nonatomic, weak) id<LYRUIConversationViewControllerDataSource> dataSource;

///---------------------------------------
/// @name Customizing a Conversation View
///---------------------------------------

/**
 @abstract The time interval at which message dates should be displayed in seconds. Default is 60 minutes meaning that
 dates will appear centered above a message only if the previous message was sent over 60 minutes ago.
 */
@property (nonatomic) NSTimeInterval dateDisplayTimeInterval;

/**
 @abstract Boolean value to determine whether or not the conversation view controller permits editing
 */
@property (nonatomic, assign) BOOL allowsEditing;

/**
 @abstract The given `LYRClient` object
 */
@property (nonatomic) LYRClient *layerClient;

/**
 @abstract The given `LYRConversation` object
 */
@property (nonatomic) LYRConversation *conversation;

@end
