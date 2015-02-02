//
//  LYRUIMessagingUtilities.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 10/27/14.
//
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

LYRMessagePart *LYRUIMessagePartWithJPEGImage(UIImage *image, BOOL isPreview);

LYRMessagePart *LYRUIMessagePartForImageSize(UIImage *image);

LYRMessagePart *LYRUIMessagePartWithLocation(CLLocation *location);

//****************************
// Image Capture Utilities
//****************************

void LYRUILastPhotoTaken(void(^completionHandler)(UIImage *image, NSError *error));

void LYRUIPhotoForLocation(CLLocationCoordinate2D location, void(^completion)(UIImage *image, NSError *error));

NSArray *LYRUILinkResultsForText(NSString *text);