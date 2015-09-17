//
//  ATLMediaAttachmentTests.m
//  Atlas
//
//  Created by Klemen Verdnik on 2/26/15.
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
#import "ATLMediaAttachment.h"
#import "ATLTestUtilities.h"
#import "ATLMediaInputStream.h"

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

@interface ATLMediaAttachmentTests : XCTestCase

@end

@implementation ATLMediaAttachmentTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testMediaAttachmentInitFailures
{
    expect(^{
        __unused ATLMediaAttachment *mediaAttachment = [[ATLMediaAttachment alloc] init];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Failed to call designated initializer. Use one of the following initialiers: mediaAttachmentWithAssetURL:thumbnailSize:, mediaAttachmentWithImage:metadata:thumbnailSize:, mediaAttachmentWithText:, mediaAttachmentWithLocation:");
    
    expect(^{
        __unused ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithAssetURL:nil thumbnailSize:0];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Cannot initialize ATLMediaAttachment with `nil` assetURL.");

    expect(^{
        __unused ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithImage:nil metadata:nil thumbnailSize:0];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Cannot initialize ATLMediaAttachment with `nil` image.");

    expect(^{
        __unused ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithText:nil];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Cannot initialize ATLMediaAttachment with `nil` text.");

    expect(^{
        __unused ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithLocation:nil];
    }).to.raiseWithReason(NSInternalInconsistencyException, @"Cannot initialize ATLMediaAttachment with `nil` location.");
}

#pragma mark Tests for Media Attachment With Text

- (void)testMediaAttachmentWithText
{
    ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithText:@"What about the Noodle Incident?"];
    
    // Verifying properties
    expect(mediaAttachment).toNot.beNil();
    expect(NSStringFromClass(mediaAttachment.class)).to.equal(@"ATLTextMediaAttachment");
    expect(mediaAttachment.textRepresentation).to.equal(@"What about the Noodle Incident?");
    expect(mediaAttachment.thumbnailSize).to.equal(0);
    expect(mediaAttachment.mediaMIMEType).to.equal(@"text/plain");
    expect(mediaAttachment.mediaInputStream).toNot.beNil();
    expect(mediaAttachment.mediaInputStream.streamStatus).to.equal(NSStreamStatusNotOpen);
    expect(mediaAttachment.thumbnailMIMEType).to.beNil();
    expect(mediaAttachment.thumbnailInputStream).to.beNil();
    expect(mediaAttachment.metadataMIMEType).to.beNil();
    expect(mediaAttachment.metadataInputStream).to.beNil();
    
    // Verifying stream content
    NSData *payload = ATLTestAttachmentDataFromStream(mediaAttachment.mediaInputStream);
    expect(payload).toNot.beNil();
    expect(payload).to.equal([@"What about the Noodle Incident?" dataUsingEncoding:NSUTF8StringEncoding]);
}

#pragma mark Tests for Media Attachment With Location

- (void)testMediaAttachmentWithLocation
{
    // Create a test location, which will be serialized.
    CLLocation *location = [[CLLocation alloc] initWithLatitude:46.368383 longitude:15.106631];
    ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithLocation:location];
    
    // Verifying properties
    expect(mediaAttachment).toNot.beNil();
    expect(NSStringFromClass(mediaAttachment.class)).to.equal(@"ATLLocationMediaAttachment");
    expect(mediaAttachment.textRepresentation).to.equal(@"Attachment: Location");
    expect(mediaAttachment.thumbnailSize).to.equal(0);
    expect(mediaAttachment.mediaMIMEType).to.equal(@"location/coordinate");
    expect(mediaAttachment.mediaInputStream).toNot.beNil();
    expect(mediaAttachment.mediaInputStream.streamStatus).to.equal(NSStreamStatusNotOpen);
    expect(mediaAttachment.thumbnailMIMEType).to.beNil();
    expect(mediaAttachment.thumbnailInputStream).to.beNil();
    expect(mediaAttachment.metadataMIMEType).to.beNil();
    expect(mediaAttachment.metadataInputStream).to.beNil();
    
    // Verifying stream content
    NSData *payload = ATLTestAttachmentDataFromStream(mediaAttachment.mediaInputStream);
    expect(payload).toNot.beNil();
    expect([NSJSONSerialization JSONObjectWithData:payload options:NSJSONReadingAllowFragments error:nil]).to.equal(@{ @"lat": @(location.coordinate.latitude), @"lon":  @(location.coordinate.longitude) });
}

#pragma mark Tests for Media Attachment With Images

/**
 @warning Make sure you allowed the XCTestCase to access the photo library.
 It's a manual process on the UI in the simulator.
 */
- (void)testMediaAttachmentWithImageFromAsset
{
    // Generate a test image and put it into the photo library.
    UIImage *image = ATLTestAttachmentMakeImageWithSize(CGSizeMake(1024, 512));
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    __block NSURL *assetURL;
    [library writeImageToSavedPhotosAlbum:image.CGImage metadata:@{ @"Orientation": @(UIImageOrientationUp) } completionBlock:^(NSURL *outAssetURL, NSError *error) {
        assetURL = outAssetURL;
    }];
    expect(assetURL).willNot.beNil();
    
    ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithAssetURL:assetURL thumbnailSize:512];

    // Verifying properties
    expect(mediaAttachment).toNot.beNil();
    expect(NSStringFromClass(mediaAttachment.class)).to.equal(@"ATLAssetMediaAttachment");
    expect(mediaAttachment.textRepresentation).to.equal(@"Attachment: Image");
    expect(mediaAttachment.thumbnailSize).to.equal(512);
    expect(mediaAttachment.mediaMIMEType).to.equal(@"image/jpeg");
    expect(mediaAttachment.mediaInputStream).toNot.beNil();
    expect(mediaAttachment.mediaInputStream.streamStatus).to.equal(NSStreamStatusNotOpen);
    expect(mediaAttachment.thumbnailMIMEType).to.equal(@"image/jpeg+preview");
    expect(mediaAttachment.thumbnailInputStream).toNot.beNil();
    expect(mediaAttachment.metadataMIMEType).to.equal(@"application/json+imageSize");
    expect(mediaAttachment.metadataInputStream).toNot.beNil();
    
    // Verifying stream content
    NSData *mediaPayload = ATLTestAttachmentDataFromStream(mediaAttachment.mediaInputStream);
    expect(mediaPayload).toNot.beNil();
    
    [mediaAttachment.mediaInputStream close];
    expect(mediaAttachment.mediaInputStream.streamError).to.beNil();
    expect(mediaAttachment.mediaInputStream.streamStatus).to.equal(NSStreamStatusClosed);
    
    UIImage *processedImage = [UIImage imageWithData:mediaPayload];
    expect(processedImage.size).to.equal(CGSizeMake(1024, 512));
    expect(processedImage.imageOrientation).to.equal(UIImageOrientationUp);
    
    NSURL *outputStreamedImageURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"streamed-image.jpeg"]];
    [[NSFileManager defaultManager] removeItemAtURL:outputStreamedImageURL error:nil];
    [mediaPayload writeToURL:outputStreamedImageURL atomically:NO];
    NSLog(@"Output file at path:'%@' length=%lu", outputStreamedImageURL.path, mediaPayload.length);

    // Verifying thumbnail content
    NSData *thumbnailPayload = ATLTestAttachmentDataFromStream(mediaAttachment.thumbnailInputStream);
    expect(thumbnailPayload).toNot.beNil();
    processedImage = [UIImage imageWithData:thumbnailPayload];
    expect(processedImage.size).to.equal(CGSizeMake(512, 256));
    expect(processedImage.imageOrientation).to.equal(UIImageOrientationUp);
    
    // Verifying image metadata JSON
    NSData *imageSizeMetadataJSON = ATLTestAttachmentDataFromStream(mediaAttachment.metadataInputStream);
    expect(imageSizeMetadataJSON).toNot.beNil();
    expect([NSJSONSerialization JSONObjectWithData:imageSizeMetadataJSON options:NSJSONReadingAllowFragments error:nil]).to.equal(@{ @"width": @1024, @"height": @512, @"orientation": @(UIImageOrientationUp) });
}

