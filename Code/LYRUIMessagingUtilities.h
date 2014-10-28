//
//  LYRUIMessagingUtilities.h
//  Pods
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>
#import <MapKit/MapKit.h>

extern NSString * const LYRUIMIMETypeTextPlain; /// text/plain
extern NSString * const LYRUIMIMETypeImagePNG;  /// image/png
extern NSString * const LYRUIMIMETypeImageJPEG; /// image/jpeg
extern NSString * const LYRUIMIMETypeLocation;  /// location/coordinate

CGFloat LYRUIMaxCellWidth();

CGSize LYRUITextPlainSize(NSString *string, UIFont *font);

CGSize LYRUIImageSize(UIImage *image);

CGRect LYRUIImageRectConstrainedToSize(CGSize imageSize, CGSize maxSize);

UIImage *LYRUIAdjustOrientationForImage(UIImage *originalImage);

NSData *LYRUIJPEGDataForImageWithConstraint(UIImage *image, CGFloat constraint);

LYRMessagePart *LYRUIMessagePartWithLocation(CLLocation *location);

LYRMessagePart *LYRUIMessagePartWithText(NSString *text);

LYRMessagePart *LYRUIMessagePartWithJPEGImage(UIImage *image);

LYRMessagePart *LYRUIMessagePartWithPNGImage(UIImage *image);
