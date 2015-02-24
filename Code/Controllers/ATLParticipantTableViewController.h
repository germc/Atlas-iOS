//
//  ATLUIParticipantListViewController.h
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
#import "ATLParticipantTableViewCell.h"


@class ATLParticipantTableViewController;

/**
 @abstract The `ATLParticipantViewControllerDelegate` protocol provides a method for notifying the adopting delegate about information changes.
 */
@protocol ATLParticipantTableViewControllerDelegate <NSObject>

/**
 @abstract Informs the receiver that the user has selected a participant.
 @param participantTableViewController The participant table view controller in which the selection was made.
 @param participant The participant who was selected.
 */
- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<ATLParticipant>)participant;

/**
 @abstract Informs the delegate that a search has been made with the following search string.
 @param participantTableViewController The participant table view controller in which the search was made.
 @param searchString The search string that was just used for search.
 @param completion The completion block that should be called when the results are fetched from the search.
 */
- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *filteredParticipants))completion;

@optional

/**
 @abstract Informs the receiver that the user has deselected a participant.
 @param participantTableViewController The participant table view controller in which the deselection was made.
 @param participant The participant who was deselected.
 */
- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didDeselectParticipant:(id<ATLParticipant>)participant;

@end

/**
 @abstract The `ATLParticipantTableViewController` sorts, groups, and displays a list of participants. It provides search capability.
 */
@interface ATLParticipantTableViewController : UITableViewController

/**
 @abstract Creates and returns an `ATLParticipantTableViewController` initialized with the given set of participants and sort type.
 @param participants The set of participants to be used for display in the table view.
 @param sortType The sort order applied to the participants. 
 @return A new participant picker initialized with the given participant set and sort type.
 */
+ (instancetype)participantTableViewControllerWithParticipants:(NSSet *)participants sortType:(ATLParticipantPickerSortType)sortType;

/**
 @abstract The participants to display.
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) NSSet *participants;

/**
 @abstract An `NSSet` of identifiers representing blocked participants.
 */
@property (nonatomic) NSSet *blockedParticipantIdentifiers;

/**
 @abstract Defines the sort ordering of the participant list.
 @default `ATLParticipantPickerSortTypeFirstName`.
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) ATLParticipantPickerSortType sortType;


/**
 @abstract The delegate for the participant table view controller.
 */
@property (nonatomic, weak) id<ATLParticipantTableViewControllerDelegate> delegate;

/**
 @abstract The table view cell class for customizing the display of participants.
 @default `[ATLParticipantTableViewCell class]`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic) Class<ATLParticipantPresenting> cellClass;

/**
 @abstract Sets the height for cells within the receiver.
 @default `48.0`
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) CGFloat rowHeight;

/**
 @abstract A boolean value that determines whether multiple participants can be selected at once.
 @default YES
 @discussion The default value of this property is `YES`.
 @raises NSInternalInconsistencyException Raised if the value is mutated after the receiver has been presented.
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

@end
