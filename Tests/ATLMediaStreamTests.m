//
//  ATLMediaStreamTests.m
//  Atlas
//
//  Created by Klenen Verdnik on 2/13/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
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
#import "ATLMediaInputStream.h"
#import "ATLTestUtilities.h"

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

@interface ATLMediaInputStreamTest : XCTestCase

@end

@implementation ATLMediaInputStreamTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

//Unit test for sending a video across
- (void)testInputMediaStreamForVideo
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAsset *VideoSourceAsset = ATLVideoAssetTestObtainLastImageFromAssetLibrary(library);
    expect(VideoSourceAsset).toNot.beNil();
    
    NSURL *LastVideoURL = VideoSourceAsset.defaultRepresentation.url;
    //Video Length
    ALAssetRepresentation *rep = [VideoSourceAsset defaultRepresentation];
    Byte *buffer1 = (Byte*)malloc(rep.size);
    NSError *error = nil;
    NSUInteger buffered = [rep getBytes:buffer1 fromOffset:0.0 length:rep.size error:&error];
    NSData *data1 = [NSData dataWithBytesNoCopy:buffer1 length:buffered freeWhenDone:YES];
    NSLog(@"Size of video %lu",(unsigned long)data1.length);
    
    ATLMediaInputStream *stream = [ATLMediaInputStream mediaInputStreamWithAssetURL:LastVideoURL];
    
    [stream open];
    expect(stream.streamStatus).to.equal(NSStreamStatusOpen);
    expect(stream.streamError).to.beNil();
    
    NSMutableData *data = [NSMutableData data];
    NSUInteger sizeOfBuffer = 512 * 1024;
    NSUInteger sizeOfRead = 512*1024;
    uint8_t *buffer = malloc(sizeOfBuffer);
    NSInteger bytesRead = 0;
    do {
        bytesRead = [stream read:buffer maxLength:sizeOfRead];
        expect(stream.streamError).to.beNil();
        [data appendBytes:buffer length:bytesRead];
    } while (bytesRead > 0);
    free(buffer);
    
    expect(stream.streamStatus).to.equal(NSStreamStatusAtEnd);
    [stream close];
    expect(stream.streamStatus).to.equal(NSStreamStatusClosed);
    expect(stream.streamError).to.beNil();
    
    NSString *path = [NSString stringWithFormat:@"%@test.mp4", NSTemporaryDirectory()];
    [data writeToFile:path atomically:NO];
    NSLog(@"check file: %@ length=%lu", path, data.length);
}

- (void)testMediaStreamDesignatedInitFails
{
    expect(^{
        __unused ATLMediaInputStream *streamDirect = [[ATLMediaInputStream alloc] init];
    }).to.raise(NSInternalInconsistencyException);
}

- (void)testMediaStreamOpensStream
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAsset *sourceAsset = ATLAssetTestObtainLastImageFromAssetLibrary(library);
    expect(sourceAsset).toNot.beNil();
    
    NSURL *lastImageURL = sourceAsset.defaultRepresentation.url;
    
    ATLMediaInputStream *streamDirect = [ATLMediaInputStream mediaInputStreamWithAssetURL:lastImageURL];
    expect(streamDirect.isLossless).to.beTruthy();
    expect(streamDirect.streamStatus).to.equal(NSStreamStatusNotOpen);
    expect(streamDirect.streamError).to.beNil();
    [streamDirect open];
    expect(streamDirect.streamStatus).to.equal(NSStreamStatusOpen);
    expect(streamDirect.streamError).to.beNil();
    
    ATLMediaInputStream *streamResample = [ATLMediaInputStream mediaInputStreamWithAssetURL:lastImageURL];
    streamResample.maximumSize = 512;
    streamResample.compressionQuality = 0.5f;
    expect(streamResample.isLossless).to.beFalsy();
    expect(streamResample.streamStatus).to.equal(NSStreamStatusNotOpen);
    expect(streamResample.streamError).to.beNil();
    [streamResample open];
    expect(streamResample.streamStatus).to.equal(NSStreamStatusOpen);
    expect(streamResample.streamError).to.beNil();
}

