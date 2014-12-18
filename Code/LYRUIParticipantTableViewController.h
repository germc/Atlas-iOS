//
//  LYRUIParticipantListViewController.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYRUIParticipantTableViewCell.h"


@class LYRUIParticipantTableViewController;

/**
 @abstract The `LYRUIParticipantViewControllerDelegate` protocol provides a method for notifying the adopting delegate about information changes.
 */
@protocol LYRUIParticipantTableViewControllerDelegate <NSObject>

/**
 @abstract Tells the receiver that the user has selected a participant.
 @param participantTableViewController The participant table view controller in which the selection was made.
 @param participant The participant who was selected.
 */
- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<LYRUIParticipant>)participant;

/**
 @abstract Informs the delegate that a search has been made with the following search string.
 @param participantTableViewController The participant table view controller in which the search was made.
 @param searchString The search string that was just used for search.
 @param completion The completion block that should be called when the results are fetched from the search.
 */
- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *filteredParticipants))completion;

/**
 @abstract Informs the delegate that the user tapped the cancel button.
 */
- (void)participantTableViewControllerDidCancel:(LYRUIParticipantTableViewController *)participantTableViewController;

@end

/**
 @abstract The `LYRUIParticipantTableViewController` sorts, groups, and displays a list of participants. It provides search capability.
 */
@interface LYRUIParticipantTableViewController : UITableViewController

/**
 @abstract The table view cell class for customizing the display of participants.
 @default `[LYRUIParticipantTableViewCell class]`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) Class<LYRUIParticipantPresenting> participantCellClass;

/**
 @abstract The delegate for the participant table view controller.
 */
@property (nonatomic, weak) id<LYRUIParticipantTableViewControllerDelegate> delegate;

/**
 @abstract The participants to display.
 */
@property (nonatomic) NSSet *participants;

/**
 @abstract Defines the sort ordering of the participant list. The view controller will sort and group
 participants by the order you specify.
 */
@property (nonatomic, assign) LYRUIParticipantPickerSortType sortType;

/**
 @abstract The selection indicator used to indicate a contact has been selected. It should be configured for both highlighted and non-highlighted state.
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
 @abstract A boolean value that determines whether multiple participants can be selected at once.
 @defaul YES
 @discussion The defauly value of this property is `YES`.
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

@end
