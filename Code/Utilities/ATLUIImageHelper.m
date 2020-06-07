//
//  ATLUIImageHelper.m
//  Pods
//
//  Created by Kabir Mahal on 3/18/15.
//
//  Credit and source to: https://github.com/mayoff/uiimage-from-animated-gif


#import "ATLUIImageHelper.h"
#import <ImageIO/ImageIO.h>

#if __has_feature(objc_arc)
#define toCF (__bridge CFTypeRef)
#define fromCF (__bridge id)
#else
#define toCF (CFTypeRef)
#define fromCF (id)
#endif

#pragma mark - Private Methods

static int ATLDelayCentisecondsForImageAtIndex(CGImageSourceRef const source, size_t const index)
{
    int delayCentiseconds = 1;
    CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(source, index, NULL);
    if (properties) {
        CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        if (gifProperties) {
            NSNumber *gifFrameDuration = fromCF CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
            if (gifFrameDuration == NULL || [gifFrameDuration doubleValue] == 0) {
                gifFrameDuration = fromCF CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
            }
            if ([gifFrameDuration doubleValue] > 0) {
                // Even though the GIF stores the delay as an integer number of centiseconds, ImageIO “helpfully” converts that to seconds for us.
                delayCentiseconds = (int)lrint([gifFrameDuration doubleValue] * 100);
            }
        }
        CFRelease(properties);
    }
    return delayCentiseconds;
}

static void ATLCreateImagesAndDelays(CGImageSourceRef source, size_t count, CGImageRef imagesOut[count], int delayCentisecondsOut[count])
{
    for (size_t i = 0; i < count; ++i) {
        imagesOut[i] = CGImageSourceCreateImageAtIndex(source, i, NULL);
        delayCentisecondsOut[i] = ATLDelayCentisecondsForImageAtIndex(source, i);
    }
}

static int ATLSum(size_t const count, int const *const values)
{
    int theSum = 0;
    for (size_t i = 0; i < count; ++i) {
        theSum += values[i];
    }
    return theSum;
}

static int ATLPairGCD(int duration, int gcd)
{
    if (duration < gcd) {
        return ATLPairGCD(gcd, duration);
    }
    while (true) {
        int const r = duration % gcd;
        if (r == 0) {
            return gcd;
        }
        duration = gcd;
        gcd = r;
    }
}

static int ATLVectorGCD(size_t const count, int const *const values)
{
    int gcd = values[0];
    for (size_t i = 1; i < count; ++i) {
        // Note that after I process the first few elements of the vector, `gcd` will probably be smaller than any remaining element.  By passing the smaller value as the second argument to `pairGCD`, I avoid making it swap the arguments.
        gcd = ATLPairGCD(values[i], gcd);
    }
    return gcd;
}

static NSArray *ATLFrameArray(size_t const count, CGImageRef const images[count], int const delayCentiseconds[count], int const totalDurationCentiseconds)
{
    int const gcd = ATLVectorGCD(count, delayCentiseconds);
    size_t const frameCount = totalDurationCentiseconds / gcd;
    UIImage *frames[frameCount];
    for (size_t i = 0, f = 0; i < count; ++i) {
        UIImage *const frame = [UIImage imageWithCGImage:images[i]];
        for (size_t j = delayCentiseconds[i] / gcd; j > 0; --j) {
            frames[f++] = frame;
        }
    }
    return [NSArray arrayWithObjects:frames count:frameCount];
}

static void ATLReleaseImages(size_t const count, CGImageRef const images[count])
{
    for (size_t i = 0; i < count; ++i) {
        CGImageRelease(images[i]);
    }
}

static UIImage *ATLAnimatedImageWithAnimatedGIFImageSource(CGImageSourceRef const source)
{
    size_t const count = CGImageSourceGetCount(source);
    CGImageRef images[count];
    int delayCentiseconds[count]; // in centiseconds
    ATLCreateImagesAndDelays(source, count, images, delayCentiseconds);
    int const totalDurationCentiseconds = ATLSum(count, delayCentiseconds);
    NSArray *const frames = ATLFrameArray(count, images, delayCentiseconds, totalDurationCentiseconds);
    UIImage *const animation = [UIImage animatedImageWithImages:frames duration:(NSTimeInterval)totalDurationCentiseconds / 100.0];
    ATLReleaseImages(count, images);
    return animation;
}

static UIImage *ATLAnimatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceRef CF_RELEASES_ARGUMENT source)
{
    if (source) {
        UIImage *const image = ATLAnimatedImageWithAnimatedGIFImageSource(source);
        CFRelease(source);
        return image;
    } else {
        return nil;
    }
}

#pragma mark - Public Helper Methods

UIImage *ATLAnimatedImageWithAnimatedGIFData(NSData *data)
{
    return ATLAnimatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithData(toCF data, NULL));
}

UIImage *ATLAnimatedImageWithAnimatedGIFURL(NSURL *url)
{
    return ATLAnimatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithURL(toCF url, NULL));
}
