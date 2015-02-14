//
//  ATLUIParticipantTableDataSet.h
//  Atlas
//
//  Created by Ben Blakley on 12/18/14.
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

#import <Foundation/Foundation.h>
#import "ATLParticipantPresenting.h"

@interface ATLParticipantTableDataSet : NSObject

/**
 @abstract Creates and returns a data set to be used to populate a table view.
 @param participants The set of participants to use. Each object in the given set must conform to the `ATLParticipant` protocol.
 @param sortType The type of sorting to use.
 @return A new data set initialized with the given set of participants.
 */
+ (instancetype)dataSetWithParticipants:(NSSet *)participants sortType:(ATLParticipantPickerSortType)sortType;

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
- (NSIndexPath *)indexPathForParticipant:(id<ATLParticipant>)participant;

/**
 @abstract The participant at the supplied index path.
 */
- (id<ATLParticipant>)participantAtIndexPath:(NSIndexPath *)indexPath;

@end
