//
//  ATLUIMessagingUtilities.m
//  Atlas
//
//  Created by Kevin Coleman on 10/27/14.
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

#import "ATLMessagingUtilities.h"
#import "ATLErrors.h"
#import <AssetsLibrary/AssetsLibrary.h>

NSString *const ATLMIMETypeTextPlain = @"text/plain";
NSString *const ATLMIMETypeTextHTML = @"text/HTML";
NSString *const ATLMIMETypeImagePNG = @"image/png";
NSString *const ATLMIMETypeImageSize = @"application/json+imageSize";
NSString *const ATLMIMETypeImageJPEG = @"image/jpeg";
NSString *const ATLMIMETypeImageJPEGPreview = @"image/jpeg+preview";
NSString *const ATLMIMETypeLocation = @"location/coordinate";
NSString *const ATLMIMETypeDate = @"text/date";

NSUInteger const LYRUIThumbnailSize = 512;

NSString *const ATLImagePreviewWidthKey = @"width";
NSString *const ATLImagePreviewHeightKey = @"height";
NSString *const ATLLocationLatitudeKey = @"lat";
NSString *const ATLLocationLongitudeKey = @"lon";

#pragma mark - Max Cell Dimensions

CGFloat ATLMaxCellWidth()
{
    return 220;
}

CGFloat ATLMaxCellHeight()
{
    return 300;
}

#pragma mark - Private Image Utilities

CGSize ATLSizeProportionallyConstrainedToSize(CGSize nativeSize, CGSize maxSize)
{
    CGSize itemSize;
    CGFloat widthScale = maxSize.width / nativeSize.width;
    CGFloat heightScale = maxSize.height / nativeSize.height;
    if (heightScale < widthScale) {
        itemSize = CGSizeMake(nativeSize.width * heightScale, maxSize.height);
    } else {
        itemSize = CGSizeMake(maxSize.width, nativeSize.height * widthScale);
    }
    return itemSize;
}

UIImage *ATLAdjustOrientationForImage(UIImage *originalImage)
{
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, originalImage.scale);
    [originalImage drawInRect:(CGRect){0, 0, originalImage.size}];
    UIImage *fixedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fixedImage;
}

#pragma mark - Image Utilities

CGSize ATLImageSizeForData(NSData *data)
{
    UIImage *image = [UIImage imageWithData:data];
    return ATLImageSize(image);
}

CGSize ATLImageSizeForJSONData(NSData *data)
{
    NSDictionary *sizeDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    CGFloat width = [sizeDictionary[ATLImagePreviewWidthKey] floatValue];
    CGFloat height = [sizeDictionary[ATLImagePreviewHeightKey] floatValue];
    return CGSizeMake(width, height);
}

CGSize ATLImageSize(UIImage *image)
{
    CGSize maxSize = CGSizeMake(ATLMaxCellWidth(), ATLMaxCellHeight());
    CGSize itemSize = ATLSizeProportionallyConstrainedToSize(image.size, maxSize);
    return itemSize;
}

CGSize ATLTextPlainSize(NSString *text, UIFont *font)
{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(ATLMaxCellWidth(), CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: font}
                                     context:nil];
    return rect.size;
}

CGRect ATLImageRectConstrainedToSize(CGSize imageSize, CGSize maxSize)
{
    CGSize itemSize = ATLSizeProportionallyConstrainedToSize(imageSize, maxSize);
    CGRect thumbRect = {0, 0, itemSize};
    return thumbRect;
}

#pragma mark - Private Message Part Helpers

NSData *ATLJPEGDataForImageWithConstraint(UIImage *image, CGFloat constraint, CGFloat quality)
{
    NSData *pngData = UIImagePNGRepresentation(image);
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)pngData, NULL);
    CGImageRef resizedImage = CGImageSourceCreateThumbnailAtIndex(source, 0, (CFDictionaryRef)@{ (NSString *)kCGImageSourceThumbnailMaxPixelSize: @(constraint),
                                                                                                 (NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent: @(YES) });
    UIImage *resizedUIImage = [UIImage imageWithCGImage:resizedImage];
    return UIImageJPEGRepresentation(resizedUIImage, quality);
}

