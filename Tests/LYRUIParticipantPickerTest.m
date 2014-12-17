//
//  LYRUIParticipantPickerTest.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/2/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

//#import <UIKit/UIKit.h>
//#import <XCTest/XCTest.h>
//#import "LYRUITestInterface.h"
//
//#import "LYRUIParticipantPickerController.h"
//#import "LSUIParticipantPickerDataSource.h"
//#import "LYRUIParticipantTableViewCell.h"
//#import "LYRUITestParticipantCell.h"
//#import "LYRUIPaticipantSectionHeaderView.h"
//#import "LYRUIParticipant.h"
//
//@interface LYRUIParticipantPickerTest : XCTestCase
//
//@property (nonatomic) LYRUITestInterface *testInterface;
//
//@end
//
//@implementation LYRUIParticipantPickerTest
//
//- (void)setUp
//{
//    LSApplicationController *applicationController =  [(LSAppDelegate *)[[UIApplication sharedApplication] delegate] applicationController];
//    self.testInterface = [LYRUITestInterface testInterfaceWithApplicationController:applicationController];
//    [super setUp];
//    
//}
//
//- (void)tearDown
//{
//    [self.testInterface deleteContacts];
//    [self.testInterface logout];
//    [super tearDown];
//}
//
////Load a list of contacts from a local mock server, see them present in the UI. (Verify loading spinner?)
//- (void)testToVerifyListOfContactsDisplaysAppropriately
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    [tester waitForTimeInterval:2];
//    
//    NSSet *participants = [self.testInterface fetchContacts];
//
//    LYRUIParticipantPickerController *controller = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeFirst];
//    [system presentModalViewController:controller configurationBlock:^(id modalViewController) {
//        for (LSUser *user in participants) {
//            [tester waitForViewWithAccessibilityLabel:[NSString stringWithFormat:@"%@", user.fullName]];
//        }
//        [self dismissModalViewController:controller];
//    }];
//}
//
////Search for a participant with a known name and verify that it appears.
//- (void)testToVerifySearchForKnownParticipantDisplaysIntendedResult
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    [tester waitForTimeInterval:1];
//    
//    LYRUIParticipantPickerController *controller = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeFirst];
//    [system presentModalViewController:controller configurationBlock:^(id modalViewController) {
//        NSString *searchText = @"Kevin Coleman";
//        [tester tapViewWithAccessibilityLabel:@"Search Bar"];
//        [tester enterText:searchText intoViewWithAccessibilityLabel:@"Search Bar"];
//        [tester waitForViewWithAccessibilityLabel:searchText];
//        [self dismissModalViewController:controller];
//    }];
//}
//
////Search for a participant with an unknown name and verify that the list is empty.
//- (void)testToVerifYSearchForUnknownParticipantDoesNotDisplayResult
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    [tester waitForTimeInterval:1];
//    
//    LYRUIParticipantPickerController *controller = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeFirst];
//    [tester waitForTimeInterval:2];
//    [system presentModalViewController:controller configurationBlock:^(id modalViewController) {
//        NSString *searchText = @"Fake Name";
//        [tester tapViewWithAccessibilityLabel:@"Search Bar"];
//        [tester enterText:searchText intoViewWithAccessibilityLabel:@"Search Bar"];
//        [tester waitForAbsenceOfViewWithAccessibilityLabel:searchText];
//        [self dismissModalViewController:controller];
//    }];
//}
//
////Test that the colors and fonts can be changed by using the UIAppearance selectors.
//- (void)testToVerifyColorAndFontChangeFunctionality
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    [tester waitForTimeInterval:1];
//    
//    UIFont *testFont = [UIFont systemFontOfSize:20];
//    UIColor *testColor = [UIColor redColor];
//    
//    LSUser *user1 = [self.testInterface randomUser];
//    
//    LYRUIParticipantPickerController *controller = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeFirst];
//    [system presentModalViewController:controller configurationBlock:^(id modalViewController) {
//        [[LYRUIParticipantTableViewCell appearance] setTitleFont:testFont];
//        [[LYRUIParticipantTableViewCell appearance] setTitleColor:testColor];
//
//        LYRUIParticipantTableViewCell *cell = (LYRUIParticipantTableViewCell *)[tester waitForViewWithAccessibilityLabel:user1.fullName];
//        expect(cell.titleFont).to.equal(testFont);
//        expect(cell.titleColor).to.equal(testColor);
//        [self dismissModalViewController:controller];
//    }];
//}
//
////Verify that the cell can be overridden and a new UI presented.
//- (void)testToVerifyCustomCellClassFunctionality
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    [tester waitForTimeInterval:1];
//    LSUser *user1 = [self.testInterface randomUser];
//    
//    LYRUIParticipantPickerController *controller = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeFirst];
//    controller.cellClass = [LYRUITestParticipantCell class];
//    [tester waitForTimeInterval:2];
//    [system presentModalViewController:controller configurationBlock:^(id modalViewController) {
//        expect([[tester waitForViewWithAccessibilityLabel:user1.fullName] class]).to.equal([LYRUITestParticipantCell class]);
//        expect([[tester waitForViewWithAccessibilityLabel:user1.fullName] class]).toNot.equal([LYRUIParticipantTableViewCell class]);
//        [self dismissModalViewController:controller];
//    }];
//}
//
////Verify that the row height can be configured.
//- (void)testToVerifyCustomRowHeightFunctionality
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    [tester waitForTimeInterval:1];
//    LSUser *user1 =[self.testInterface randomUser];
//    
//    LYRUIParticipantPickerController *controller = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeFirst];
//    controller.rowHeight = 80;
//    [tester waitForTimeInterval:2];
//    [system presentModalViewController:controller configurationBlock:^(id modalViewController) {
//        expect([tester waitForViewWithAccessibilityLabel:user1.fullName].frame.size.height).to.equal(80);
//        [self dismissModalViewController:controller];
//    }];
//}
//
////Verify that the sorting by first name or last name produces the intended result
//-(void)testToVerifySectionTextPropertyFunctionality
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    [tester waitForTimeInterval:1];
//    NSSet *participants = [self.testInterface fetchContacts];
//    
//    NSArray *sortedParticipantsFirst = [[participants allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
//    LYRUIParticipantPickerController *controllerFirst = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeFirst];
//    LYRCountDownLatch *latch = [LYRCountDownLatch latchWithCount:1 timeoutInterval:10];
//    [system presentModalViewController:controllerFirst configurationBlock:^(id modalViewController) {
//        LSUser *participantFirst = (LSUser *)[sortedParticipantsFirst firstObject];
//        LYRUIParticipantTableViewCell *cell = (LYRUIParticipantTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:@"Participant TableView Controller"];
//        expect(cell.textLabel.text).to.equal(participantFirst.fullName);
//        [[modalViewController presentingViewController] dismissViewControllerAnimated:TRUE completion:^{
//            [latch decrementCount];
//        }];
//    }];
//    [latch waitTilCount:0];
//    
//    NSArray *sortedParticipantsLast = [[participants allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]]];
//    LYRUIParticipantPickerController *controllerLast = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeLast];
//    [system presentModalViewController:controllerLast configurationBlock:^(id modalViewController) {
//        LSUser *participantLast = (LSUser *)[sortedParticipantsLast firstObject];
//        LYRUIParticipantTableViewCell *cell = (LYRUIParticipantTableViewCell *)[tester waitForCellAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:@"Participant TableView Controller"];
//        expect(cell.textLabel.text).to.equal(participantLast.fullName);
//        [self dismissModalViewController:controllerLast];
//    }];
//}
//
////Test that attempts to change the cell class after the view is loaded results in a runtime error.
//- (void)testToVerifyChangingCellClassAfterViewLoadRaiseException
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    [tester waitForTimeInterval:1];
//    
//    LYRUIParticipantPickerController *controller = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeFirst];
//    [system presentModalViewController:controller configurationBlock:^(id modalViewController) {
//        [tester waitForTimeInterval:2];
//        expect(^{ [modalViewController setCellClass:[UITableView class]]; }).to.raise(NSInternalInconsistencyException);
//        [self dismissModalViewController:controller];
//    }];
//}
//
////Test that attempting to change the row height after the view is loaded results in a runtime error.
//- (void)testToVerifyChangingRowHeightAfterViewLoadRaiseException
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    [tester waitForTimeInterval:1];
//    
//    LYRUIParticipantPickerController *controller = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeFirst];
//    [system presentModalViewController:controller configurationBlock:^(id modalViewController) {
//        [tester waitForTimeInterval:2];
//        expect(^{ [modalViewController setRowHeight:80]; }).to.raise(NSInternalInconsistencyException);
//        [self dismissModalViewController:controller];
//    }];
//}
//
//- (void)testtoVerifyParticipantPickerDelegateFunctionalityForCancelButton
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    [tester waitForTimeInterval:1];
//    
//    LYRUIParticipantPickerController *controller = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeFirst];
//    id delegateMock = OCMProtocolMock(@protocol(LYRUIParticipantPickerControllerDelegate));
//    controller.participantPickerDelegate = delegateMock;
//    [system presentModalViewController:controller configurationBlock:^(id modalViewController) {
//        [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
//            //
//        }] participantSelectionViewControllerDidCancel:[OCMArg any]];
//        
//        [tester tapViewWithAccessibilityLabel:@"Cancel"];
//        [delegateMock verify];
//    }];
//}
//
//- (void)testtoVerifyParticipantPickerDelegateFunctionalityForParticipantSelection
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    [tester waitForTimeInterval:1];
//    
//    LYRUIParticipantPickerController *controller = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeFirst];
//    id delegateMock = OCMProtocolMock(@protocol(LYRUIParticipantPickerControllerDelegate));
//    controller.participantPickerDelegate = delegateMock;
//    [system presentModalViewController:controller configurationBlock:^(id modalViewController) {
//        [[[delegateMock expect] andDo:^(NSInvocation *invocation) {
//            
//            id<LYRUIParticipant> participant;
//            [invocation getArgument:&participant atIndex:3];
//            expect([participant class]).to.equal([LSUser class]);
//            [controller dismissViewControllerAnimated:true completion:nil];
//            
//        }] participantSelectionViewController:[OCMArg any] didSelectParticipant:[OCMArg any]];
//        
//        [tester tapRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableViewWithAccessibilityIdentifier:@"Participant TableView Controller"];
//        [delegateMock verify];
//    }];
//}
//
//- (void)testToVerifyParticipantPickerDataSourceFunctionality
//{
//    [self.testInterface registerAndAuthenticateUser:[LYRUITestUser testUserWithNumber:1]];
//    [tester waitForTimeInterval:1];
//    
//    LYRUIParticipantPickerController *controller = [self participantPickerControllerWithSortType:LYRUIParticipantPickerControllerSortTypeFirst];
//    [system presentModalViewController:controller configurationBlock:^(id modalViewController) {
//
//        
//    }];
//}
//
//- (LYRUIParticipantPickerController *)participantPickerControllerWithSortType:(LYRUIParticipantPickerSortType)sortType
//{
//    LSUIParticipantPickerDataSource *dataSource = [LSUIParticipantPickerDataSource participantPickerDataSourceWithPersistenceManager:self.testInterface.applicationController.persistenceManager];
//    LYRUIParticipantPickerController *controller = [LYRUIParticipantPickerController participantPickerWithDataSource:dataSource sortType:sortType];
//    return controller;
//}
//
//- (void)dismissModalViewController:(UINavigationController *)modalViewController
//{
//    [modalViewController.presentingViewController dismissViewControllerAnimated:TRUE completion:nil];
//    [tester waitForTimeInterval:1];
//}
//
//- (NSString *)selectionIndicatoraccessibilityLabelForUser:(LSUser *)testUser
//{
//    return [NSString stringWithFormat:@"%@ selected", testUser.fullName];
//}
//@end
