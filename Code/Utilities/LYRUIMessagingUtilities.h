//
//  LYRUIMessagingUtilities.h
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

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import <MapKit/MapKit.h>
#import <ImageIO/ImageIO.h>

extern NSString *const LYRUIMIMETypeTextPlain;          // text/plain
extern NSString *const LYRUIMIMETypeImagePNG;           // image/png
extern NSString *const LYRUIMIMETypeImageJPEG;          // image/jpeg
extern NSString *const LYRUIMIMETypeImageJPEGPreview;   // image/jpeg+preview
extern NSString *const LYRUIMIMETypeImageSize;          // application/json+imageSize
extern NSString *const LYRUIMIMETypeLocation;           // location/coordinate
extern NSString *const LYRUIMIMETypeDate;               // text/date

extern NSString *const LYRUIImagePreviewWidthKey;
extern NSString *const LYRUIImagePreviewHeightKey;
extern NSString *const LYRUILocationLatitudeKey;
extern NSString *const LYRUILocationLongitudeKey;

//****************************
// Max Cell Dimensions
//****************************

CGFloat LYRUIMaxCellWidth();

CGFloat LYRUIMaxCellHeight();

//****************************
// Image Utilities
//****************************

CGSize LYRUIImageSizeForData(NSData *data);

CGSize LYRUIImageSizeForJSONData(NSData *data);

CGSize LYRUIImageSize(UIImage *image);

CGSize LYRUITextPlainSize(NSString *string, UIFont *font);

CGRect LYRUIImageRectConstrainedToSize(CGSize imageSize, CGSize maxSize);

//****************************
// Message Part Constructors
//****************************

LYRMessagePart *LYRUIMessagePartWithText(NSString *text);

LYRMessagePart *LYRUIMessagePartWithJPEGImage(UIImage *image);

LYRMessagePart *LYRUIMessagePartForImageSize(UIImage *image);

LYRMessagePart *LYRUIMessagePartWithLocation(CLLocation *location);

//****************************
// Image Capture Utilities
//****************************

void LYRUILastPhotoTaken(void(^completionHandler)(UIImage *image, NSError *error));

UIImage *LYRUIPinPhotoForSnapshot(MKMapSnapshot *snapshot, CLLocationCoordinate2D location);

NSArray *LYRUILinkResultsForText(NSString *text);