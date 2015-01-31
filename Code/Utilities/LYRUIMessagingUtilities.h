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

NSString *const LYRUIImagePreviewWidthKey;
NSString *const LYRUIImagePreviewHeightKey;


CGFloat LYRUIMaxCellWidth();

CGSize LYRUIImageSizeForData(NSData *data);

CGSize LYRUIImageSizeForJSONData(NSData *data);

CGSize LYRUIImageSize(UIImage *image);

CGSize LYRUITextPlainSize(NSString *string, UIFont *font);

CGSize LYRUISizeProportionallyConstrainedToSize(CGSize nativeSize, CGSize maxSize);

CGRect LYRUIImageRectConstrainedToSize(CGSize imageSize, CGSize maxSize);

UIImage *LYRUIAdjustOrientationForImage(UIImage *originalImage);

LYRMessagePart *LYRUIMessagePartWithLocation(CLLocation *location);

LYRMessagePart *LYRUIMessagePartWithText(NSString *text);

LYRMessagePart *LYRUIMessagePartWithJPEGImage(UIImage *image, BOOL isPreview);

LYRMessagePart *LYRUIMEssagePartForImageSize(UIImage *image);

void LYRUILastPhotoTaken(void(^completionHandler)(UIImage *image, NSError *error));

NSArray *LYRUILinkResultsForText(NSString *text);
