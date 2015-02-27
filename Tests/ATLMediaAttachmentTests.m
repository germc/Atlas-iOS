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

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

/**
 @abstract Reads the stream content into a NSData object.
 @param inputStream Input stream to read the content from.
 @return Returns an `NSData` object containing the content of the stream; or `nil` in case of an error.
 */
NSData *ATLTestAttachmentDataFromStream(NSInputStream *inputStream);

/**
 @abstract Generates a test image with the given size.
 @param size The size of the output image.
 @return An `UIImage` instance.
 */
UIImage *ATLTestAttachmentMakeImageWithSize(CGSize size);

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

- (void)testMediaAttachmentWithLocation
{
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
    expect(payload).to.equal([NSJSONSerialization dataWithJSONObject:@{ @"lat": @(location.coordinate.latitude), @"lon":  @(location.coordinate.longitude) }  options:0 error:nil]);
}

- (void)testMediaWithImage
{
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
    UIImage *processedImage = [UIImage imageWithData:mediaPayload];
    expect(processedImage.size).to.equal(CGSizeMake(1024, 512));
    expect(processedImage.imageOrientation).to.equal(UIImageOrientationUp);

    // Verifying thumbnail content
    NSData *thumbnailPayload = ATLTestAttachmentDataFromStream(mediaAttachment.thumbnailInputStream);
    expect(thumbnailPayload).toNot.beNil();
    processedImage = [UIImage imageWithData:thumbnailPayload];
    expect(processedImage.size).to.equal(CGSizeMake(512, 256));
    expect(processedImage.imageOrientation).to.equal(UIImageOrientationUp);
    
    // Verifying image metadata JSON
    NSData *imageSizeMetadataJSON = ATLTestAttachmentDataFromStream(mediaAttachment.metadataInputStream);
    expect(imageSizeMetadataJSON).toNot.beNil();
    expect(imageSizeMetadataJSON).to.equal([NSJSONSerialization dataWithJSONObject:@{ @"width":@1024, @"height":@512, @"orientation":@(UIImageOrientationUp) } options:NSJSONWritingPrettyPrinted error:nil]);
}

- (void)testMediaWithAsset
{
    UIImage *image = ATLTestAttachmentMakeImageWithSize(CGSizeMake(1024, 512));

    // First, save the generated image to the album.
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
    UIImage *processedImage = [UIImage imageWithData:mediaPayload];
    expect(processedImage.size).to.equal(CGSizeMake(1024, 512));
    expect(processedImage.imageOrientation).to.equal(UIImageOrientationUp);
    
    // Verifying thumbnail content
    NSData *thumbnailPayload = ATLTestAttachmentDataFromStream(mediaAttachment.thumbnailInputStream);
    expect(thumbnailPayload).toNot.beNil();
    processedImage = [UIImage imageWithData:thumbnailPayload];
    expect(processedImage.size).to.equal(CGSizeMake(512, 256));
    expect(processedImage.imageOrientation).to.equal(UIImageOrientationUp);
    
    // Verifying image metadata JSON
    NSData *imageSizeMetadataJSON = ATLTestAttachmentDataFromStream(mediaAttachment.metadataInputStream);
    expect(imageSizeMetadataJSON).toNot.beNil();
    expect(imageSizeMetadataJSON).to.equal([NSJSONSerialization dataWithJSONObject:@{ @"width":@1024, @"height":@512, @"orientation":@(UIImageOrientationUp) } options:NSJSONWritingPrettyPrinted error:nil]);
}

@end

#pragma mark - Test utilities

NSData *ATLTestAttachmentDataFromStream(NSInputStream *inputStream)
{
    if (!inputStream) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"inputStream cannot be `nil`." userInfo:nil];
    }
    NSMutableData *dataFromStream = [NSMutableData data];
    
    // Open stream
    [inputStream open];
    if (inputStream.streamError) {
        NSLog(@"Failed to stream image content with %@", inputStream.streamError);
        return nil;
    }
    
    // Start streaming
    const NSUInteger bufferSize = 1024;
    uint8_t *buffer = malloc(bufferSize);
    NSUInteger bytesRead;
    do {
        bytesRead = [inputStream read:buffer maxLength:(unsigned long)bufferSize];
        if (bytesRead != 0) {
            [dataFromStream appendBytes:buffer length:bytesRead];
        }
    } while (bytesRead != 0);
    free(buffer);
    
    // Close stream
    [inputStream close];
    
    // Done
    return dataFromStream;
}

