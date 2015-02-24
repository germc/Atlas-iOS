//
//  LYRParticipantTableViewCellTest.m
//  Atlas
//
//  Created by Kevin Coleman on 2/10/15.
//
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
#import "ATLTestInterface.h"

@interface LYRParticipantTableViewCellTest : XCTestCase

@property (nonatomic) ATLTestInterface *testInterface;
@property (nonatomic) ATLUserMock *userMock;

@end

@implementation LYRParticipantTableViewCellTest

extern NSString *const ATLParticipantTableViewAccessibilityIdentifier;
extern NSString *const ATLParticipantSectionHeaderViewAccessibilityLabel;

- (void)setUp
{
    [super setUp];
    ATLUserMock *mockUser = [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [ATLTestInterface testIntefaceWithLayerClient:layerClient];
    self.userMock = [ATLUserMock new];
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
    [[ATLParticipantTableViewCell appearance] setTitleColor:testColor];
    [self presentParticipantPicker];
    
    ATLUserMock *user = [[[ATLUserMock allMockParticipants] allObjects] firstObject];
    ATLParticipantTableViewCell *cell = (ATLParticipantTableViewCell *)[tester waitForViewWithAccessibilityLabel:user.fullName];
    expect(cell.titleColor).to.equal(testColor);
}

- (void)testToVerifyCustomFont
{
    UIFont *testFont = [UIFont systemFontOfSize:20];
    [[ATLParticipantTableViewCell appearance] setTitleFont:testFont];
    [self presentParticipantPicker];
    
    ATLUserMock *user = [[[ATLUserMock allMockParticipants] allObjects] firstObject];
    ATLParticipantTableViewCell *cell = (ATLParticipantTableViewCell *)[tester waitForViewWithAccessibilityLabel:user.fullName];
    expect(cell.titleFont).to.equal(testFont);
}

- (void)testToVerifyCustomBoldFont
{
    UIFont *testFont = [UIFont boldSystemFontOfSize:10];
    [[ATLParticipantTableViewCell appearance] setBoldTitleFont:testFont];
    [self presentParticipantPicker];
    
    ATLUserMock *user = [[[ATLUserMock allMockParticipants] allObjects] firstObject];
    ATLParticipantTableViewCell *cell = (ATLParticipantTableViewCell *)[tester waitForViewWithAccessibilityLabel:user.fullName];;
    expect(cell.boldTitleFont).to.equal(testFont);
}

- (void)testToVeifyCustomHeaderFont
{
    UIFont *boldFont = [UIFont boldSystemFontOfSize:20];
    [[ATLParticipantSectionHeaderView appearance] setSectionHeaderFont:boldFont];
    [self presentParticipantPicker];
    
    ATLUserMock *user = [[[ATLUserMock allMockParticipants] allObjects] firstObject];
    NSString *name = user.fullName;
    NSString *firstInitial = [name substringToIndex:1];
    
    ATLParticipantSectionHeaderView *header = (ATLParticipantSectionHeaderView *)[tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@ - %@", ATLParticipantSectionHeaderViewAccessibilityLabel, firstInitial]];
    expect(header.sectionHeaderFont).to.equal(boldFont);
}

- (void)testToVerifyCustomHeaderTextColor
{
    UIColor *testColor = [UIColor redColor];
    [[ATLParticipantSectionHeaderView appearance] setSectionHeaderTextColor:testColor];
    [self presentParticipantPicker];
    
    ATLUserMock *user = [[[ATLUserMock allMockParticipants] allObjects] firstObject];
    NSString *name = user.fullName;
    NSString *firstInitial = [name substringToIndex:1];
    
    ATLParticipantSectionHeaderView *header = (ATLParticipantSectionHeaderView *)[tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@ - %@", ATLParticipantSectionHeaderViewAccessibilityLabel, firstInitial]];
    expect(header.sectionHeaderTextColor).to.equal(testColor);
}

- (void)testToVerifyCustomBackgroundColor
{
    UIColor *testColor = [UIColor redColor];
    [[ATLParticipantSectionHeaderView appearance] setSectionHeaderBackgroundColor:testColor];
    [self presentParticipantPicker];
    
    ATLUserMock *user = [[[ATLUserMock allMockParticipants] allObjects] firstObject];
    NSString *name = user.fullName;
    NSString *firstInitial = [name substringToIndex:1];
    
    ATLParticipantSectionHeaderView *header = (ATLParticipantSectionHeaderView *)[tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@ - %@", ATLParticipantSectionHeaderViewAccessibilityLabel, firstInitial]];
    expect(header.contentView.backgroundColor).to.equal(testColor);
    expect(header.sectionHeaderBackgroundColor).to.equal(testColor);
}

- (void)presentParticipantPicker
{
    NSSet *participants = [ATLUserMock allMockParticipants];
    ATLParticipantTableViewController *controller = [ATLParticipantTableViewController participantTableViewControllerWithParticipants:participants sortType:ATLParticipantPickerSortTypeFirstName];
    controller.allowsMultipleSelection = NO;
    UINavigationController *presentingController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    UINavigationController *navigationController = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [navigationController presentViewController:presentingController animated:YES completion:nil];
}

@end
