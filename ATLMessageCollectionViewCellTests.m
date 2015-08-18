//
//  ATLMessageCollectionViewCellTests.m
//  Atlas
//
//  Created by Kabir Mahal on 8/17/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ATLMessageCollectionViewCell.h"
#import "ATLTestUtilities.h"
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import "LYRMessageMock.h"
#import "LYRMessagePartMock.h"

@interface ATLMessageCollectionViewCell ()

@property (strong, nonatomic) LYRMessage *message;

@end

@interface ATLMessageCollectionViewCellTests : XCTestCase

@end

@implementation ATLMessageCollectionViewCellTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testThatAsynchronousImageAndGifLoadingDoesNotUpdateReusedCells
{
    ATLMessageCollectionViewCell *cell = [[ATLMessageCollectionViewCell alloc] initWithFrame:CGRectZero];
    ATLMessageBubbleView *bubbleView = cell.bubbleView;
    id partialMock = OCMPartialMock(bubbleView);
    [[[partialMock reject] ignoringNonObjectArgs] updateWithImage:[OCMArg any] width:1337];
    
    NSBundle *parentBundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [parentBundle URLForResource:@"boatgif" withExtension:@"gif"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *gif = [UIImage imageWithData:data];
    
    LYRMessagePartMock *part1 = [LYRMessagePartMock messagePartWithMIMEType:ATLMIMETypeImageGIF data:data];
    data = part1.data;
    NSDictionary *imageMetadata = @{ @"width": @(gif.size.width),
                                     @"height": @(gif.size.height),
                                     @"orientation": @(gif.imageOrientation) };
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:imageMetadata options:NSJSONWritingPrettyPrinted error:nil];
    LYRMessagePartMock *part2 = [LYRMessagePartMock messagePartWithMIMEType:ATLMIMETypeImageSize data:JSONData];
    LYRMessageMock *messageMock1 = [LYRMessageMock newMessageWithParts:@[ part1, part2 ] senderID:[ATLUserMock userWithMockUserName:ATLMockUserNameKlemen].participantIdentifier];
    LYRMessageMock *messageMock2 = [LYRMessageMock newMessageWithParts:@[ [LYRMessagePartMock messagePartWithMIMEType:@"text/plain" data:[@"test" dataUsingEncoding:NSUTF8StringEncoding]] ]  senderID:[ATLUserMock userWithMockUserName:ATLMockUserNameKlemen].participantIdentifier];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    id partialmockedPart = OCMPartialMock(part1);
    OCMStub([partialmockedPart data]).andDo(^(NSInvocation *invocation){
        NSLog(@"test");
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [invocation setReturnValue:(__bridge void *)data];
        NSLog(@"test2");
    });
    
    [cell presentMessage:messageMock1];
    //[cell presentMessage:messageMock2];
    
    dispatch_semaphore_signal(semaphore);

   [partialMock verifyWithDelay:2.0f];
}

@end
