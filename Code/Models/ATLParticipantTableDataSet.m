//
//  ATLUIParticipantTableDataSet.m
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
#import "ATLParticipantTableDataSet.h"

static NSString *const ATLParticipantTableMiscellaneaSectionTitle = @"#";

@interface ATLParticipantTableSectionData : NSObject

@property (nonatomic) NSRange participantsRange;

@end

@implementation ATLParticipantTableSectionData

@end

@interface ATLParticipantTableDataSet ()

@property (nonatomic) NSArray *sectionTitles;
@property (nonatomic) NSArray *participants;
@property (nonatomic) NSArray *sections;

@end

@implementation ATLParticipantTableDataSet

+ (instancetype)dataSetWithParticipants:(NSSet *)participants sortType:(ATLParticipantPickerSortType)sortType
{
    NSSortDescriptor *sortDescriptor;
    switch (sortType) {
        case ATLParticipantPickerSortTypeFirstName:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES selector:@selector(localizedStandardCompare:)];
            break;
        case ATLParticipantPickerSortTypeLastName:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES selector:@selector(localizedStandardCompare:)];
            break;
    }
    NSArray *sortedParticipants = [participants sortedArrayUsingDescriptors:@[sortDescriptor]];

    NSMutableArray *sections = [NSMutableArray new];
    NSMutableArray *sectionTitles = [NSMutableArray new];
    NSString *currentSectionTitle;
    ATLParticipantTableSectionData *currentSectionData;
    for (id<ATLParticipant> participant in sortedParticipants) {
        NSString *name;
        switch (sortType) {
            case ATLParticipantPickerSortTypeFirstName:
                name = participant.firstName;
                break;
            case ATLParticipantPickerSortTypeLastName:
                name = participant.lastName;
                break;
        }
        NSString *initial = [self initialForName:name];
        if ([initial isEqualToString:currentSectionTitle]) {
            NSRange range = currentSectionData.participantsRange;
            range.length += 1;
            currentSectionData.participantsRange = range;
        } else {
            currentSectionTitle = initial;
            [sectionTitles addObject:currentSectionTitle];
            ATLParticipantTableSectionData *priorSectionData = currentSectionData;
            currentSectionData = [ATLParticipantTableSectionData new];
            currentSectionData.participantsRange = NSMakeRange(NSMaxRange(priorSectionData.participantsRange), 1);
            [sections addObject:currentSectionData];
        }
    }

    ATLParticipantTableDataSet *dataSet = [self new];
    dataSet.participants = sortedParticipants;
    dataSet.sectionTitles = sectionTitles;
    dataSet.sections = sections;
    return dataSet;
}

+ (NSString *)initialForName:(NSString *)name
{
    if (name.length == 0) return ATLParticipantTableMiscellaneaSectionTitle;
    NSString *initial = [name substringToIndex:1];
    initial = [initial decomposedStringWithCanonicalMapping];
    if (initial.length > 1) {
        initial = [initial substringToIndex:1];
    }
    initial = initial.uppercaseString;
    NSCharacterSet *uppercaseCharacters = [NSCharacterSet uppercaseLetterCharacterSet];
    NSRange range = [initial rangeOfCharacterFromSet:uppercaseCharacters];
    if (range.location == NSNotFound) return ATLParticipantTableMiscellaneaSectionTitle;
    return initial;
}

- (NSUInteger)numberOfSections
{
    return self.sections.count;
}

- (NSUInteger)numberOfParticipantsInSection:(NSUInteger)section
{
    ATLParticipantTableSectionData *sectionData = self.sections[section];
    return sectionData.participantsRange.length;
}

- (id<ATLParticipant>)participantAtIndexPath:(NSIndexPath *)indexPath
{
    ATLParticipantTableSectionData *sectionData = self.sections[indexPath.section];
    NSUInteger index = sectionData.participantsRange.location + indexPath.row;
    id<ATLParticipant> participant = self.participants[index];
    return participant;
}

- (NSIndexPath *)indexPathForParticipant:(id<ATLParticipant>)participant
{
    NSUInteger index = [self.participants indexOfObject:participant];
    if (index == NSNotFound) return nil;
    __block NSIndexPath *indexPath;
    [self.sections enumerateObjectsUsingBlock:^(ATLParticipantTableSectionData *sectionData, NSUInteger section, BOOL *stop) {
        NSRange range = sectionData.participantsRange;
        NSUInteger row = index - range.location;
        if (row >= range.length) return;
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        *stop = YES;
    }];
    return indexPath;
}

@end