- (void)testMediaStreamClosesStream
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAsset *sourceAsset = ATLAssetTestObtainLastImageFromAssetLibrary(library);
    expect(sourceAsset).toNot.beNil();
    
    NSURL *lastImageURL = sourceAsset.defaultRepresentation.url;
    
    ATLMediaInputStream *streamDirect = [ATLMediaInputStream mediaInputStreamWithAssetURL:lastImageURL];
    expect(streamDirect.streamStatus).to.equal(NSStreamStatusNotOpen);
    expect(streamDirect.streamError).to.beNil();
    [streamDirect open];
    expect(streamDirect.streamStatus).to.equal(NSStreamStatusOpen);
    expect(streamDirect.streamError).to.beNil();
    [streamDirect close];
    expect(streamDirect.streamStatus).to.equal(NSStreamStatusClosed);
    expect(streamDirect.streamError).to.beNil();
    
    ATLMediaInputStream *streamResample = [ATLMediaInputStream mediaInputStreamWithAssetURL:lastImageURL];
    streamResample.maximumSize = 512;
    streamResample.compressionQuality = 0.5f;
    expect(streamResample.streamStatus).to.equal(NSStreamStatusNotOpen);
    expect(streamResample.streamError).to.beNil();
    [streamResample open];
    expect(streamResample.streamStatus).to.equal(NSStreamStatusOpen);
    expect(streamResample.streamError).to.beNil();
    [streamResample close];
    expect(streamResample.streamStatus).to.equal(NSStreamStatusClosed);
    expect(streamResample.streamError).to.beNil();
}

- (void)testMediaStreamReadsStreamRenameMe
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAsset *sourceAsset = ATLAssetTestObtainLastImageFromAssetLibrary(library);
    expect(sourceAsset).toNot.beNil();
    
    NSURL *lastImageURL = sourceAsset.defaultRepresentation.url;
    
    ATLMediaInputStream *stream = [ATLMediaInputStream mediaInputStreamWithAssetURL:lastImageURL];
    [stream open];
    expect(stream.streamStatus).to.equal(NSStreamStatusOpen);
    expect(stream.streamError).to.beNil();
    
    NSMutableData *data = [NSMutableData data];
    NSUInteger size = 512 * 1024;
    uint8_t *buffer = malloc(size);
    NSInteger bytesRead = 0;
    do {
        bytesRead = [stream read:buffer maxLength:size];
        expect(stream.streamError).to.beNil();
        [data appendBytes:buffer length:bytesRead];
    } while (bytesRead > 0);
    free(buffer);
    
    expect(stream.streamStatus).to.equal(NSStreamStatusAtEnd);
    [stream close];
    expect(stream.streamStatus).to.equal(NSStreamStatusClosed);
    expect(stream.streamError).to.beNil();
    
    NSString *path = [NSString stringWithFormat:@"%@test.jpeg", NSTemporaryDirectory()];
    [data writeToFile:path atomically:NO];
    NSLog(@"check file: %@ length=%lu", path, data.length);
}

- (void)testMediaStreamReadsStreamFromDifferentThread
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    ALAsset *sourceAsset = ATLAssetTestObtainLastImageFromAssetLibrary(library);
    
    expect(sourceAsset).toNot.beNil();
    
    NSURL *lastImageURL = sourceAsset.defaultRepresentation.url;
    
    ATLMediaInputStream *stream = [ATLMediaInputStream mediaInputStreamWithAssetURL:lastImageURL];
    [stream open];
    expect(stream.streamStatus).to.equal(NSStreamStatusOpen);
    expect(stream.streamError).to.beNil();
    
    NSMutableData *data = [NSMutableData data];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        NSUInteger size = 512 * 1024;
        uint8_t *buffer = malloc(size);
        NSInteger bytesRead = 0;
        do {
            bytesRead = [stream read:buffer maxLength:size];
            expect(stream.streamError).to.beNil();
            [data appendBytes:buffer length:bytesRead];
        } while (bytesRead > 0);
        free(buffer);
        expect(stream.streamStatus).to.equal(NSStreamStatusAtEnd);
        [stream close];
    });
    
    expect(stream.streamStatus).will.equal(NSStreamStatusClosed);
    expect(stream.streamError).to.beNil();
    
    NSString *path = [NSString stringWithFormat:@"%@test.jpeg", NSTemporaryDirectory()];
    [data writeToFile:path atomically:NO];
    NSLog(@"check file: %@ length=%lu", path, data.length);
}

@end
