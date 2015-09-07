//
//  ATLMessageCollectionViewCellTests.m
//  Atlas
//
//  Created by Kabir Mahal on 8/17/15.
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ATLMessageCollectionViewCell.h"
#import "ATLTestClasses.h"
#import "ATLTestUtilities.h"
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import "LYRMessageMock.h"
#import "LYRMessagePartMock.h"

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

- (void)testThatAsynchronousGifLoadingDoesNotUpdateReusedCells
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
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);

    id partialmockedPart = OCMPartialMock(part1);
    [[partialmockedPart expect] andForwardToRealObject];
    [[partialmockedPart expect] andForwardToRealObject];
    [[partialmockedPart expect] andForwardToRealObject];
    [[partialmockedPart expect] andDo:^(NSInvocation *invocation) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [invocation setReturnValue:(__bridge void *)(data)];
    }];
    [cell presentMessage:(LYRMessage *)messageMock1];
    [cell prepareForReuse];
    [cell presentMessage:(LYRMessage *)messageMock2];

    dispatch_semaphore_signal(semaphore);
    
   [partialMock verifyWithDelay:2.0f];
}

- (void)testThatAsynchronousImageLoadingDoesNotUpdateReusedCells
{
    ATLMessageCollectionViewCell *cell = [[ATLMessageCollectionViewCell alloc] initWithFrame:CGRectZero];
    ATLMessageBubbleView *bubbleView = cell.bubbleView;
    id partialMock = OCMPartialMock(bubbleView);
    [[[partialMock reject] ignoringNonObjectArgs] updateWithImage:[OCMArg any] width:1337];
    
    UIImage *image = ATLTestAttachmentMakeImageWithSize(CGSizeMake(800, 800));
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
                                                        
    LYRMessagePartMock *part1 = [LYRMessagePartMock messagePartWithMIMEType:ATLMIMETypeImageJPEG data:data];
    data = part1.data;
    NSDictionary *imageMetadata = @{ @"width": @(image.size.width),
                                     @"height": @(image.size.height),
                                     @"orientation": @(image.imageOrientation) };
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:imageMetadata options:NSJSONWritingPrettyPrinted error:nil];
    LYRMessagePartMock *part2 = [LYRMessagePartMock messagePartWithMIMEType:ATLMIMETypeImageSize data:JSONData];
    LYRMessageMock *messageMock1 = [LYRMessageMock newMessageWithParts:@[ part1, part2 ] senderID:[ATLUserMock userWithMockUserName:ATLMockUserNameKlemen].participantIdentifier];
    LYRMessageMock *messageMock2 = [LYRMessageMock newMessageWithParts:@[ [LYRMessagePartMock messagePartWithMIMEType:@"text/plain" data:[@"test" dataUsingEncoding:NSUTF8StringEncoding]] ]  senderID:[ATLUserMock userWithMockUserName:ATLMockUserNameKlemen].participantIdentifier];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    
    id partialmockedPart = OCMPartialMock(part1);
    [[partialmockedPart expect] andForwardToRealObject];
    [[partialmockedPart expect] andForwardToRealObject];
    [[partialmockedPart expect] andForwardToRealObject];
    [[partialmockedPart expect] andDo:^(NSInvocation *invocation) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [invocation setReturnValue:(__bridge void *)(data)];
    }];
    [cell presentMessage:(LYRMessage *)messageMock1];
    [cell prepareForReuse];
    [cell presentMessage:(LYRMessage *)messageMock2];
    
    dispatch_semaphore_signal(semaphore);
    
    [partialMock verifyWithDelay:2.0f];
}

@end
