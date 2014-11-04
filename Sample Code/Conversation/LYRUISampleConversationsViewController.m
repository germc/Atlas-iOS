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
    NSMutableString *statuses = [NSMutableString string];
    [[recipientStatus allKeys] enumerateObjectsUsingBlock:^(NSString *participant, NSUInteger idx, BOOL *stop) {
        LYRRecipientStatus status = [recipientStatus[participant] unsignedIntegerValue];
        if ([participant isEqualToString:self.layerClient.authenticatedUserID]) {
            return;
        }
        if (status == LYRRecipientStatusSent) {
            [statuses appendString:@"sent✔︎ "];
        } else if (status == LYRRecipientStatusDelivered) {
            [statuses appendString:@"delivered✔︎ "];
        } else if (status == LYRRecipientStatusRead) {
            [statuses appendString:@"read✔︎ "];
        }
    }];
//    if (statuses.length) {
//        [statuses insertString:@"read" atIndex:0];
//    }
    return [[NSAttributedString alloc] initWithString:statuses];
}

@end
