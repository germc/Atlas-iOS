//
//  ATLUIAddressBarController.h
//  Atlas
//
//  Created by Kevin Coleman on 10/27/14.
//  Copyright (c) 2015 Layer. All rights reserved.
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
#import "ATLAddressBarView.h"
#import "ATLParticipant.h"

@class ATLAddressBarViewController;

///---------------------------------------
/// @name Delegate
///---------------------------------------

@protocol ATLAddressBarViewControllerDelegate <NSObject>

@optional
/**
 @abstract Informs the delegate that a user began searching by typing in the `LYRAddressBarTextView`.
 @param addressBarViewController The `ATLAddressBarViewController` presenting the `ATLAddressBarTextView`.
 */
- (void)addressBarViewControllerDidBeginSearching:(ATLAddressBarViewController *)addressBarViewController;

/**
 @abstract Informs the delegate that the user made a participant selection.
 @param addressBarViewController The `ATLAddressBarViewController` in which the selection occurred.
 @param participant The participant who was selected and added to the address bar.
 @discussion Upon selection, the participant's full name will be appended to any existing text in the `ATLAddressBarTextView`.
 The set of participants represents the identifiers for all currently displayed participants.
 */
- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didSelectParticipant:(id<ATLParticipant>)participant;

/**
 @abstract Informs the delegate that the user removed a participant from the address bar.
 @param addressBarViewController The `ATLAddressBarViewController` in which the removal occurred.
 @param participant The participant who was removed.
 */
- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didRemoveParticipant:(id<ATLParticipant>)participant;

/**
 @abstract Informs the delegate that the user finished searching.
 @param addressBarViewController The `ATLAddressBarViewController` in which the search occurred.
 @discussion Searching ends when the user either selects a participant or removes all participants from the `ATLAddressBarTextView`.
 */
- (void)addressBarViewControllerDidEndSearching:(ATLAddressBarViewController *)addressBarViewController;

/**
 @abstract Informs the delegate that the user tapped on the `addContactsButton`.
 @param addressBarViewController The `ATLAddressBarViewController` in which the tap occurred.
 @param addContactsButton The button that was tapped.
 */
- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton;

/**
 @abstract Informs the delegate that the user tapped on the controller while in a disabled state.
 @param addressBarViewController The `ATLAddressBarViewController` in which the tap occurred.
 */
- (void)addressBarViewControllerDidSelectWhileDisabled:(ATLAddressBarViewController *)addressBarViewController;

/**
 @abstract Asks the data source for an NSSet of participants given a search string.
 @param addressBarViewController The `ATLAddressBarViewController` in which the tap occurred.
 @param searchText The text upon which a participant search should be performed.
 @param completion The completion block to be called upon search completion.
 @discussion Search should be performed across each `ATLParticipant` object's fullName property.
 */
- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSArray *participants))completion;

@end

/**
 @abstract The `ATLAddressBarViewController` class presents an interface that provides for displaying an address bar
 in an `ATLConversationViewController`.
 @discussion The class handles displaying the address bar in addition to a table view of participants in response to user search input.
 When a participant is selected, the class appends that participant's full name to any existing text currently displayed. It also allows
 for the entire participant name to be highlighted in response to a tap. The bar's design and functionality closely correlates with the
 design and functionality of the address bar in Messages.
 */
@interface ATLAddressBarViewController : UIViewController

/**
 @abstract The object to be informed of specific events that occur within the controller.
 */
@property (nonatomic, weak) id<ATLAddressBarViewControllerDelegate> delegate;

/**
 @abstract The `ATLAddressBarView` displays the `ATLAddressBarTextView` in which the actual text input occurs. It also displays
 a UIButton object represented by the `addContactButton` property.
 */
@property (nonatomic) ATLAddressBarView *addressBarView;

///------------------------------------
// @name Managing Participant Selection
///------------------------------------

/**
 @abstract An ordered set of the currently selected participants.
 */
@property (nonatomic) NSOrderedSet *selectedParticipants;

/**
 @abstract Informs the receiver that a selection occurred outside of the controller and a participant should be added to the address
 bar.
 @param participant The participant to select.
 */
- (void)selectParticipant:(id<ATLParticipant>)participant;

///-------------------------
/// @name Reloading the View
///-------------------------

/**
 @abstract Tells the receiver to reload the view with the latest details of the participants.
 */
- (void)reloadView;

///----------------------
/// @name Disabling Input
///----------------------

/**
@abstract Disables user input and searching.
 */
- (void)disable;

/**
 @abstract A boolean indicating whether or not the receiver is in a disabled state.
 */
- (BOOL)isDisabled;

@end
