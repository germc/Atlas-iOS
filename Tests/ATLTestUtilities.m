//
//  ATLTestUtilities.m
//  Atlas
//
//  Created by Klemen Verdnik on 2/26/15.
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

#import "ATLTestUtilities.h"

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

ALAsset *ATLAssetTestObtainLastImageFromAssetLibrary(ALAssetsLibrary *library)
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t asyncQueue = dispatch_queue_create("com.layer.ATLMediaStreamTest.ObtainLastImage.async", DISPATCH_QUEUE_CONCURRENT);
    
    __block ALAsset *sourceAsset;
    dispatch_async(asyncQueue, ^{
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (!group) {
                *stop = YES;
                dispatch_semaphore_signal(semaphore);
                return;
            }
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if ([group numberOfAssets] == 0) {
                *stop = YES;
                dispatch_semaphore_signal(semaphore);
                return;
            }
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *innerStop) {
                *innerStop = YES;
                *stop = YES;
                if (!result) {
                    return;
                }
                sourceAsset = result;
            }];
        } failureBlock:^(NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return sourceAsset;
}

ALAsset *ATLVideoAssetTestObtainLastImageFromAssetLibrary(ALAssetsLibrary *library)
{
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t asyncQueue = dispatch_queue_create("com.layer.ATLMediaStreamTest.ObtainLastImage.async", DISPATCH_QUEUE_CONCURRENT);
    
    __block ALAsset *sourceAsset;
    dispatch_async(asyncQueue, ^{
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (!group) {
                *stop = YES;
                dispatch_semaphore_signal(semaphore);
                return;
            }
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            if ([group numberOfAssets] == 0) {
                *stop = YES;
                dispatch_semaphore_signal(semaphore);
                return;
            }
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *innerStop) {
                *innerStop = YES;
                *stop = YES;
                if (!result) {
                    return;
                }
                sourceAsset = result;
            }];
        } failureBlock:^(NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return sourceAsset;
    
}

