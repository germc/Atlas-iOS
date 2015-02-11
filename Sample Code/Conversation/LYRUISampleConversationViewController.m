//
//  LYRUISampleConversationsViewController.h
//  LayerUIKit
//
//  Created by Klemen Verdnik on 11/3/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRUISampleConversationViewController.h"
#import "LYRClientMock.h"
#import "LYRUIParticipant.h"

@interface LYRUISampleConversationViewController () <LYRUIConversationViewControllerDataSource>

@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation LYRUISampleConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Setup the datasource as self, since we're going to
    // handle it in this implementation file.
    self.dataSource = self;
    
    // Setup the dateformatter used by the dataSource.
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    [self configureTitle];
}

#pragma mark - LYRUIConversationViewControllerDataSource methods

- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    return [LYRUserMock mockUserForIdentifier:participantIdentifier];
}

- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor grayColor] };
    return [[NSAttributedString alloc] initWithString:[self.dateFormatter stringFromDate:date] attributes:attributes];
}

- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    if (recipientStatus.count == 0) return nil;
    NSMutableAttributedString *mergedStatuses = [[NSMutableAttributedString alloc] init];

    [[recipientStatus allKeys] enumerateObjectsUsingBlock:^(NSString *participant, NSUInteger idx, BOOL *stop) {
        LYRRecipientStatus status = [recipientStatus[participant] unsignedIntegerValue];
        if ([participant isEqualToString:self.layerClient.authenticatedUserID]) {
            return;
        }
        NSString *participantNameWithCheckmark = [NSString stringWithFormat:@"%@✔︎ ", [LYRUserMock mockUserForIdentifier:participant].firstName];
        UIColor *textColor = [UIColor lightGrayColor];
        if (status == LYRRecipientStatusSent) {
            textColor = [UIColor lightGrayColor];
        } else if (status == LYRRecipientStatusDelivered) {
            textColor = [UIColor orangeColor];
        } else if (status == LYRRecipientStatusRead) {
            textColor = [UIColor greenColor];
        }
        NSAttributedString *statusString = [[NSAttributedString alloc] initWithString:participantNameWithCheckmark attributes:@{NSForegroundColorAttributeName: textColor}];
        [mergedStatuses appendAttributedString:statusString];
    }];
    return mergedStatuses;
}

- (void)configureTitle
{
    if (!self.conversation) {
        self.title = @"New Message";
        return;
    }
    
    NSMutableSet *otherParticipantIDs = [self.conversation.participants mutableCopy];
    if (self.layerClient.authenticatedUserID) [otherParticipantIDs removeObject:self.layerClient.authenticatedUserID];
    
    if (otherParticipantIDs.count == 0) {
        self.title = @"Personal";
    } else if (otherParticipantIDs.count == 1) {
        NSString *otherParticipantID = [otherParticipantIDs anyObject];
        id<LYRUIParticipant> participant = [LYRUserMock mockUserForIdentifier:otherParticipantID];
        if (participant) {
            self.title = participant.firstName;
        } else {
            self.title = @"Unknown";
        }
    } else {
        self.title = @"Group";
    }
}

@end