- (void)testMediaAttachmentWithImageFromMemory
{
    // Generate a test image for an in memory image streaming.
    UIImage *image = ATLTestAttachmentMakeImageWithSize(CGSizeMake(1024, 512));
    ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithImage:image metadata:@{ @"Orientation": @(UIImageOrientationUp) } thumbnailSize:512];
    
    // Verifying properties
    expect(mediaAttachment).toNot.beNil();
    expect(NSStringFromClass(mediaAttachment.class)).to.equal(@"ATLImageMediaAttachment");
    expect(mediaAttachment.textRepresentation).to.equal(@"Attachment: Image");
    expect(mediaAttachment.thumbnailSize).to.equal(512);
    expect(mediaAttachment.mediaMIMEType).to.equal(@"image/jpeg");
    expect(mediaAttachment.mediaInputStream).toNot.beNil();
    expect(mediaAttachment.mediaInputStream.streamStatus).to.equal(NSStreamStatusNotOpen);
    expect(mediaAttachment.thumbnailMIMEType).to.equal(@"image/jpeg+preview");
    expect(mediaAttachment.thumbnailInputStream).toNot.beNil();
    expect(mediaAttachment.metadataMIMEType).to.equal(@"application/json+imageSize");
    expect(mediaAttachment.metadataInputStream).toNot.beNil();
    
    // Verifying stream content
    NSData *mediaPayload = ATLTestAttachmentDataFromStream(mediaAttachment.mediaInputStream);
    expect(mediaPayload).toNot.beNil();
    
    [mediaAttachment.mediaInputStream close];
    expect(mediaAttachment.mediaInputStream.streamError).to.beNil();
    expect(mediaAttachment.mediaInputStream.streamStatus).to.equal(NSStreamStatusClosed);
    
    UIImage *processedImage = [UIImage imageWithData:mediaPayload];
    expect(processedImage.size).to.equal(CGSizeMake(1024, 512));
    expect(processedImage.imageOrientation).to.equal(UIImageOrientationUp);
    
    NSURL *outputStreamedImageURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"streamed-image.jpeg"]];
    [[NSFileManager defaultManager] removeItemAtURL:outputStreamedImageURL error:nil];
    [mediaPayload writeToURL:outputStreamedImageURL atomically:NO];
    NSLog(@"Output file at path:'%@' length=%lu", outputStreamedImageURL.path, mediaPayload.length);

    // Verifying thumbnail content
    NSData *thumbnailPayload = ATLTestAttachmentDataFromStream(mediaAttachment.thumbnailInputStream);
    expect(thumbnailPayload).toNot.beNil();
    processedImage = [UIImage imageWithData:thumbnailPayload];
    expect(processedImage.size).to.equal(CGSizeMake(512, 256));
    expect(processedImage.imageOrientation).to.equal(UIImageOrientationUp);
    
    // Verifying image metadata JSON
    NSData *imageSizeMetadataJSON = ATLTestAttachmentDataFromStream(mediaAttachment.metadataInputStream);
    expect(imageSizeMetadataJSON).toNot.beNil();
    expect([NSJSONSerialization JSONObjectWithData:imageSizeMetadataJSON options:NSJSONReadingAllowFragments error:nil]).to.equal(@{ @"width": @1024, @"height": @512, @"orientation": @(UIImageOrientationUp) });
}

