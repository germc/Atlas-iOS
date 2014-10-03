//
//  LYRUIParticipantListViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRUIParticipantTableViewCell.h"

/**
 @abstract The `LYRUIParticipantPickerSortType` allows for configuration of sorting order of the participant list
 */
typedef enum : NSUInteger {
    LYRUIParticipantPickerControllerSortTypeFirst,
    LYRUIParticipantPickerControllerSortTypeLast,
}LYRUIParticipantPickerSortType;


@class LYRUIParticipantTableViewController;

/**
 @abstract The `LYRUIParticipantViewControllerDelegate` protocol provides a method for notifying the adopting delegate about information changes.
 */
@protocol LYRUIParticipantTableViewControllerDelegate <NSObject>

/**
 @abstract Tells the receiver that the user has selected a participants from a participant selection view.
 @param participantSelectionViewController The participant selection view in which the selection was made.
 @param participant The participants that was selected.
 */
- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<LYRUIParticipant>)participant;

/**
 @abstract  Informs the delegate that a search has been made with the following search string. After the completion block is called, the `contactListViewController:presenterForContactAtIndex:` method will be called for each search result.
 @param contactListViewController An object representing the contact list view controller.
 @param searchString The search string that was just used for search.
 @param completion The completion block that should be called when the results are fetched from the search.
 */
- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *filteredParticipants))completion;

/**
 @abstract Informst the delegate that the user tapped the `cancel` button
 */
- (void)participantTableViewControllerDidSelectCancelButton;

/**
 @abstract Informst the delegate that the user tapped the `done` button
 */
- (void)participantTableViewControllerDidSelectDoneButtonWithSelectedParticipants:(NSMutableSet *)selectedParticipants;

@end

/**
 @abstract The `LYRUIParticipantTableViewController` sorts, groups, and displayes a list of participants. It provides search capability.
 */
@interface LYRUIParticipantTableViewController : UITableViewController

/**
 @abstract The table view cell class for customizing the display of participants.
 @default `[LYRUIParticipantTableViewCell class]`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) Class<LYRUIParticipantPresenting> participantCellClass;

/**
 @abstract The delegate for the participantTableViewController
 */
@property (nonatomic, weak) id<LYRUIParticipantTableViewControllerDelegate>delegate;

/**
 @abstract A dictionary containing a set of dictionaries each cooresponding to a unique letter in the alphabet
 */
@property (nonatomic) NSSet *participants;

/**
 @abstract Defines the sort ordering of the participant list. If set, the view controller will sort and group
 participants by the order you specify. If `LYRUIParticipantPickerControllerSortTypeNone`, the view controller 
 will not perform sorting or grouping.
 */
@property (nonatomic, assign) LYRUIParticipantPickerSortType sortType;

/**
 @abstract The seclection indicator used to indicate a contact has been selected. Should have views configured for both highlighted and non highlighted state
 @default `LYRUISelectionIndicator`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) UIControl *selectionIndicator;

/**
 @abstract Sets the height for cells within the receiver.
 @default `48.0`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) CGFloat rowHeight;

/**
 @abstract A Boolean value that determines whether multiple participants can be selected at once.
 @defaul Yes
 @discussion The defauly value of this property is `YES`.
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

@end
