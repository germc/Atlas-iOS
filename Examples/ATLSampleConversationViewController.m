//
//  ATLUISampleConversationsViewController.h
//  Atlas
//
//  Created by Klemen Verdnik on 11/3/14.
//  Copyright (c) 2014 Layer. All rights reserved.
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

#import "ATLSampleConversationViewController.h"
#import "LYRClientMock.h"
#import "ATLParticipant.h"
#import "ATLSampleParticipantTableViewController.h"

@interface ATLSampleConversationViewController () <ATLConversationViewControllerDataSource>

@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation ATLSampleConversationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.addressBarController.delegate = self;
    
    // Setup the dateformatter used by the dataSource.
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    [self configureTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTapLink:) name:ATLUserDidTapLinkNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTapPhoneNumber:) name:ATLUserDidTapPhoneNumberNotification object:nil];
}

#pragma mark - ATLConversationViewControllerDataSource methods

- (id<ATLParticipant>)conversationViewController:(ATLConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    return [ATLUserMock mockUserForIdentifier:participantIdentifier];
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor grayColor] };
    return [[NSAttributedString alloc] initWithString:[self.dateFormatter stringFromDate:date] attributes:attributes];
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    if (recipientStatus.count == 0) return nil;
    NSMutableAttributedString *mergedStatuses = [[NSMutableAttributedString alloc] init];

    [[recipientStatus allKeys] enumerateObjectsUsingBlock:^(NSString *participant, NSUInteger idx, BOOL *stop) {
        if ([participant isEqualToString:self.layerClient.authenticatedUserID]) {
            return;
        }
        NSString *participantNameWithCheckmark = [NSString stringWithFormat:@"%@✔︎ ", [ATLUserMock mockUserForIdentifier:participant].firstName];
        UIColor *textColor = [UIColor lightGrayColor];
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
        id<ATLParticipant> participant = [ATLUserMock mockUserForIdentifier:otherParticipantID];
        if (participant) {
            self.title = participant.firstName;
        } else {
            self.title = @"Unknown";
        }
    } else {
        self.title = @"Group";
    }
}

- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton
{
    NSSet *participants = [ATLUserMock allMockParticipants];
    ATLSampleParticipantTableViewController *controller = [ATLSampleParticipantTableViewController participantTableViewControllerWithParticipants:participants sortType:ATLParticipantPickerSortTypeFirstName];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<ATLParticipant>)participant
{
    [self.addressBarController selectParticipant:participant];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSArray *))completion
{
    completion([[ATLUserMock participantsWithText:searchText] allObjects]);
}

- (void)userDidTapLink:(NSNotification *)notification
{
    [[UIApplication sharedApplication] openURL:notification.object];
}

- (void)userDidTapPhoneNumber:(NSNotification *)notification
{
    
}

@end