UIImage *ATLTestAttachmentMakeImageWithSize(CGSize imageSize)
{
    CGFloat scaleFactor;
    CGFloat xOffset = 0.0f;
    CGFloat yOffset = 15.0f;
    if (imageSize.width >= imageSize.height) {
        scaleFactor = imageSize.height / 285;
        xOffset = (imageSize.width / 2) - (580 / 2 * scaleFactor);
    } else {
        scaleFactor = imageSize.width / 580;
        yOffset *= scaleFactor;
        yOffset += (imageSize.height / 2) - (285 / 2 * scaleFactor);
    }
    
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, xOffset, yOffset);
    CGContextScaleCTM(context, scaleFactor, scaleFactor);
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path setMiterLimit:4];
    [[UIColor blackColor] setFill];
    [path moveToPoint:CGPointMake(152.64, 175.83)];
    [path addCurveToPoint:CGPointMake(143.64, 184.82) controlPoint1:CGPointMake(152.64, 180.7) controlPoint2:CGPointMake(148.52, 184.82)];
    [path addLineToPoint:CGPointMake(120.88, 184.82)];
    [path addCurveToPoint:CGPointMake(41.18, 105.13) controlPoint1:CGPointMake(72.94, 184.82) controlPoint2:CGPointMake(41.18, 153.06)];
    [path addLineToPoint:CGPointMake(41.18, 82.36)];
    [path addCurveToPoint:CGPointMake(50.17, 73.37) controlPoint1:CGPointMake(41.18, 77.48) controlPoint2:CGPointMake(45.3, 73.37)];
    [path addLineToPoint:CGPointMake(143.64, 73.37)];
    [path addCurveToPoint:CGPointMake(152.64, 82.36) controlPoint1:CGPointMake(148.52, 73.37) controlPoint2:CGPointMake(152.64, 77.48)];
    [path addLineToPoint:CGPointMake(152.64, 175.83)];
    [path closePath];
    [path moveToPoint:CGPointMake(143.64, 57.19)];
    [path addLineToPoint:CGPointMake(50.17, 57.19)];
    [path addCurveToPoint:CGPointMake(25, 82.36) controlPoint1:CGPointMake(36.32, 57.19) controlPoint2:CGPointMake(25, 68.51)];
    [path addLineToPoint:CGPointMake(25, 175.83)];
    [path addCurveToPoint:CGPointMake(50.17, 201) controlPoint1:CGPointMake(25, 189.67) controlPoint2:CGPointMake(36.32, 201)];
    [path addLineToPoint:CGPointMake(143.64, 201)];
    [path addCurveToPoint:CGPointMake(168.81, 175.83) controlPoint1:CGPointMake(157.49, 201) controlPoint2:CGPointMake(168.81, 189.67)];
    [path addLineToPoint:CGPointMake(168.81, 82.36)];
    [path addCurveToPoint:CGPointMake(143.64, 57.19) controlPoint1:CGPointMake(168.81, 68.51) controlPoint2:CGPointMake(157.49, 57.19)];
    [path closePath];
    [path fill];
    
    CGRect frame = CGRectMake(178, 36.5, 504, 190);
    NSString* text = [NSString stringWithFormat:@"%c%c%c%c%c", 76, 97, 121, 101, 114];
    UIFont* font = [UIFont systemFontOfSize: 155];
    [UIColor.blackColor setFill];
    CGFloat height = frame.size.height;
    [text drawInRect:CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame) + (CGRectGetHeight(frame) - height) / 2, CGRectGetWidth(frame), height) withAttributes:@{ NSFontAttributeName: font }];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
