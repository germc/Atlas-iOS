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

@optional

/**
 @abstract Tells the receiver that the user has deselected a participant.
 @param participantTableViewController The participant table view controller in which the deselection was made.
 @param participant The participant who was deselected.
 */
- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didDeselectParticipant:(id<LYRUIParticipant>)participant;

@end

/**
 @abstract The `LYRUIParticipantTableViewController` sorts, groups, and displays a list of participants. It provides search capability.
 */
@interface LYRUIParticipantTableViewController : UITableViewController

/**
 @abstract Creates and returns an `LYRUIParticipantTableViewController` initialized with the given set of participants and sort type.
 @param participants The set of participants to be used for display in the table view.
 @param sortType The sort order applied to the participants. 
 @return A new participant picker initialized with the given participant set and sort type.
 */
+ (instancetype)participantTableViewControllerWithParticipants:(NSSet *)participants sortType:(LYRUIParticipantPickerSortType)sortType;

/**
 @abstract The participants to display.
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) NSSet *participants;

/**
 @abstract Defines the sort ordering of the participant list.
 @default `LYRUIParticipantPickerSortTypeFirstName`.
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) LYRUIParticipantPickerSortType sortType;


/**
 @abstract The delegate for the participant table view controller.
 */
@property (nonatomic, weak) id<LYRUIParticipantTableViewControllerDelegate> delegate;

/**
 @abstract The table view cell class for customizing the display of participants.
 @default `[LYRUIParticipantTableViewCell class]`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) Class<LYRUIParticipantPresenting> cellClass;

/**
 @abstract Sets the height for cells within the receiver.
 @default `48.0`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) CGFloat rowHeight;

/**
 @abstract A boolean value that determines whether multiple participants can be selected at once.
 @default YES
 @discussion The defauly value of this property is `YES`.
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

@end
