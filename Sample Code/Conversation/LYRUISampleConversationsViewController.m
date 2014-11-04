//
//  LYRUISampleConversationsViewController.h
//  LayerUIKit
//
//  Created by Klemen Verdnik on 11/3/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRUISampleConversationsViewController.h"
#import <LayerUIKit/LYRUIConversationDataSource.h>
#import "LYRClientMock.h"
#import "LYRClientMockFactory.h"
#import "LYRUIParticipant.h"

@interface LYRUISampleConversationsViewController () <LYRUIConversationViewControllerDataSource>

@property (nonatomic) LYRClientMockFactory *clientMockFactory;
@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation LYRUISampleConversationsViewController

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
}

#pragma mark - LYRUIConversationViewControllerDataSource methods

- (id<LYRUIParticipant>)conversationViewController:(LYRUIConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    return [LYRClientMockFactory userForParticipantIdentifier:participantIdentifier];
}

- (NSAttributedString *)conversationViewController:(LYRUIConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    return [[NSAttributedString alloc] initWithString:[self.dateFormatter stringFromDate:date]];
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
        NSString *participantNameWithCheckmark = [NSString stringWithFormat:@"%@✔︎ ", [LYRClientMockFactory userForParticipantIdentifier:participant].firstName];
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

@end
