//
//  LYRUIAddressBarController.h
//  
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import <UIKit/UIKit.h>
#import "LYRUIAddressBarView.h"
#import "LYRUIParticipant.h"

@class LYRUIAddressBarViewController;

///---------------------------------------
/// @name Delegate
///---------------------------------------

@protocol LYRUIAddressBarControllerDelegate <NSObject>

@optional
/**
 @abstract Informs the delegate that a user began searching by typing in the `LYRAddressBarTextView`.
 @param addressBarViewController The `LYRUIAddressBarViewController` presenting the `LYRUIAddressBarTextView`.
 */
- (void)addressBarViewControllerDidBeginSearching:(LYRUIAddressBarViewController *)addressBarViewController;

/**
 @abstract Informs the delegate that the user made a participant selection.
 @param addressBarViewController The `LYRUIAddressBarViewController` in which the selection occurred.
 @param participant The participant who was selected and added to the address bar.
 @discussion Upon selection, the participant's full name will be appended to any existing text in the `LYRUIAddressBarTextView`.
 The set of participants represents the identifiers for all currently displayed participants.
 */
- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController didSelectParticipant:(id<LYRUIParticipant>)participant;

/**
 @abstract Informs the delegate that the user removed a participant from the address bar.
 @param addressBarViewController The `LYRUIAddressBarViewController` in which the removal occurred.
 @param participant The participant who was removed.
 */
- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController didRemoveParticipant:(id<LYRUIParticipant>)participant;

/**
 @abstract Informs the delegate that the user finished searching.
 @param addressBarViewController The `LYRUIAddressBarViewController` in which the search occurred.
 @discussion Searching ends when the user either selects a participant or removes all participants from the `LYRUIAddressBarTextView`.
 */
- (void)addressBarViewControllerDidEndSearching:(LYRUIAddressBarViewController *)addressBarViewController;

/**
 @abstract Informs the delegate that the user tapped on the `addContactsButton`.
 @param addressBarViewController The `LYRUIAddressBarViewController` in which the tap occurred.
 @param addContactsButton The button that was tapped.
 */
- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton;

@end

///---------------------------------------
/// @name Data Source
///---------------------------------------

@protocol LYRUIAddressBarControllerDataSource <NSObject>

@optional

/**
 @abstract Asks the data source for an NSSet of participants given a search string.
 @param searchText The text upon which a participant search should be performed.
 @param completion The completion block to be called upon search completion.
 @discussion Search should be performed across each `LYRUIParticipant` object's fullName property.
 */
- (void)searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSSet *participants))completion;

@end

/**
 @abstract The `LYRUIAddressBarViewController` class presents an interface that provides for displaying an address bar
 in an `LYRUIConversationViewController`.
 @discussion The class handles displaying the address bar in addition to a table view of participants in response to user search input.
 When a participant is selected, the class appends that participant's full name to any existing text currently displayed. It also creates
 `LYRUIAddressToken` objects which allow for the entire participant name to be highlighted in response to a tap. The bar's design and
 functionality closely correlates with the design and functionality of the address bar in iMessage.
 */
@interface LYRUIAddressBarViewController : UIViewController

/**
 @abstract The `LYRUIAddressBarControllerDelegate` class informs the receiver of specific events that occurred within the controller.
 */
@property (nonatomic, weak) id<LYRUIAddressBarControllerDelegate> delegate;

/**
 @abstract The `LYRUIAddressBarControllerDataSource` class requests information from the receiver to be displayed in the controller.
 */
@property (nonatomic, weak) id<LYRUIAddressBarControllerDataSource> dataSource;

/**
 @abstract The `LYRUIAddressBarView` displays the `LYRUIAddressBarTextView` in which the actual text input occurs. It also displays
 a UIButton object represented by the `addContactButton` property.
 */
@property (nonatomic) LYRUIAddressBarView *addressBarView;

/**
 @abstract The `NSSet` of currently selected participants.
 */
@property (nonatomic, readonly) NSSet *selectedParticipants;

/**
 @abstract Informs the receiver that a selection occurred outside of the controller and a participant should be added to the address
 bar.
 */
- (void)selectParticipant:(id<LYRUIParticipant>)participant;

/**
 @abstract Informs the receiver to enter a permanent state. When this method is called, user input and search will be disallowed.
 */
- (void)setPermanent;

@end
