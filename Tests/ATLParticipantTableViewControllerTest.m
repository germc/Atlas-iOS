//
//  LYUIParticipantTableViewControllerTest.m
//  Atlas
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ATLTestInterface.h"
#import "ATLParticipantTableViewCell.h"
#import "ATLParticipant.h"
#import "ATLSampleParticipantTableViewController.h"

@interface ATLParticipantTableViewCell ()

@property (nonatomic) UILabel *nameLabel;

@end

@interface ATLParticipantTableViewControllerTest : XCTestCase

@property (nonatomic) ATLTestInterface *testInterface;
@property (nonatomic) ATLSampleParticipantTableViewController *controller;

@end

@implementation ATLParticipantTableViewControllerTest

NSString *const ATLParticipantTableViewAccessibilityIdentifier;

- (void)setUp
{
    [super setUp];

    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [ATLTestInterface testIntefaceWithLayerClient:layerClient];
    
    NSSet *participants = [LYRUserMock allMockParticipants];
    self.controller = [ATLSampleParticipantTableViewController participantTableViewControllerWithParticipants:participants sortType:ATLParticipantPickerSortTypeFirstName];
    [self.controller setCellClass:[ATLParticipantTableViewCell class]];
    
    [[ATLParticipantTableViewCell appearance] setTitleFont:[UIFont systemFontOfSize:14]];
    [[ATLParticipantTableViewCell appearance] setTitleColor:[UIColor blackColor]];
}

- (void)tearDown
{
    [[LYRMockContentStore sharedStore] resetContentStore];
    self.testInterface = nil;
    self.controller = nil;
    [super tearDown];
}

- (void)testToVerifyListOfContactsDisplaysAppropriately
{
    [self setRootViewController];
    NSSet *participants = [LYRUserMock allMockParticipants];
    for (LYRUserMock *mock in participants) {
        NSString *name = [NSString stringWithFormat:@"%@", mock.fullName];
        [tester waitForViewWithAccessibilityLabel:name];
    }
}

- (void)testToVerifySearchForKnownParticipantDisplaysIntendedResult
{
    [self setRootViewController];
    LYRUserMock *mock = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby];
    [tester tapViewWithAccessibilityLabel:@"Search Bar"];
    [tester enterText:mock.fullName intoViewWithAccessibilityLabel:@"Search Bar"];
    [tester waitForViewWithAccessibilityLabel:mock.fullName];
}

//Search for a participant with an unknown name and verify that the list is empty.
- (void)testToVerifYSearchForUnknownParticipantDoesNotDisplayResult
{
    [self setRootViewController];
    NSString *searchText = @"Fake Name";
    [tester tapViewWithAccessibilityLabel:@"Search Bar"];
    [tester enterText:searchText intoViewWithAccessibilityLabel:@"Search Bar"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:searchText];
}

//Test that the colors and fonts can be changed by using the UIAppearance selectors.
- (void)testToVerifyColorAndFontChangeFunctionality
{
    UIFont *testFont = [UIFont systemFontOfSize:20];
    UIColor *testColor = [UIColor redColor];
    [[ATLParticipantTableViewCell appearance] setTitleFont:testFont];
    [[ATLParticipantTableViewCell appearance] setTitleColor:testColor];
    [self setRootViewController];
    
    LYRUserMock *mock = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby];
    ATLParticipantTableViewCell *cell = (ATLParticipantTableViewCell *)[tester waitForViewWithAccessibilityLabel:mock.fullName];
    expect(cell.titleFont).to.equal(testFont);
    expect(cell.titleColor).to.equal(testColor);
}

//Verify that the cell can be overridden and a new UI presented.
- (void)testToVerifyCustomCellClassFunctionality
{
    self.controller.cellClass = [ATLTestParticipantCell class];
    [self setRootViewController];
    
    LYRUserMock *mock = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby];
    expect([[tester waitForViewWithAccessibilityLabel:mock.fullName] class]).to.equal([ATLTestParticipantCell class]);
    expect([[tester waitForViewWithAccessibilityLabel:mock.fullName] class]).toNot.equal([ATLParticipantTableViewCell class]);
}

//Verify that the row height can be configured.
- (void)testToVerifyCustomRowHeightFunctionality
{
    LYRUserMock *mock = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby];
    self.controller.rowHeight = 80;
    [self setRootViewController];
    expect([tester waitForViewWithAccessibilityLabel:mock.fullName].frame.size.height).to.equal(80);
}

-(void)testToVerifySectionTextPropertyFunctionality
{
    [self setRootViewController];
    
    NSSet *participants = [LYRUserMock allMockParticipants];
    NSArray *sortedParticipantsFirst = [[participants allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
    LYRUserMock *firstUser = (LYRUserMock *)[sortedParticipantsFirst firstObject];
    ATLParticipantTableViewCell *cell = (ATLParticipantTableViewCell *)[tester waitForViewWithAccessibilityLabel:firstUser.fullName];
    expect(cell.nameLabel.text).to.equal(firstUser.fullName);
    
    NSArray *sortedParticipantsLast = [[participants allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]]];
    self.controller = [ATLSampleParticipantTableViewController participantTableViewControllerWithParticipants:participants sortType:ATLParticipantPickerSortTypeLastName];
    [self setRootViewController];
    firstUser = (LYRUserMock *)[sortedParticipantsLast firstObject];
    cell = (ATLParticipantTableViewCell *)[tester waitForViewWithAccessibilityLabel:firstUser.fullName];
    expect(cell.nameLabel.text).to.equal(firstUser.fullName);
}

//Test that attempts to change the cell class after the view is loaded results in a runtime error.
- (void)testToVerifyChangingCellClassAfterViewLoadRaiseException
{
    [self setRootViewController];
    expect(^{ [self.controller setCellClass:[UITableView class]]; }).to.raise(NSInternalInconsistencyException);
}

//Test that attempting to change the row height after the view is loaded results in a runtime error.
- (void)testToVerifyChangingRowHeightAfterViewLoadRaiseException
{
    [self setRootViewController];
    expect(^{ [self.controller setRowHeight:80]; }).to.raise(NSInternalInconsistencyException);
}

- (void)testToVerifyParticipantPickerDelegateFunctionalityForCancelButton
{
    [self setRootViewController];
    id delegateMock = OCMProtocolMock(@protocol(ATLParticipantTableViewControllerDelegate));
    self.controller.delegate = delegateMock;
    [self setRootViewController];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
    //
    }] participantTableViewController:[OCMArg any] didSearchWithString:[OCMArg any] completion:nil];

    [tester tapViewWithAccessibilityLabel:@"Search Bar"];
    [tester enterText:@"S" intoViewWithAccessibilityLabel:@"Search Bar"];
    [delegateMock verify];
}

- (void)testtoVerifyParticipantPickerDelegateFunctionalityForParticipantSelection
{
    [self setRootViewController];
    id delegateMock = OCMProtocolMock(@protocol(ATLParticipantTableViewControllerDelegate));
    self.controller.delegate = delegateMock;
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {

        
    }] participantTableViewController:[OCMArg any] didSelectParticipant:[OCMArg any]];
    
    LYRUserMock *mock = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby];
    [tester tapViewWithAccessibilityLabel:mock.fullName];
    [delegateMock verify];
}

- (void)setRootViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.controller];
    [self.testInterface pushViewController:navigationController];
    [tester waitForViewWithAccessibilityLabel:@"Participants"];
}

@end
