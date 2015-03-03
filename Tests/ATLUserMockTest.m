//
//  ATLUserMockTest.m
//  Atlas
//
//  Created by Kabir Mahal on 3/2/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ATLTestInterface.h"
#import "ATLSampleConversationViewController.h"

@interface ATLUserMockTest : XCTestCase

@end

@implementation ATLUserMockTest

- (void)testToVerifyCaseInsensitiveSearch
{
    NSSet *set1 = [ATLUserMock participantsWithText:@"Kleme"];
    NSString *fullName1 = ((ATLUserMock*)set1.allObjects.firstObject).fullName;
    expect(fullName1).to.equal([ATLUserMock userWithMockUserName:ATLMockUserNameKlemen].fullName);
    
    NSSet *set2 = [ATLUserMock participantsWithText:@"kleme"];
    NSString *fullName2 = ((ATLUserMock*)set2.allObjects.firstObject).fullName;
    expect(fullName2).to.equal([ATLUserMock userWithMockUserName:ATLMockUserNameKlemen].fullName);

    NSSet *set3 = [ATLUserMock participantsWithText:@"bob"];
    NSString *fullName3 = ((ATLUserMock*)set3.allObjects.firstObject).fullName;
    expect(fullName3).toNot.equal([ATLUserMock userWithMockUserName:ATLMockUserNameKlemen].fullName);
}

@end
