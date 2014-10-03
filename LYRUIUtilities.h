//
//  LYRUIUtilities.h
//  Pods
//
//  Created by Kevin Coleman on 9/8/14.
//
//

#import <Foundation/Foundation.h>

extern NSString * const LYRUIMIMETypeTextPlain; /// text/plain
extern NSString * const LYRUIMIMETypeTextHTML;  /// text/html
extern NSString * const LYRUIMIMETypeImagePNG;  /// image/png
extern NSString * const LYRUIMIMETypeImageJPEG; /// image/jpeg
extern NSString * const LYRUIMIMETypeLocation;  /// location/coordinate

CGFloat LYRUIMaxCellWidth();

CGSize LYRUITextPlainSize(NSString *string, UIFont *font);

CGSize LYRUIImageSize(UIImage *image);

CGRect LYRUIImageRectConstrainedToSize(CGSize imageSize, CGSize maxSize);

UIImage *LYRUIAdjustOrientationForImage(UIImage *originalImage);

NSData *LYRUIJPEGDataForImageWithConstraint(UIImage *image, CGFloat constraint);

