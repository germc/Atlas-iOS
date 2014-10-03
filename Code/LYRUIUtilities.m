//
//  LYRUIUtilities.m
//  Pods
//
//  Created by Kevin Coleman on 9/8/14.
//
//

#import "LYRUIUtilities.h"

NSString * const LYRUIMIMETypeTextPlain = @"text/plain";
NSString * const LYRUIMIMETypeTextHTML = @"text/HTML";
NSString * const LYRUIMIMETypeImagePNG = @"image/png";
NSString * const LYRUIMIMETypeImageJPEG = @"image/jpeg";
NSString * const LYRUIMIMETypeLocation = @"location/coordinate";

CGFloat LYRUIMaxCellWidth()
{
    return 200;
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
        itemSize = CGSizeMake(LYRUIMaxCellWidth(), 300);
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


