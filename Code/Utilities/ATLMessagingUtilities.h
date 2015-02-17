//
//  ATLUIMessagingUtilities.h
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

extern NSString *const ATLMIMETypeTextPlain;          // text/plain
extern NSString *const ATLMIMETypeImagePNG;           // image/png
extern NSString *const ATLMIMETypeImageJPEG;          // image/jpeg
extern NSString *const ATLMIMETypeImageJPEGPreview;   // image/jpeg+preview
extern NSString *const ATLMIMETypeImageSize;          // application/json+imageSize
extern NSString *const ATLMIMETypeLocation;           // location/coordinate
extern NSString *const ATLMIMETypeDate;               // text/date

extern NSUInteger const ATLThumbnailSize;             // 512px

extern NSString *const ATLImagePreviewWidthKey;
extern NSString *const ATLImagePreviewHeightKey;
extern NSString *const ATLLocationLatitudeKey;
extern NSString *const ATLLocationLongitudeKey;

//--------------------------
// @name Max Cell Dimensions
//--------------------------

CGFloat ATLMaxCellWidth();

CGFloat ATLMaxCellHeight();

//----------------------
// @name Image Utilities
//----------------------

CGSize ATLImageSizeForData(NSData *data);

CGSize ATLImageSizeForJSONData(NSData *data);

CGSize ATLImageSize(UIImage *image);

CGSize ATLTextPlainSize(NSString *string, UIFont *font);

CGRect ATLImageRectConstrainedToSize(CGSize imageSize, CGSize maxSize);

//--------------------------------
// @name Message Part Constructors
//--------------------------------

LYRMessagePart *ATLMessagePartWithText(NSString *text);

LYRMessagePart *ATLMessagePartWithJPEGImage(UIImage *image);

LYRMessagePart *ATLMessagePartForImageSize(UIImage *image);

LYRMessagePart *ATLMessagePartWithLocation(CLLocation *location);

//------------------------------
// @name Image Capture Utilities
//------------------------------

void ATLLastPhotoTaken(void(^completionHandler)(UIImage *image, NSError *error));

UIImage *ATLPinPhotoForSnapshot(MKMapSnapshot *snapshot, CLLocationCoordinate2D location);

NSArray *ATLLinkResultsForText(NSString *text);
