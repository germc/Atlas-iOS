//
//  LYRUIParticipantTableViewCellTest.m
//  Atlas
//
//  Created by Kevin Coleman on 2/10/15.
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
#import <XCTest/XCTest.h>
#import "LYRUITestInterface.h"
#import "LYRUISampleParticipantTableViewController.h"

@interface LYRUIParticipantPickerCustomizationTest : XCTestCase

@property (nonatomic) LYRUITestInterface *testInterface;
@property (nonatomic) LYRUserMock *userMock;

@end

@implementation LYRUIParticipantPickerCustomizationTest

extern NSString *const LYRUIParticipantTableViewAccessibilityIdentifier;
extern NSString *const LYRUIParticipantSectionHeaderViewAccessibilityLabel;

- (void)setUp
{
    [super setUp];
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [LYRUITestInterface testIntefaceWithLayerClient:layerClient];
    self.userMock = [LYRUserMock new];
}

- (void)tearDown
{
    UINavigationController *navigationController = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [navigationController dismissViewControllerAnimated:YES completion:nil];
    self.userMock = nil;
    [super tearDown];
}

- (void)testToVerifyCustomTextColor
{
    UIColor *testColor = [UIColor redColor];
    [[LYRUIParticipantTableViewCell appearance] setTitleColor:testColor];
    [self presentParticipantPicker];
    
    LYRUIParticipantTableViewCell *cell = (LYRUIParticipantTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:LYRUIParticipantTableViewAccessibilityIdentifier];
    expect(cell.titleColor).to.equal(testColor);
}

- (void)testToVerifyCustomFont
{
    UIFont *testFont = [UIFont systemFontOfSize:20];
    [[LYRUIParticipantTableViewCell appearance] setTitleFont:testFont];
    [self presentParticipantPicker];
    
    LYRUIParticipantTableViewCell *cell = (LYRUIParticipantTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:LYRUIParticipantTableViewAccessibilityIdentifier];
    expect(cell.titleFont).to.equal(testFont);
}

- (void)testToVerifyCustomBoldFont
{
    UIFont *testFont = [UIFont boldSystemFontOfSize:10];
    [[LYRUIParticipantTableViewCell appearance] setBoldTitleFont:testFont];
    [self presentParticipantPicker];
    
    LYRUIParticipantTableViewCell *cell = (LYRUIParticipantTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:LYRUIParticipantTableViewAccessibilityIdentifier];
    expect(cell.boldTitleFont).to.equal(testFont);
}

- (void)testToVeifyCustomHeaderFont
{
    UIFont *boldFont = [UIFont boldSystemFontOfSize:20];
    [[LYRUIParticipantSectionHeaderView appearance] setSectionHeaderFont:boldFont];
    [self presentParticipantPicker];
    
    LYRUserMock *user = [[[LYRUserMock allMockParticipants] allObjects] firstObject];
    NSString *name = user.fullName;
    NSString *firstInitial = [name substringToIndex:1];
    
    LYRUIParticipantSectionHeaderView *header = (LYRUIParticipantSectionHeaderView *)[tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@ - %@", LYRUIParticipantSectionHeaderViewAccessibilityLabel, firstInitial]];
    expect(header.sectionHeaderFont).to.equal(boldFont);
}

- (void)testToVerifyCustomHeaderTextColor
{
    UIColor *testColor = [UIColor redColor];
    [[LYRUIParticipantSectionHeaderView appearance] setSectionHeaderTextColor:testColor];
    [self presentParticipantPicker];
    
    LYRUserMock *user = [[[LYRUserMock allMockParticipants] allObjects] firstObject];
    NSString *name = user.fullName;
    NSString *firstInitial = [name substringToIndex:1];
    
    LYRUIParticipantSectionHeaderView *header = (LYRUIParticipantSectionHeaderView *)[tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@ - %@", LYRUIParticipantSectionHeaderViewAccessibilityLabel, firstInitial]];
    expect(header.sectionHeaderTextColor).to.equal(testColor);
}

- (void)testToVerifyCustomBackgroundColor
{
    UIColor *testColor = [UIColor redColor];
    [[LYRUIParticipantSectionHeaderView appearance] setSectionHeaderBackgroundColor:testColor];
    [self presentParticipantPicker];
    
    LYRUserMock *user = [[[LYRUserMock allMockParticipants] allObjects] firstObject];
    NSString *name = user.fullName;
    NSString *firstInitial = [name substringToIndex:1];
    
    LYRUIParticipantSectionHeaderView *header = (LYRUIParticipantSectionHeaderView *)[tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@ - %@", LYRUIParticipantSectionHeaderViewAccessibilityLabel, firstInitial]];
    expect(header.contentView.backgroundColor).to.equal(testColor);
    expect(header.sectionHeaderBackgroundColor).to.equal(testColor);
}

- (void)presentParticipantPicker
{
    NSSet *participants = [LYRUserMock allMockParticipants];
    LYRUISampleParticipantTableViewController *controller = [LYRUISampleParticipantTableViewController participantTableViewControllerWithParticipants:participants sortType:LYRUIParticipantPickerSortTypeFirstName];
    controller.allowsMultipleSelection = NO;
    
    UINavigationController *presentingController = [[UINavigationController alloc] initWithRootViewController:controller];
    UINavigationController *navigationController = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [navigationController presentViewController:presentingController animated:YES completion:nil];
}

@end