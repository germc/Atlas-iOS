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
#import "ATLMediaAttachment.h"

extern NSString *const ATLMIMETypeTextPlain;          // text/plain
extern NSString *const ATLMIMETypeImagePNG;           // image/png
extern NSString *const ATLMIMETypeImageJPEG;          // image/jpeg
extern NSString *const ATLMIMETypeImageJPEGPreview;   // image/jpeg+preview
extern NSString *const ATLMIMETypeImageGIF;           // image/gif
extern NSString *const ATLMIMETypeImageGIFPreview;    // image/gif+preview
extern NSString *const ATLMIMETypeImageSize;          // application/json+imageSize
extern NSString *const ATLMIMETypeLocation;           // location/coordinate
extern NSString *const ATLMIMETypeDate;               // text/date

extern NSUInteger const ATLDefaultThumbnailSize;      // 512px
extern NSUInteger const ATLDefaultGIFThumbnailSize;   // 64px

extern NSString *const ATLImagePreviewWidthKey;
extern NSString *const ATLImagePreviewHeightKey;
extern NSString *const ATLLocationLatitudeKey;
extern NSString *const ATLLocationLongitudeKey;

//---------------------------------
// @name Internationalization Macro
//---------------------------------

#define ATLLocalizedString(key, value, comment) NSLocalizedStringWithDefaultValue(key, nil, [NSBundle mainBundle], value, comment)

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

/**
 @abstract Constraints the CGSize to the default cell size (defined in ATLMaxCellWidth() and ATLMaxCellHeight()) and preserving the original aspec ratio.
 @param imageSize The size of the source image that should be shrunk or enlarged.
 @return Returns a CGSize constrained to the cell size with the same aspect ratio as the source CGSize.
 */
CGSize ATLConstrainImageSizeToCellSize(CGSize imageSize);

CGSize ATLTextPlainSize(NSString *string, UIFont *font);

CGRect ATLImageRectConstrainedToSize(CGSize imageSize, CGSize maxSize);

//-----------------------------
// @name Message Part Utilities
//-----------------------------

NSArray *ATLMessagePartsWithMediaAttachment(ATLMediaAttachment *mediaAttachment);

LYRMessagePart *ATLMessagePartForMIMEType(LYRMessage *message, NSString *MIMEType);

//------------------------------
// @name Image Capture Utilities
//------------------------------

void ATLAssetURLOfLastPhotoTaken(void(^completionHandler)(NSURL *assetURL, NSError *error));

void ATLLastPhotoTaken(void(^completionHandler)(UIImage *image, NSError *error));

UIImage *ATLPinPhotoForSnapshot(MKMapSnapshot *snapshot, CLLocationCoordinate2D location);

NSArray *ATLTextCheckingResultsForText(NSString *text, NSTextCheckingType linkTypes);

//---------------------------------------------------------------
// @name ATLConversationViewController UIMenuController Utilities
//---------------------------------------------------------------

/**
 @abstract Returns the `LYRMessage` object from a `UIMenuController` selection in an `ATLMessageCollectionViewCell`.  Used in the `UIMenuItem` selectors the developer
 implements when setting `menuControllerActions` of the `ATLMessageBubbleView` class.
 @param collectionview The collectionview in which the event occurred.
 @param menuController The `UIMenuController` that handled the `UIMenuItem` selector.
 @return Returns the `LYRMessage` of the `ATLMessageCollectionViewCell` that had a `UIMenuItem` selected.
 */
LYRMessage *ATLMessageFromATLMessageCollectionViewCellForMenuController(UICollectionView *collectionview, UIMenuController *menuController);
