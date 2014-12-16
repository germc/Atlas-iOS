//
//  LYRUIMessagingUtilities.m
//  Pods
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import "LYRUIMessagingUtilities.h"

NSString * const LYRUIMIMETypeTextPlain = @"text/plain";
NSString * const LYRUIMIMETypeTextHTML = @"text/HTML";
NSString * const LYRUIMIMETypeImagePNG = @"image/png";
NSString * const LYRUIMIMETypeImageJPEG = @"image/jpeg";
NSString * const LYRUIMIMETypeLocation = @"location/coordinate";
NSString * const LYRUIMIMETypeDate = @"text/date";

CGFloat LYRUIMaxCellWidth()
{
    return 220;
}

CGFloat LYRUIMaxCellHeight()
{
    return 300;
}

CGSize LYRUITextPlainSize(NSString *text, UIFont *font)
{
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                         attributes:@{NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){LYRUIMaxCellWidth(), CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size;
}

CGSize LYRUIImageSize(UIImage *image)
{
    CGSize itemSize;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    if (imageView.frame.size.height > imageView.frame.size.width) {
        CGFloat ratio = (LYRUIMaxCellHeight() / imageView.frame.size.height);
        itemSize = CGSizeMake(imageView.frame.size.width * ratio, LYRUIMaxCellHeight());
    } else {
        CGFloat ratio = (LYRUIMaxCellWidth() / imageView.frame.size.width);
        itemSize = CGSizeMake(LYRUIMaxCellWidth(), imageView.frame.size.height * ratio);
    }
    return itemSize;
}

CGRect LYRUIImageRectConstrainedToSize(CGSize imageSize, CGSize maxSize)
{
    CGRect thumbRect;
    
    if (imageSize.width > imageSize.height) {
        double ratio = maxSize.width/imageSize.width;
        double height = imageSize.height * ratio;
        thumbRect = CGRectMake(0, 0, maxSize.width, height);
    } else {
        double ratio = maxSize.height/imageSize.height;
        double width = imageSize.width * ratio;
        thumbRect = CGRectMake(0, 0, width, maxSize.height);
    }
    
    return thumbRect;
}

UIImage *LYRUIAdjustOrientationForImage(UIImage *originalImage)
{
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, originalImage.scale);
    [originalImage drawInRect:(CGRect){0, 0, originalImage.size}];
    UIImage *fixedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fixedImage;
}

// Photo Resizing
CGSize  LYRUISizeFromOriginalSizeWithConstraint(CGSize originalSize, CGFloat constraint)
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

// Photo JPEG Compression
NSData *LYRUIJPEGDataForImageWithConstraint(UIImage *image, CGFloat constraint)
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    CGImageRef ref = [[UIImage imageWithData:imageData] CGImage];
    
    CGFloat width = 1.0f * CGImageGetWidth(ref);
    CGFloat height = 1.0f * CGImageGetHeight(ref);
    
    CGSize previousSize = CGSizeMake(width, height);
    CGSize newSize = LYRUISizeFromOriginalSizeWithConstraint(previousSize, constraint);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    UIImage *assetImage = [UIImage imageWithCGImage:ref];
    [assetImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *imageToCompress = UIGraphicsGetImageFromCurrentImageContext();
    
    return UIImageJPEGRepresentation(imageToCompress, 0.25f);
}

NSDictionary *LYRUIComponetsForDate(NSDate *date)
{
    NSCalendar *cal = [[NSCalendar alloc] init];
    NSDateComponents *components = [cal components:0 fromDate:date];
    
    NSDictionary *dateComponets = @{@"year" : [NSNumber numberWithInteger:[components year]],
                                    @"month" : [NSNumber numberWithInteger:[components month]],
                                    @"day" : [NSNumber numberWithInteger:[components day]],
                                    @"hour" : [NSNumber numberWithInteger:[components hour]],
                                    @"minunte" : [NSNumber numberWithInteger:[components minute]],
                                    @"second" : [NSNumber numberWithInteger:[components second]]};
    return dateComponets;
}

LYRMessagePart *LYRUIMessagePartWithText(NSString *text)
{
    return [LYRMessagePart messagePartWithMIMEType:@"text/plain" data:[text dataUsingEncoding:NSUTF8StringEncoding]];
}

LYRMessagePart *LYRUIMessagePartWithLocation(CLLocation *location)
{
    NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:location.coordinate.longitude];
    return [LYRMessagePart messagePartWithMIMEType:LYRUIMIMETypeLocation
                                              data:[NSJSONSerialization dataWithJSONObject: @{@"lat" : lat, @"lon" : lon} options:0 error:nil]];
}

LYRMessagePart *LYRUIMessagePartWithJPEGImage(UIImage *image)
{
    UIImage *adjustedImage = LYRUIAdjustOrientationForImage(image);
    NSData *compressedImageData = UIImageJPEGRepresentation(adjustedImage, 1.0);
    return [LYRMessagePart messagePartWithMIMEType:LYRUIMIMETypeImageJPEG
                                              data:compressedImageData];
}

LYRMessagePart *LYRUIMessagePartWithDate(NSDate *date)
{
    NSDictionary *dateCompoents = LYRUIComponetsForDate(date);
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dateCompoents options:NSJSONWritingPrettyPrinted error:&error];
    return [LYRMessagePart messagePartWithMIMEType:LYRUIMIMETypeDate data:jsonData];
}



