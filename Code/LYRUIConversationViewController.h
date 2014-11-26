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
#import "LYRUIAddressBarViewController.h"

@class LYRUIConversationViewController;

///---------------------------------------
/// @name Delegate
///---------------------------------------

@protocol LYRUIConversationViewControllerDelegate <NSObject>

@optional
/**
 @abstract Informs the delegate that a user succesfully sent an `LYRMessage` object.
 @param conversationViewController The `LYRUIConversationViewController` in which the message was sent.
 @param message The `LYRMessage` object that was sent via Layer.
 */
- (void)conversationViewController:(LYRUIConversationViewController *)viewController didSendMessage:(LYRMessage *)message;

/**
 @abstract Informs the delegate that an `LYRMessage` object send attempt failed.
 @param conversationViewController The `LYRUIConversationViewController` in which the message failed to send.
 @param message The `LYRMessage` object which was attempted to be sent via Layer.
 @param error The `NSError` object describing why send failed.
 */
- (void)conversationViewController:(LYRUIConversationViewController *)viewController didFailSendingMessage:(LYRMessage *)message error:(NSError *)error;

/**
 @abstract Informs the delegate that an `LYRMessage` object was tapped
 @param conversationViewController The `LYRUIConversationViewController` in which the message failed to send.
 @param message The `LYRMessage` object which that was tapped.
 */
- (void)conversationViewController:(LYRUIConversationViewController *)viewController didSelectMessage:(LYRMessage *)message;

@end

///---------------------------------------
/// @name Data Source
///---------------------------------------

@protocol LYRUIConversationViewControllerDataSource <NSObject>

/**
 @abstract Asks the data source for an object conforming to the `LYRUIParticipant` protocol for a given identifier.
 @param conversationViewController The `LYRUIConversationViewController` requesting the object.
 @param participantIdentifer The participant identifier.
 @return an object conforming to the `LYRUIParticpant` protocol.
 */
- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier;

/**
 @abstract Asks the data source for an `NSAttributedString` representation of a given date.
 @param conversationViewController The `LYRUIConversationViewController` requesting the string.
 @param date The `NSDate` object to be displayed as a string.
 @retrun an `NSAttributedString` representing the given date.
 @discussion The date string will be displayed above message cells in section headers. The date represents the `sentAt` date of a message object. 
 The string can be customized to appear in whichever fromat your application requires.
 */
- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date;

/**
 @abstract Asks the data source for an `NSAttributedString` representation of a given `LYRRecipientStatus`.
 @param conversationViewController The `LYRUIConversationViewController` requesting the string.
 @param recipientStatus The `LYRRecipientStatus` object to be displayed as aquestion
 string.
 @return an `NSAttributedString` representing the give recipient status
 @discussion The recipient status string will be displayed below message the most recent message sent by the authenticated user. 
 */
- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus;

@optional

/**
 @abstract Asks the data source for an `NSString` object to be sent as the push notification alert text via Layer.
 @param conversationViewController The `LYRUIConversationViewController` requesting the string.
 @param message The `LYRMessage` object to be sent via Layer.
 @return a string representing the push notification text.
 @discussion If this method is not implemented, or it returns nil, Layer will deliver silent push notifications.
 */
- (NSString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController pushNotificationTextForMessageParts:(NSArray *)messageParts;

/**
 @abstract Asks the data source if the `LRYRecipientStatus` should be updated.
 @param conversationViewController The `LYRConversationViewController` requesting the string.
 @param message the `LYRMessage` object that requires evaluation
 @return a boolean value indicating if the recipient status should be updated
 @discussion If the method returns true, the controller will mark the message as read
 */
- (BOOL)conversationViewController:(LYRUIConversationViewController *)conversationViewController shouldUpdateRecipientStatusForMessage:(LYRMessage *)message;

@end

/**
 @abstract The `LYRUIConversationViewController` class presents an interface that provides for displaying 
 a Layer conversation and the ability to send messages. The controller's design and functionality closely correlates with
 the conversation view controller in iMessage.
*/
@interface LYRUIConversationViewController : UIViewController <LYRUIAddressBarControllerDelegate>

///---------------------------------------
/// @name Designated Initializer
///---------------------------------------

/**
 @abstract Creates and returns a new `LYRUIConversationViewController` initialized with a `LYRConversation` and `LYRClient` object.
 @param conversation The `LYRConversation` object whose messages are to be displayed in the controller.
 @param layerClient The `LYRClient` object from which to retrieve the messages for display.
 @return An `LYRConversationViewController` object.
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
/// @name Configuration
///---------------------------------------

/**
 @abstract The time interval at which message dates should be displayed in seconds. Default is 15 minutes meaning that
 dates will appear centered above a message only if the previous message was sent over 15 minutes ago.
 */
@property (nonatomic) NSTimeInterval dateDisplayTimeInterval;

///---------------------------------------
/// @name Public Accessors
///---------------------------------------

/**
 @abstract The `LYRClient` object used to initailize the controller
 */
@property (nonatomic) LYRClient *layerClient;

/**
 @abstract The `LYRConversation` object used to initailize the controller
 */
@property (nonatomic) LYRConversation *conversation;

/**
 @abstract The `LYRUIAddressBarViewController` displayed for addressing new conversations
 */
@property (nonatomic) LYRUIAddressBarViewController *addressBarController;

/**
 @abstract The `LYRUIMessageInputToolbar` displayed for user input
 */
@property (nonatomic) LYRUIMessageInputToolbar *messageInputToolbar;

/**
 @abstract Informs the receiver if it should display a `LYRUIAddressBarController`. If yes, your application must implement
 `LYRUIAddressBarControllerDelegate` and `LYRUIAddressBarControllerDataSource`. Default is no.
 */
@property (nonatomic) BOOL showsAddressBar;

/**
 @abstract If set, places the text in the navigation bar, otherwise UI will place the names of the participants
 */
@property (nonatomic) NSString *conversationTitle;

@end
