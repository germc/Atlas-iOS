//
//  LYRUITestParticipantDataSource.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/29/14.
//
//

#import "LYRUITestParticipantDataSource.h"

@interface LYRUITestParticipantDataSource ()

@property (nonatomic) NSSet *participants;

@end

@implementation LYRUITestParticipantDataSource

+ (instancetype)dataSourceWithParticipants:(NSSet *)participants
{
    return [[self alloc] initWithParticipants:participants];
}

- (id)initWithParticipants:(NSSet *)participants
{
    self = [super init];
    if (self) {
        _participants = participants;
    }
    return self;
}

- (NSSet *)participantsForParticipantPickerController:(LYRUIParticipantPickerController *)participantPickerController
{
    return self.participants;
}

- (void)participantPickerController:(LYRUIParticipantPickerController *)participantPickerController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSSet *participants))completion
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.fullName CONTAINS %@", searchText];
    NSSet *set = [self.participants filteredSetUsingPredicate:predicate];
    completion(set);
}

- (void)dealloc
{
    
}

@end
