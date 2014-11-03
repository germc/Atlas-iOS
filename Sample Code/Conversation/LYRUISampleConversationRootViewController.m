//
//  LYRUISampleConversationRootViewController.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/30/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRUISampleConversationRootViewController.h"
#import <LayerUIKit/LYRUIConversationDataSource.h>
#import <LayerUIKit/LYRUIConversationViewController.h>
#import "LYRClientMock.h"
#import "LYRClientMockFactory.h"
#import "LYRUIParticipant.h"

@interface LYRUISampleConversationRootViewController () <LYRUIConversationViewControllerDataSource>

@property (nonatomic) LYRUIConversationViewController *conversationViewController;
@property (nonatomic) LYRClientMockFactory *clientMockFactory;
@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation LYRUISampleConversationRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup the title for this view controller
    self.title = @"Conversation view sample";
    
    // Use factory to create a client with some messages.
    self.clientMockFactory = [LYRClientMockFactory clientForAliceWithConversation];
    LYRConversationMock *conversation = [[self.clientMockFactory.layerClient conversationsForIdentifiers:nil] anyObject];

    // Instantiate and configure LYRUIConversationViewController
    self.conversationViewController = [LYRUIConversationViewController conversationViewControllerWithConversation:(id)conversation layerClient:(id)self.clientMockFactory.layerClient];
    self.conversationViewController.dataSource = self;
    
    // Setup the dateformatter used by the dataSource
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    // Put the LYRUIConversationViewController on view stack and display it
    [self addChildViewController:self.conversationViewController];
    [self.view addSubview:self.conversationViewController.view];
    [self.conversationViewController didMoveToParentViewController:self];
}

- (UIView *)inputAccessoryView
{
    return self.conversationViewController.inputAccessoryView;
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
    NSMutableString *statuses = [NSMutableString stringWithString:@"read "];
    [[recipientStatus allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [statuses appendString:@"✔︎"];
    }];
    return [[NSAttributedString alloc] initWithString:statuses];
}

@end