- (void)testMediaAttachmentWithImageFromFile
{
    // Generate a test image at a temporary path.
    NSURL *imageFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"test-image.jpeg"]];
    [[NSFileManager defaultManager] removeItemAtURL:imageFileURL error:nil];
    UIImage *generatedTestImage = ATLTestAttachmentMakeImageWithSize(CGSizeMake(1920, 1080));
    NSData *imageData = UIImageJPEGRepresentation(generatedTestImage, 1.0);
    [imageData writeToURL:imageFileURL atomically:NO];
    expect([[NSFileManager defaultManager] fileExistsAtPath:imageFileURL.path]).to.beTruthy();
    
    //check properties of ATLMediaAttachment Object
    ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithFileURL:imageFileURL thumbnailSize:512];
    expect(mediaAttachment).toNot.beNil();
    expect(NSStringFromClass(mediaAttachment.class)).to.equal(@"ATLAssetMediaAttachment");
    expect(mediaAttachment.textRepresentation).to.equal(@"Attachment: Image");
    expect(mediaAttachment.thumbnailSize).to.equal(512);
    expect(mediaAttachment.mediaMIMEType).to.equal(@"image/jpeg");
    expect(mediaAttachment.mediaInputStream).toNot.beNil();
    expect(mediaAttachment.mediaInputStream.streamStatus).to.equal(NSStreamStatusNotOpen);
    expect(mediaAttachment.thumbnailMIMEType).to.equal(@"image/jpeg+preview");
    expect(mediaAttachment.thumbnailInputStream).toNot.beNil();
    expect(mediaAttachment.metadataMIMEType).to.equal(@"application/json+imageSize");
    expect(mediaAttachment.metadataInputStream).toNot.beNil();
    
    // Verifying stream content
    NSInputStream *stream = mediaAttachment.mediaInputStream;
    [stream open];
    expect(stream.streamStatus).to.equal(NSStreamStatusOpen);
    expect(stream.streamError).to.beNil();
    
    NSData *mediaPayload = ATLTestAttachmentDataFromStream(mediaAttachment.mediaInputStream);
    expect(mediaPayload).toNot.beNil();
    
    [stream close];
    expect(stream.streamError).to.beNil();
    expect(stream.streamStatus).to.equal(NSStreamStatusClosed);

    UIImage *processedImage = [UIImage imageWithData:mediaPayload];
    expect(processedImage.size).to.equal(CGSizeMake(1920, 1080));
    expect(processedImage.imageOrientation).to.equal(UIImageOrientationUp);
    
    NSURL *outputStreamedImageURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"streamed-image.jpeg"]];
    [[NSFileManager defaultManager] removeItemAtURL:outputStreamedImageURL error:nil];
    [mediaPayload writeToURL:outputStreamedImageURL atomically:NO];
    NSLog(@"Output file at path:'%@' length=%lu", outputStreamedImageURL.path, mediaPayload.length);
    
    // Verifying thumbnail content
    NSData *thumbnailPayload = ATLTestAttachmentDataFromStream(mediaAttachment.thumbnailInputStream);
    expect(thumbnailPayload).toNot.beNil();
    processedImage = [UIImage imageWithData:thumbnailPayload];
    expect(processedImage.size).to.equal(CGSizeMake(512, 288));
    expect(processedImage.imageOrientation).to.equal(UIImageOrientationUp);
    
    // Verifying image metadata JSON
    NSData *imageSizeMetadataJSON = ATLTestAttachmentDataFromStream(mediaAttachment.metadataInputStream);
    expect(imageSizeMetadataJSON).toNot.beNil();
    expect([NSJSONSerialization JSONObjectWithData:imageSizeMetadataJSON options:NSJSONReadingAllowFragments error:nil]).to.equal(@{ @"width": @1920, @"height": @1080, @"orientation": @(UIImageOrientationUp) });
}

