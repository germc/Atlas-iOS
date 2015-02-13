//
//  LYRUIParticipantTableDataSet.m
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

#import "LYRUIParticipantTableDataSet.h"

static NSString *const LYRUIParticipantTableMiscellaneaSectionTitle = @"#";

@interface LYRUIParticipantTableSectionData : NSObject

@property (nonatomic) NSRange participantsRange;

@end

@implementation LYRUIParticipantTableSectionData

@end

@interface LYRUIParticipantTableDataSet ()

@property (nonatomic) NSArray *sectionTitles;
@property (nonatomic) NSArray *participants;
@property (nonatomic) NSArray *sections;

@end

@implementation LYRUIParticipantTableDataSet

+ (instancetype)dataSetWithParticipants:(NSSet *)participants sortType:(LYRUIParticipantPickerSortType)sortType
{
    NSSortDescriptor *sortDescriptor;
    switch (sortType) {
        case LYRUIParticipantPickerSortTypeFirstName:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES selector:@selector(localizedStandardCompare:)];
            break;
        case LYRUIParticipantPickerSortTypeLastName:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES selector:@selector(localizedStandardCompare:)];
            break;
    }
    NSArray *sortedParticipants = [participants sortedArrayUsingDescriptors:@[sortDescriptor]];

    NSMutableArray *sections = [NSMutableArray new];
    NSMutableArray *sectionTitles = [NSMutableArray new];
    NSString *currentSectionTitle;
    LYRUIParticipantTableSectionData *currentSectionData;
    for (id<LYRUIParticipant> participant in sortedParticipants) {
        NSString *name;
        switch (sortType) {
            case LYRUIParticipantPickerSortTypeFirstName:
                name = participant.firstName;
                break;
            case LYRUIParticipantPickerSortTypeLastName:
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
            LYRUIParticipantTableSectionData *priorSectionData = currentSectionData;
            currentSectionData = [LYRUIParticipantTableSectionData new];
            currentSectionData.participantsRange = NSMakeRange(NSMaxRange(priorSectionData.participantsRange), 1);
            [sections addObject:currentSectionData];
        }
    }

    LYRUIParticipantTableDataSet *dataSet = [self new];
    dataSet.participants = sortedParticipants;
    dataSet.sectionTitles = sectionTitles;
    dataSet.sections = sections;
    return dataSet;
}

+ (NSString *)initialForName:(NSString *)name
{
    if (name.length == 0) return LYRUIParticipantTableMiscellaneaSectionTitle;
    NSString *initial = [name substringToIndex:1];
    initial = [initial decomposedStringWithCanonicalMapping];
    if (initial.length > 1) {
        initial = [initial substringToIndex:1];
    }
    initial = initial.uppercaseString;
    NSCharacterSet *uppercaseCharacters = [NSCharacterSet uppercaseLetterCharacterSet];
    NSRange range = [initial rangeOfCharacterFromSet:uppercaseCharacters];
    if (range.location == NSNotFound) return LYRUIParticipantTableMiscellaneaSectionTitle;
    return initial;
}

- (NSUInteger)numberOfSections
{
    return self.sections.count;
}

- (NSUInteger)numberOfParticipantsInSection:(NSUInteger)section
{
    LYRUIParticipantTableSectionData *sectionData = self.sections[section];
    return sectionData.participantsRange.length;
}

- (id<LYRUIParticipant>)participantAtIndexPath:(NSIndexPath *)indexPath
{
    LYRUIParticipantTableSectionData *sectionData = self.sections[indexPath.section];
    NSUInteger index = sectionData.participantsRange.location + indexPath.row;
    id<LYRUIParticipant> participant = self.participants[index];
    return participant;
}

- (NSIndexPath *)indexPathForParticipant:(id<LYRUIParticipant>)participant
{
    NSUInteger index = [self.participants indexOfObject:participant];
    if (index == NSNotFound) return nil;
    __block NSIndexPath *indexPath;
    [self.sections enumerateObjectsUsingBlock:^(LYRUIParticipantTableSectionData *sectionData, NSUInteger section, BOOL *stop) {
        NSRange range = sectionData.participantsRange;
        NSUInteger row = index - range.location;
        if (row >= range.length) return;
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        *stop = YES;
    }];
    return indexPath;
}

@end
