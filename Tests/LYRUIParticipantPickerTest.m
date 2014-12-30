//
//  LYRUIParticipantPickerTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.


#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LYRUITestInterface.h"

#import "LYRUIParticipantPickerController.h"
#import "LYRUIParticipantTableViewCell.h"
#import "LYRUITestParticipantCell.h"
#import "LYRUIParticipant.h"
#import "LYRUITestParticipantDataSource.h"

@interface LYRUIParticipantPickerTest : XCTestCase

@property (nonatomic) LYRUITestInterface *testInterface;
@property (nonatomic) LYRUIParticipantPickerController *controller;
@property (nonatomic) LYRUITestParticipantDataSource *dataSource;

@end

@implementation LYRUIParticipantPickerTest

- (void)setUp
{
    [super setUp];
    [[LYRMockContentStore sharedStore] resetContentStore];
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    LYRClientMock *layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
    self.testInterface = [LYRUITestInterface testIntefaceWithLayerClient:layerClient];
    
    NSSet *participants = [LYRUserMock allMockParticipants];
    self.dataSource = [LYRUITestParticipantDataSource dataSourceWithParticipants:participants];
    self.controller = [LYRUIParticipantPickerController participantPickerWithDataSource:self.dataSource
                                                                               sortType:LYRUIParticipantPickerSortTypeFirstName];
    [self.controller setCellClass:[LYRUIParticipantTableViewCell class]];
}

- (void)tearDown
{
    self.dataSource = nil;
    self.controller = nil;
    self.testInterface = nil;
    [[LYRMockContentStore sharedStore] resetContentStore];
    [[UIApplication sharedApplication] delegate].window.rootViewController = nil;
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
    [[LYRUIParticipantTableViewCell appearance] setTitleFont:testFont];
    [[LYRUIParticipantTableViewCell appearance] setTitleColor:testColor];
    [self setRootViewController];
    
    LYRUserMock *mock = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby];
    LYRUIParticipantTableViewCell *cell = (LYRUIParticipantTableViewCell *)[tester waitForViewWithAccessibilityLabel:mock.fullName];
    expect(cell.titleFont).to.equal(testFont);
    expect(cell.titleColor).to.equal(testColor);
}

//Verify that the cell can be overridden and a new UI presented.
- (void)testToVerifyCustomCellClassFunctionality
{
    self.controller.cellClass = [LYRUITestParticipantCell class];
    [self setRootViewController];
    
    LYRUserMock *mock = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby];
    expect([[tester waitForViewWithAccessibilityLabel:mock.fullName] class]).to.equal([LYRUITestParticipantCell class]);
    expect([[tester waitForViewWithAccessibilityLabel:mock.fullName] class]).toNot.equal([LYRUIParticipantTableViewCell class]);
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
    LYRUIParticipantTableViewCell *cell = (LYRUIParticipantTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                   inTableViewWithAccessibilityIdentifier:@"Participant TableView Controller"];
    expect(cell.nameLabel.text).to.equal(firstUser.fullName);
    
    NSArray *sortedParticipantsLast = [[participants allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]]];
    self.controller = [LYRUIParticipantPickerController participantPickerWithDataSource:self.dataSource
                                                                               sortType:LYRUIParticipantPickerSortTypeLastName];
    [self setRootViewController];
    firstUser = (LYRUserMock *)[sortedParticipantsLast firstObject];
    cell = (LYRUIParticipantTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                    inTableViewWithAccessibilityIdentifier:@"Participant TableView Controller"];
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
    id delegateMock = OCMProtocolMock(@protocol(LYRUIParticipantPickerControllerDelegate));
    self.controller.participantPickerDelegate = delegateMock;
    [self setRootViewController];
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
        //
    }] participantPickerControllerDidCancel:[OCMArg any]];
    
    [tester tapViewWithAccessibilityLabel:@"Cancel"];
    [delegateMock verify];
}

- (void)testtoVerifyParticipantPickerDelegateFunctionalityForParticipantSelection
{
    [self setRootViewController];
    id delegateMock = OCMProtocolMock(@protocol(LYRUIParticipantPickerControllerDelegate));
    self.controller.participantPickerDelegate = delegateMock;
    [[[delegateMock expect] andDo:^(NSInvocation *invocation) {

    }] participantPickerController:[OCMArg any] didSelectParticipant:[OCMArg any]];
    
    [tester tapRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:@"Participant TableView Controller"];
    [delegateMock verify];
}

- (void)testToVerifyParticipantPickerDataSourceFunctionality
{
    
}

- (void)setRootViewController
{
    [self.testInterface pushViewController:self.controller];
}
@end