#pragma mark Tests for Media Attachment With Videos

/**
 @warning Make sure you allowed the XCTestCase to access the photo library.
   It's a manual process on the UI in the simulator.
 */
- (void)testMediaAttachmentWithVideoFromAsset
{
    // Generate a test video and put in into the library.
    NSURL *videoFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temporary-test-video.mov"]];
    BOOL success = ATLTestMakeVideo(videoFileURL, CGSizeMake(1280, 720), 30, 2);
    expect(success).to.beTruthy();
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    __block NSURL *assetURL;
    [library writeVideoAtPathToSavedPhotosAlbum:videoFileURL completionBlock:^(NSURL *outAssetURL, NSError *error) {
        assetURL = outAssetURL;
    }];
    expect(assetURL).willNot.beNil();
    
    // Get Last Video
    ALAsset *sourceAsset = ATLVideoAssetTestObtainLastVideoFromAssetLibrary(library);
    expect(sourceAsset).toNot.beNil();
    NSURL *lastVideoURL = sourceAsset.defaultRepresentation.url;
    
    //check properties of ATLMediaAttachment Object
    ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithAssetURL:lastVideoURL thumbnailSize:512];
    expect(mediaAttachment).toNot.beNil();
    expect(NSStringFromClass(mediaAttachment.class)).to.equal(@"ATLAssetMediaAttachment");
    expect(mediaAttachment.textRepresentation).to.equal(@"Attachment: Video");
    expect(mediaAttachment.thumbnailSize).to.equal(512);
    expect(mediaAttachment.mediaMIMEType).to.equal(@"video/mp4");
    expect(mediaAttachment.mediaInputStream).toNot.beNil();
    expect(mediaAttachment.mediaInputStream.streamStatus).to.equal(NSStreamStatusNotOpen);
    expect(mediaAttachment.thumbnailMIMEType).to.equal(@"image/jpeg+preview");
    expect(mediaAttachment.thumbnailInputStream).toNot.beNil();
    expect(mediaAttachment.metadataMIMEType).to.equal(@"application/json+imageSize");
    expect(mediaAttachment.metadataInputStream).toNot.beNil();
    
    // Verifying stream content
    NSInputStream *stream = mediaAttachment.mediaInputStream;
    [stream open];
    expect(stream.streamStatus).to.equal(NSStreamStatusOpen);
    expect(stream.streamError).to.beNil();
    
    NSData *mediaPayload = ATLTestAttachmentDataFromStream(mediaAttachment.mediaInputStream);
    [stream close];
    expect(stream.streamError).to.beNil();
    expect(stream.streamStatus).to.equal(NSStreamStatusClosed);
    expect(mediaPayload).toNot.beNil();
    expect(mediaPayload.length).to.beGreaterThan(0);
    
    NSURL *outputStreamedVideoURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"streamed-video.mp4"]];
    [[NSFileManager defaultManager] removeItemAtURL:outputStreamedVideoURL error:nil];
    [mediaPayload writeToURL:outputStreamedVideoURL atomically:NO];
    NSLog(@"Output file at path:'%@' length=%lu", outputStreamedVideoURL.path, mediaPayload.length);

    // Verifying thumbnail content
    NSData *thumbnailPayload = ATLTestAttachmentDataFromStream(mediaAttachment.thumbnailInputStream);
    expect(thumbnailPayload).toNot.beNil();
    UIImage *processedImage = [UIImage imageWithData:thumbnailPayload];
    expect(processedImage.size).toNot.beNil();
    expect(processedImage.size).to.equal(CGSizeMake(512, 288));
    expect(processedImage.imageOrientation).to.equal(UIImageOrientationUp);
    
    // Verifying image metadata JSON
    NSData *videoSizeMetadataJSON = ATLTestAttachmentDataFromStream(mediaAttachment.metadataInputStream);
    expect(videoSizeMetadataJSON).toNot.beNil();
    expect([NSJSONSerialization JSONObjectWithData:videoSizeMetadataJSON options:NSJSONReadingAllowFragments error:nil]).to.equal(@{ @"width": @1280, @"height": @720, @"orientation": @(UIImageOrientationUp) });
}

