//
//  LYRUIParticipantTableDataSet.m
//  Pods
//
//  Created by Ben Blakley on 12/18/14.
//
//

#import "LYRUIParticipantTableDataSet.h"

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
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
            break;
        case LYRUIParticipantPickerSortTypeLastName:
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
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
        NSString *initial = [name substringToIndex:1].uppercaseString;
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