CGSize  ATLSizeFromOriginalSizeWithConstraint(CGSize originalSize, CGFloat constraint)
{
    if (originalSize.height > constraint && (originalSize.height > originalSize.width)) {
        CGFloat heightRatio = constraint / originalSize.height;
        return CGSizeMake(originalSize.width * heightRatio, constraint);
    } else if (originalSize.width > constraint) {
        CGFloat widthRatio = constraint / originalSize.width;
        return CGSizeMake(constraint, originalSize.height * widthRatio);
    }
    return originalSize;
}

#pragma mark - Message Parts Constructors

LYRMessagePart *ATLMessagePartWithText(NSString *text)
{
    return [LYRMessagePart messagePartWithMIMEType:@"text/plain" data:[text dataUsingEncoding:NSUTF8StringEncoding]];
}

LYRMessagePart *ATLMessagePartWithJPEGImage(UIImage *image)
{
    UIImage *adjustedImage = ATLAdjustOrientationForImage(image);
    NSData *imageData = ATLJPEGDataForImageWithConstraint(adjustedImage, 768, 0.8f);
    return [LYRMessagePart messagePartWithMIMEType:ATLMIMETypeImageJPEG
                                              data:imageData];
}

LYRMessagePart *ATLMessagePartForImageSize(UIImage *image)
{
    CGSize size = ATLImageSize(image);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{ATLImagePreviewWidthKey : @(size.width), ATLImagePreviewHeightKey : @(size.height)}
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    return [LYRMessagePart messagePartWithMIMEType:ATLMIMETypeImageSize data:jsonData];
}

LYRMessagePart *ATLMessagePartWithLocation(CLLocation *location)
{
    NSNumber *lat = @(location.coordinate.latitude);
    NSNumber *lon = @(location.coordinate.longitude);
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ATLLocationLatitudeKey: lat, ATLLocationLongitudeKey: lon} options:0 error:nil];
    return [LYRMessagePart messagePartWithMIMEType:ATLMIMETypeLocation data:data];
}

#pragma mark - Image Capture Utilities

void ATLLastPhotoTaken(void(^completionHandler)(UIImage *image, NSError *error))
{
    // Credit goes to @iBrad Apps on Stack Overflow
    // http://stackoverflow.com/questions/8867496/get-last-image-from-photos-app
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        // When done, the group enumeration block is called another time with group set to nil.
        if (!group) return;

        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];

        if ([group numberOfAssets] == 0) {
            completionHandler(nil, [NSError errorWithDomain:ATLErrorDomain code:ATLErrorNoPhotos userInfo:@{NSLocalizedDescriptionKey: @"There are no photos."}]);
            return;
        }
        
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *innerStop) {
            // When done, the asset enumeration block is called another time with result set to nil.
            if (!result) return;

            ALAssetRepresentation *representation = [result defaultRepresentation];
            UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
            
            // Stop the enumerations
            *innerStop = YES;
            *stop = YES;
            completionHandler(latestPhoto, nil);
        }];
    } failureBlock:^(NSError *error) {
        completionHandler(nil, error);
    }];
}

UIImage *ATLPinPhotoForSnapshot(MKMapSnapshot *snapshot, CLLocationCoordinate2D location)
{
    // Create a pin image.
    MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
    UIImage *pinImage = pin.image;
    
    // Draw the image.
    UIImage *image = snapshot.image;
    UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
    [image drawAtPoint:CGPointMake(0, 0)];
    
    // Draw the pin.
    CGPoint point = [snapshot pointForCoordinate:location];
    [pinImage drawAtPoint:CGPointMake(point.x, point.y - pinImage.size.height)];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

NSArray *ATLLinkResultsForText(NSString *text)
{
    if (!text) return nil;
    
    NSError *error;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                               error:&error];
    if (error) return nil;
    return [detector matchesInString:text options:kNilOptions range:NSMakeRange(0, text.length)];
}
