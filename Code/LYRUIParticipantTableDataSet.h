//
//  LYRUIParticipantTableDataSet.h
//  Pods
//
//  Created by Ben Blakley on 12/18/14.
//
//

#import <Foundation/Foundation.h>
#import "LYRUIParticipantPresenting.h"

@interface LYRUIParticipantTableDataSet : NSObject

/**
 @abstract Creates and returns a data set to be used to populate a table view.
 @param participants The set of participants to use. Each object in the given set must conform to the `LYRUIParticipant` protocol.
 @param sortType The type of sorting to use.
 @return A new data set initialized with the given set of participants.
 */
+ (instancetype)dataSetWithParticipants:(NSSet *)participants sortType:(LYRUIParticipantPickerSortType)sortType;

/**
 @abstract An array containing a string for each section.
 */
@property (nonatomic, readonly) NSArray *sectionTitles;

/**
 @abstract The number of sections of participants in the data set.
 */
@property (nonatomic, readonly) NSUInteger numberOfSections;

/**
 @abstract The number of participants in the given section.
 */
- (NSUInteger)numberOfParticipantsInSection:(NSUInteger)section;

/**
 @abstract The index path for the supplied participant.
 */
- (NSIndexPath *)indexPathForParticipant:(id<LYRUIParticipant>)participant;

/**
 @abstract The participant at the supplied index path.
 */
- (id<LYRUIParticipant>)participantAtIndexPath:(NSIndexPath *)indexPath;

@end