- (void)testMediaAttachmentWithVideoFromFile
{
    // Generate a test video and put in into the library.
    NSURL *videoFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temporary-test-video.mov"]];
    BOOL success = ATLTestMakeVideo(videoFileURL, CGSizeMake(1280, 720), 30, 2);
    expect(success).to.beTruthy();
    
    // Check properties of ATLMediaAttachment Object
    ATLMediaAttachment *mediaAttachment = [ATLMediaAttachment mediaAttachmentWithFileURL:videoFileURL thumbnailSize:512];
    expect(mediaAttachment).toNot.beNil();
    expect(NSStringFromClass(mediaAttachment.class)).to.equal(@"ATLAssetMediaAttachment");
    expect(mediaAttachment.textRepresentation).to.equal(@"Attachment: Video");
    expect(mediaAttachment.thumbnailSize).to.equal(512);
    expect(mediaAttachment.mediaMIMEType).to.equal(@"video/mp4");
    expect(mediaAttachment.mediaInputStream).toNot.beNil();
    expect(mediaAttachment.mediaInputStream.streamStatus).to.equal(NSStreamStatusNotOpen);
    expect(mediaAttachment.thumbnailMIMEType).to.equal(@"image/jpeg+preview");
    expect(mediaAttachment.thumbnailInputStream).toNot.beNil();
    expect(mediaAttachment.metadataMIMEType).to.equal(@"application/json+imageSize");
    expect(mediaAttachment.metadataInputStream).toNot.beNil();
    
    // Verifying stream content
    NSInputStream *stream = mediaAttachment.mediaInputStream;
    [stream open];
    expect(stream.streamStatus).to.equal(NSStreamStatusOpen);
    expect(stream.streamError).to.beNil();
    
    NSData *mediaPayload = ATLTestAttachmentDataFromStream(mediaAttachment.mediaInputStream);
    [stream close];
    expect(stream.streamError).to.beNil();
    expect(stream.streamStatus).to.equal(NSStreamStatusClosed);
    expect(mediaPayload).toNot.beNil();
    expect(mediaPayload.length).to.beGreaterThan(0);
    
    NSURL *outputStreamedVideoURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"streamed-video.mp4"]];
    [[NSFileManager defaultManager] removeItemAtURL:outputStreamedVideoURL error:nil];
    [mediaPayload writeToURL:outputStreamedVideoURL atomically:NO];
    NSLog(@"Output file at path:'%@' length=%lu", outputStreamedVideoURL.path, mediaPayload.length);
    
    // Verifying thumbnail content
    NSData *thumbnailPayload = ATLTestAttachmentDataFromStream(mediaAttachment.thumbnailInputStream);
    expect(thumbnailPayload).toNot.beNil();
    UIImage *processedImage = [UIImage imageWithData:thumbnailPayload];
    expect(processedImage.size).toNot.beNil();
    expect(processedImage.size).to.equal(CGSizeMake(512, 288));
    expect(processedImage.imageOrientation).to.equal(UIImageOrientationUp);
    
    // Verifying image metadata JSON
    NSData *videoSizeMetadataJSON = ATLTestAttachmentDataFromStream(mediaAttachment.metadataInputStream);
    expect(videoSizeMetadataJSON).toNot.beNil();
    expect([NSJSONSerialization JSONObjectWithData:videoSizeMetadataJSON options:NSJSONReadingAllowFragments error:nil]).to.equal(@{ @"width": @1280, @"height": @720, @"orientation": @(UIImageOrientationRight) });
}

@end
