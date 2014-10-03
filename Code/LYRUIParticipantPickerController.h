//
//  LYRUIParticipantPickerController.h
//  
//
//  Created by Kevin Coleman on 8/29/14.
//
//

#import <UIKit/UIKit.h>
#import "LYRUIParticipantTableViewCell.h"
#import "LYRUIParticipant.h"
#import "LYRUIParticipantTableViewController.h"

@class LYRUIParticipantPickerController;

/**
 @abstract The `LYRUIParticipantPickerControllerDelegate` protocol must be adopted by objects that wish to act
 as the delegate for a `LYRUIParticipantPickerController` object.
 */
@protocol LYRUIParticipantPickerControllerDelegate <NSObject>

/**
 @abstract Tells the receiver that the participant selection view was dismissed without making a selection.
 @param participantSelectionViewController The participant selection view that was dismissed.
 */
- (void)participantSelectionViewControllerDidCancel:(LYRUIParticipantPickerController *)participantSelectionViewController;

/**
 @abstract Tells the receiver that the user has selected a set of participants from a participant selection view.
 @param participantSelectionViewController The participant selection view in which the selection was made.
 @param participants The set of participants that was selected.
 */
- (void)participantSelectionViewController:(LYRUIParticipantPickerController *)participantSelectionViewController didSelectParticipants:(NSSet *)participants;

@end

/**
 @abstract Objects wishing to act as the data source for a participant picker must adopt the `LYRUIParticipantsPickerDataSource` protocol.
 */
@protocol LYRUIParticipantPickerDataSource <NSObject>

/**
 @abstract The set of participants to be presented in the picker. Each object in the returned collection must conform to the `LYRUIParticipant` protocol.
 @discussion The picker presents the returned participants in alphabetical order sectioned by the value returned by the `sectionText` property.
 */
@property (nonatomic) NSSet *participants;

/**
 @abstract Asynchronously searches for participants that match the given search text.
 @discussion Invoked by the participant picker controller when the user inputs text into the search bar. The receiver is
 to perform the search, build a set of matching participants, and then call the completion block. The controller will section
 the participants using the value returned by the `sectionText` property and present them in alphabetical order.
 */
- (void)searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSSet *participants))completion;

@end

/**
 @abstract Displays a list of participants in a navigation controller and allows for searching of participants
 */
@interface LYRUIParticipantPickerController : UINavigationController

///------------------------------------
/// @name Creating a Participant Picker
///------------------------------------

/**
 @abstract Creates and returns a participant picker initialized with the given set of participants.
 @param participants The set of participants to display in the picker. Each object in the given set must conform to the `LYRUIParticipant` protocol.
 @returns A new participant picker initialized with the given set of participants.
 @raises NSInvalidArgumentException Raised if any object in the given set of participants does not conform to the `LYRUIParticipant` protocol.
 */
+ (instancetype)participantPickerWithDataSource:(id<LYRUIParticipantPickerDataSource>)dataSource sortType:(LYRUIParticipantPickerSortType)sortType;

///----------------------------------------
/// @name Accessing the Set of Participants
///----------------------------------------

@property (nonatomic) LYRUIParticipantPickerSortType sortType;

///-----------------------------------------
/// @name Accessing the Picker Data Source
///-----------------------------------------

@property (nonatomic, weak) id<LYRUIParticipantPickerDataSource> dataSource;

///-----------------------------------------
/// @name Accessing the Picker Delegate
///-----------------------------------------

@property (nonatomic, weak) id<LYRUIParticipantPickerControllerDelegate> participantPickerDelegate;

///---------------------------------
/// @name Configuring Picker Options
///---------------------------------

/**
 @abstract A Boolean value that determines whether multiple participants can be selected at once.
 @discussion The defauly value of this property is `YES`.
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

/**
 @abstract The table view cell class for customizing the display of participants.
 @default `[LYRUIParticipantTableViewCell class]`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) Class<LYRUIParticipantPresenting> cellClass;

/**
 @abstract Configures the height of each row in the receiver.
 @default 44.0f
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) CGFloat rowHeight;

/**
 @abstract Configures the sort type of the receiver.
 @default LYRUIParticipantPickerControllerSortTypeFirst
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) LYRUIParticipantPickerSortType participantPickerSortType;

@end
