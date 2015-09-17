//
//  ATLMediaAttachment.h
//  Atlas
//
//  Created by Klemen Verdnik on 2/14/15.
//  Copyright (c) 2015 Layer, Inc. All rights reserved.
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

#import "ATLMediaAttachment.h"
#import "ATLMessagingUtilities.h"
#import "ATLMediaInputStream.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

/**
 @abstract Fetches the ALAsset from library based on given `assetURL`.
 @param assetURL URL identifier representing the asset.
 @param assetLibrary Library instance from whence to fetch the asset.
 @return An `ALAsset` if successfully retrieved from asset library, otherwise `nil`.
 */
ALAsset *ATLMediaAttachmentFromAssetURL(NSURL *assetURL, ALAssetsLibrary *assetLibrary);

/**
 @abstract A helper function that streams data straight from an NSInputStream
   into the NSData.
 @param inputStream The `NSInputStream` where the data will be consumed from.
 @return An `NSData` object with data.
 */
NSData *ATLMediaAttachmentDataFromInputStream(NSInputStream *inputStream);

/**
 @abstract Generates a thumbnail from the desired video by taking a still
   snapshot from a frame located at the first second in the video.
 @param fileURL File path of the video asset in a form of an `NSURL`
 @return Returns a thumbnail image in a form of an `NSUImage`; In case of a
   failure, function returns `nil`.
 */
UIImage *ATLMediaAttachmentGenerateThumbnailFromVideoFileURL(NSURL *videoFileURL);

/**
 @abstract Extracts the video orientation based on assetTtrack's affine transform.
 @param assetTrack The `AVAssetTrack` for which to extract the video orientation from.
 @return Orientation information in a form of `UIImageOrientation`.
 */
UIImageOrientation ATLMediaAttachmentVideoOrientationForAVAssetTrack(AVAssetTrack *assetVideoTrack);

static int const ATLMediaAttachmentTIFFOrientationToImageOrientationMap[9] = { 0, 0, 6, 1, 5, 4, 4, 7, 2 };
static char const ATLMediaAttachmentAsyncToBlockingQueueName[] = "com.layer.Atlas.ATLMediaAttachment.blocking";
static NSUInteger const ATLMediaAttachmentDataFromStreamBufferSize = 1024 * 1024;
static float const ATLMediaAttachmentDefaultThumbnailJPEGCompression = 0.5f;

#pragma mark - Private class definitions

@interface ATLMediaAttachment ()

@property (nonatomic) UIImage *attachableThumbnailImage;
@property (nonatomic, readwrite) ATLMediaAttachmentType mediaType;
@property (nonatomic, readwrite) NSUInteger thumbnailSize;
@property (nonatomic, readwrite) NSString *textRepresentation;
@property (nonatomic, readwrite) NSString *mediaMIMEType;
@property (nonatomic, readwrite) NSInputStream *mediaInputStream;
@property (nonatomic, readwrite) NSString *thumbnailMIMEType;
@property (nonatomic, readwrite) NSInputStream *thumbnailInputStream;
@property (nonatomic, readwrite) NSString *metadataMIMEType;
@property (nonatomic, readwrite) NSInputStream *metadataInputStream;

@end

@interface ATLAssetMediaAttachment : ATLMediaAttachment

@property (nonatomic) NSURL *inputAssetURL;

- (instancetype)initWithAssetURL:(NSURL *)assetURL thumbnailSize:(NSUInteger)thumbnailSize;
- (instancetype)initWithFileURL:(NSURL *)fileURL thumbnailSize:(NSUInteger)thumbnailSize;

@end

@interface ATLImageMediaAttachment : ATLMediaAttachment

@property (nonatomic) UIImage *inputImage;

- (instancetype)initWithImage:(UIImage *)image metadata:(NSDictionary *)metadata thumbnailSize:(NSUInteger)thumbnailSize;

@end

@interface ATLLocationMediaAttachment : ATLMediaAttachment

- (instancetype)initWithLocation:(CLLocation *)location;

@end

@interface ATLTextMediaAttachment : ATLMediaAttachment

- (instancetype)initWithText:(NSString *)text;

@end

#pragma mark - Private class implementations

@implementation ATLAssetMediaAttachment

- (instancetype)initWithAssetURL:(NSURL *)assetURL thumbnailSize:(NSUInteger)thumbnailSize
{
    self = [super init];
    if (self) {
        if (!assetURL) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Cannot initialize %@ with `nil` assetURL.", self.superclass] userInfo:nil];
        }
        _inputAssetURL = assetURL;
        self.thumbnailSize = thumbnailSize;
        
        // --------------------------------------------------------------------
        // Fetching the asset from the assets library and bringing
        // it into this thread.
        // --------------------------------------------------------------------
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        ALAsset *asset = ATLMediaAttachmentFromAssetURL(assetURL, assetLibrary);
        if (!asset) {
            // Asset not found
            return nil;
        }
        NSString *assetType = [asset valueForProperty:ALAssetPropertyType];
        
        // --------------------------------------------------------------------
        // Prepare the input stream and MIMEType for the full size media.
        // --------------------------------------------------------------------
        self.mediaInputStream = [ATLMediaInputStream mediaInputStreamWithAssetURL:asset.defaultRepresentation.url];
        
        if ( [assetType isEqualToString:ALAssetTypeVideo]) {
            self.mediaMIMEType = ATLMIMETypeVideoMP4;
        }else {
            self.mediaMIMEType = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)(asset.defaultRepresentation.UTI), kUTTagClassMIMEType));
        }
        
        // --------------------------------------------------------------------
        // Prepare the input stream and MIMEType for the thumbnail.
        // --------------------------------------------------------------------
        if ([self.mediaMIMEType isEqualToString:ATLMIMETypeImageGIF]) {
            self.thumbnailInputStream = [ATLMediaInputStream mediaInputStreamWithAssetURL:asset.defaultRepresentation.url];
            ((ATLMediaInputStream *)self.thumbnailInputStream).maximumSize = ATLDefaultGIFThumbnailSize;
            self.thumbnailMIMEType = ATLMIMETypeImageGIFPreview;
        } else if ([self.mediaMIMEType isEqualToString:ATLMIMETypeVideoMP4]) {
            UIImage *image = ATLMediaAttachmentGenerateThumbnailFromVideoFileURL(assetURL);
            self.thumbnailInputStream = [ATLMediaInputStream mediaInputStreamWithImage:image metadata:nil];
            ((ATLMediaInputStream *)self.thumbnailInputStream).maximumSize = thumbnailSize;
            ((ATLMediaInputStream *)self.thumbnailInputStream).compressionQuality = ATLMediaAttachmentDefaultThumbnailJPEGCompression;
            self.thumbnailMIMEType = ATLMIMETypeImageJPEGPreview;
        } else {
            self.thumbnailInputStream = [ATLMediaInputStream mediaInputStreamWithAssetURL:asset.defaultRepresentation.url];
            ((ATLMediaInputStream *)self.thumbnailInputStream).maximumSize = thumbnailSize;
            ((ATLMediaInputStream *)self.thumbnailInputStream).compressionQuality = ATLMediaAttachmentDefaultThumbnailJPEGCompression;
            self.thumbnailMIMEType = ATLMIMETypeImageJPEGPreview;
        }
        
        // --------------------------------------------------------------------
        // Prepare the input stream and MIMEType for the metadata
        // about the asset.
        // --------------------------------------------------------------------
        NSDictionary *imageMetadata = @{ @"width": @(asset.defaultRepresentation.dimensions.width),
                                         @"height": @(asset.defaultRepresentation.dimensions.height),
                                         @"orientation": @(asset.defaultRepresentation.orientation) };
        NSError *JSONSerializerError;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:imageMetadata options:NSJSONWritingPrettyPrinted error:&JSONSerializerError];
        if (JSONData) {
            self.metadataInputStream = [NSInputStream inputStreamWithData:JSONData];
            self.metadataMIMEType = ATLMIMETypeImageSize;
        } else {
            NSLog(@"ATLMediaAttachment failed to generate a JSON object for image metadata");
        }
        
        // --------------------------------------------------------------------
        // Prepare the attachable thumbnail meant for UI (which is inlined with
        // text in the message composer).
        // --------------------------------------------------------------------
        self.attachableThumbnailImage = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
        
        // --------------------------------------------------------------------
        // Set the type - public property.
        // --------------------------------------------------------------------
        if ([assetType isEqualToString:ALAssetTypePhoto] ) {
            self.mediaType = ATLMediaAttachmentTypeImage;
            self.textRepresentation = @"Attachment: Image";
        } else if ([assetType isEqualToString:ALAssetTypeVideo]) {
            self.mediaType = ATLMediaAttachmentTypeVideo;
            self.textRepresentation = @"Attachment: Video";
        } else {
            return nil;
        }
        
    }
    return self;
}

- (instancetype)initWithFileURL:(NSURL *)fileURL thumbnailSize:(NSUInteger)thumbnailSize
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Cannot initialize %@. File not found at path='%@'.", self.superclass, fileURL] userInfo:nil];
    }

    // --------------------------------------------------------------------
    // Figure out the type of the media from the file extension.
    // --------------------------------------------------------------------
    UIImage *thumbnailImage;
    CFStringRef fileExtension = (__bridge CFStringRef)[fileURL pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    if (!(UTTypeConformsTo(fileUTI, kUTTypeImage) || UTTypeConformsTo(fileUTI, kUTTypeVideo) || UTTypeConformsTo(fileUTI, kUTTypeQuickTimeMovie))) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Cannot initialize %@. Unsupported MIMEtype='%@'.", self.superclass, (__bridge NSString *)UTTypeCopyDescription(fileUTI)] userInfo:nil];
    }

    // --------------------------------------------------------------------
    // Prepare the input stream and MIMEType for the full size media.
    // --------------------------------------------------------------------
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
        self.mediaMIMEType = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(fileUTI, kUTTagClassMIMEType));
    } else if (UTTypeConformsTo(fileUTI, kUTTypeVideo) || UTTypeConformsTo(fileUTI, kUTTypeQuickTimeMovie)) {
        self.mediaMIMEType = ATLMIMETypeVideoMP4;
    }
    self.mediaInputStream = [ATLMediaInputStream mediaInputStreamWithFileURL:fileURL];
    
    // --------------------------------------------------------------------
    // Prepare the input stream and MIMEType for the thumbnail.
    // --------------------------------------------------------------------
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
        self.thumbnailInputStream = [ATLMediaInputStream mediaInputStreamWithFileURL:fileURL];
        self.thumbnailMIMEType = ATLMIMETypeImageJPEGPreview;
    } else if (UTTypeConformsTo(fileUTI, kUTTypeVideo) || UTTypeConformsTo(fileUTI, kUTTypeQuickTimeMovie)) {
        if ((UTTypeConformsTo(fileUTI, kUTTypeVideo) || UTTypeConformsTo(fileUTI, kUTTypeQuickTimeMovie))) {
            thumbnailImage = ATLMediaAttachmentGenerateThumbnailFromVideoFileURL(fileURL);
        }
        self.thumbnailInputStream = [ATLMediaInputStream mediaInputStreamWithImage:thumbnailImage metadata:nil];
        self.thumbnailMIMEType = ATLMIMETypeImageJPEGPreview;
    }
    ((ATLMediaInputStream *)self.thumbnailInputStream).maximumSize = thumbnailSize;
    ((ATLMediaInputStream *)self.thumbnailInputStream).compressionQuality = ATLMediaAttachmentDefaultThumbnailJPEGCompression;
    
    // --------------------------------------------------------------------
    // Prepare the input stream and MIMEType for the metadata information
    // about the asset (dimension and orientation).
    // --------------------------------------------------------------------
    CGSize mediaDimensions = CGSizeZero;
    UIImageOrientation mediaOrientation = UIImageOrientationUp;
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
        // In case it's an image.
        CGDataProviderRef providerRef = CGDataProviderCreateWithURL((CFURLRef)fileURL);
        CGImageSourceRef imageSourceRef = CGImageSourceCreateWithDataProvider(providerRef, NULL);
        NSDictionary *dict = (__bridge NSDictionary *)(CGImageSourceCopyPropertiesAtIndex(imageSourceRef, 0, NULL));
        CGDataProviderRelease(providerRef);
        CFRelease(imageSourceRef);
        mediaDimensions.width = [dict[(NSString *)kCGImagePropertyPixelWidth] integerValue];
        mediaDimensions.height = [dict[(NSString *)kCGImagePropertyPixelHeight] integerValue];
        int CGImageTIFFOrientation = [dict[(NSString *)kCGImagePropertyTIFFOrientation] intValue];
        mediaOrientation = ATLMediaAttachmentTIFFOrientationToImageOrientationMap[CGImageTIFFOrientation];
    } else if (UTTypeConformsTo(fileUTI, kUTTypeVideo) || UTTypeConformsTo(fileUTI, kUTTypeQuickTimeMovie)) {
        // Or if it's a video.
        AVAsset *videoAsset = [AVAsset assetWithURL:fileURL];
        AVAssetTrack *firstVideoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
        mediaDimensions = firstVideoAssetTrack.naturalSize;
        mediaOrientation = ATLMediaAttachmentVideoOrientationForAVAssetTrack(firstVideoAssetTrack);
        if (mediaOrientation == UIImageOrientationUp || mediaOrientation == UIImageOrientationDown) {
            // Flip the media dimension.
            mediaDimensions = CGSizeMake(mediaDimensions.height, mediaDimensions.width);
        }
    }

    NSDictionary *mediaMetadata = @{ @"width": @(mediaDimensions.width),
                                     @"height": @(mediaDimensions.height),
                                     @"orientation": @(mediaOrientation) };
    NSError *JSONSerializerError;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:mediaMetadata options:NSJSONWritingPrettyPrinted error:&JSONSerializerError];
    if (JSONData) {
        self.metadataInputStream = [NSInputStream inputStreamWithData:JSONData];
        self.metadataMIMEType = ATLMIMETypeImageSize;
    } else {
        NSLog(@"ATLMediaAttachment failed to generate a JSON object for image metadata");
    }
    
    // --------------------------------------------------------------------
    // Prepare the attachable thumbnail meant for the UI (which is inlined
    // with text in the message composer).
    //
    // Since we got the full resolution UIImage, we need to create a
    // thumbnail size in the initializer.
    // --------------------------------------------------------------------
    ATLMediaInputStream *attachableThumbnailInputStream;
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
        attachableThumbnailInputStream = [ATLMediaInputStream mediaInputStreamWithFileURL:fileURL];
    } else if (UTTypeConformsTo(fileUTI, kUTTypeVideo) || UTTypeConformsTo(fileUTI, kUTTypeQuickTimeMovie)) {
        attachableThumbnailInputStream = [ATLMediaInputStream mediaInputStreamWithImage:thumbnailImage metadata:nil];
    }
    
    attachableThumbnailInputStream.maximumSize = thumbnailSize;
    attachableThumbnailInputStream.compressionQuality = ATLMediaAttachmentDefaultThumbnailJPEGCompression;
    NSData *resampledImageData = ATLMediaAttachmentDataFromInputStream(attachableThumbnailInputStream);
    self.attachableThumbnailImage = [UIImage imageWithData:resampledImageData scale:thumbnailImage.scale];
    
    self.thumbnailSize = thumbnailSize;
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
        self.mediaType = ATLMediaAttachmentTypeImage;
        self.textRepresentation = @"Attachment: Image";
    } else if (UTTypeConformsTo(fileUTI, kUTTypeVideo) || UTTypeConformsTo(fileUTI, kUTTypeQuickTimeMovie)) {
        self.mediaType = ATLMediaAttachmentTypeVideo;
        self.textRepresentation = @"Attachment: Video";
    }
    return self;
}

@end

@implementation ATLImageMediaAttachment

- (instancetype)initWithImage:(UIImage *)image metadata:(NSDictionary *)metadata thumbnailSize:(NSUInteger)thumbnailSize
{
    self = [super init];
    if (self) {
        if (!image) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Cannot initialize %@ with `nil` image.", self.superclass] userInfo:nil];
        }
        self.inputImage = image;
        
        // --------------------------------------------------------------------
        // Prepare the input stream and MIMEType for the full size media.
        // --------------------------------------------------------------------
        self.mediaInputStream = [ATLMediaInputStream mediaInputStreamWithImage:image metadata:metadata];
        self.mediaMIMEType = ATLMIMETypeImageJPEG;
        
        // --------------------------------------------------------------------
        // Prepare the input stream and MIMEType for the thumbnail.
        // --------------------------------------------------------------------
        self.thumbnailInputStream = [ATLMediaInputStream mediaInputStreamWithImage:image metadata:metadata];
        ((ATLMediaInputStream *)self.thumbnailInputStream).maximumSize = thumbnailSize;
        ((ATLMediaInputStream *)self.thumbnailInputStream).compressionQuality = ATLMediaAttachmentDefaultThumbnailJPEGCompression;
        self.thumbnailMIMEType = ATLMIMETypeImageJPEGPreview;
        
        // --------------------------------------------------------------------
        // Prepare the input stream and MIMEType for the metadata
        // about the asset.
        // --------------------------------------------------------------------
        NSDictionary *imageMetadata = @{ @"width": @(image.size.width),
                                         @"height": @(image.size.height),
                                         @"orientation": @(image.imageOrientation) };
        NSError *JSONSerializerError;
        NSData *JSONData = [NSJSONSerialization dataWithJSONObject:imageMetadata options:NSJSONWritingPrettyPrinted error:&JSONSerializerError];
        if (JSONData) {
            self.metadataInputStream = [NSInputStream inputStreamWithData:JSONData];
            self.metadataMIMEType = ATLMIMETypeImageSize;
        } else {
            NSLog(@"ATLMediaAttachment failed to generate a JSON object for image metadata");
        }
        
        // --------------------------------------------------------------------
        // Prepare the attachable thumbnail meant for the UI (which is inlined
        // with text in the message composer).
        //
        // Since we got the full resolution UIImage, we need to create a
        // thumbnail size in the initializer.
        // --------------------------------------------------------------------
        ATLMediaInputStream *attachableThumbnailInputStream = [ATLMediaInputStream mediaInputStreamWithImage:image metadata:metadata];
        attachableThumbnailInputStream.maximumSize = thumbnailSize;
        attachableThumbnailInputStream.compressionQuality = ATLMediaAttachmentDefaultThumbnailJPEGCompression;
        NSData *resampledImageData = ATLMediaAttachmentDataFromInputStream(attachableThumbnailInputStream);
        self.attachableThumbnailImage = [UIImage imageWithData:resampledImageData scale:image.scale];
        
        // --------------------------------------------------------------------
        // Set the type and the rest of the public properties.
        // --------------------------------------------------------------------
        self.thumbnailSize = thumbnailSize;
        self.mediaType = ATLMediaAttachmentTypeImage;
        self.textRepresentation = @"Attachment: Image";
    }
    return self;
}

@end

@implementation ATLLocationMediaAttachment

- (instancetype)initWithLocation:(CLLocation *)location
{
    self = [super init];
    if (self) {
        if (!location) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Cannot initialize %@ with `nil` location.", self.superclass] userInfo:nil];
        }
        self.mediaType = ATLMediaAttachmentTypeLocation;
        self.mediaMIMEType = ATLMIMETypeLocation;
        NSData *data = [NSJSONSerialization dataWithJSONObject:@{ ATLLocationLatitudeKey: @(location.coordinate.latitude),
                                                                  ATLLocationLongitudeKey: @(location.coordinate.longitude) } options:0 error:nil];
        self.mediaInputStream = [NSInputStream inputStreamWithData:data];
        self.textRepresentation = @"Attachment: Location";
    }
    return self;
}

@end

@implementation ATLTextMediaAttachment

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self) {
        if (!text) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Cannot initialize %@ with `nil` text.", self.superclass] userInfo:nil];
        }
        self.mediaType = ATLMediaAttachmentTypeText;
        self.mediaMIMEType = ATLMIMETypeTextPlain;
        self.mediaInputStream = [NSInputStream inputStreamWithData:[text dataUsingEncoding:NSUTF8StringEncoding]];
        self.textRepresentation = text;
    }
    return self;
}

@end

@implementation ATLMediaAttachment

#pragma mark - Initializers

+ (instancetype)mediaAttachmentWithAssetURL:(NSURL *)assetURL thumbnailSize:(NSUInteger)thumbnailSize
{
    return [[ATLAssetMediaAttachment alloc] initWithAssetURL:assetURL thumbnailSize:thumbnailSize];
}

+ (instancetype)mediaAttachmentWithFileURL:(NSURL *)fileURL thumbnailSize:(NSUInteger)thumbnailSize
{
    return [[ATLAssetMediaAttachment alloc] initWithFileURL:fileURL thumbnailSize:thumbnailSize];
}

+ (instancetype)mediaAttachmentWithImage:(UIImage *)image metadata:(NSDictionary *)metadata thumbnailSize:(NSUInteger)thumbnailSize;
{
    return [[ATLImageMediaAttachment alloc] initWithImage:image metadata:(NSDictionary *)metadata thumbnailSize:thumbnailSize];
}

+ (instancetype)mediaAttachmentWithText:(NSString *)text
{
    return [[ATLTextMediaAttachment alloc] initWithText:text];
}

+ (instancetype)mediaAttachmentWithLocation:(CLLocation *)location
{
    return [[ATLLocationMediaAttachment alloc] initWithLocation:location];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([[self class] isEqual:[ATLMediaAttachment class]]) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Failed to call designated initializer. Use one of the following initialiers: %@", [@[ NSStringFromSelector(@selector(mediaAttachmentWithAssetURL:thumbnailSize:)), NSStringFromSelector(@selector(mediaAttachmentWithImage:metadata:thumbnailSize:)), NSStringFromSelector(@selector(mediaAttachmentWithText:)), NSStringFromSelector(@selector(mediaAttachmentWithLocation:)) ] componentsJoinedByString:@", "]] userInfo:nil];
        }
    }
    return self;
}

#pragma mark - NSTextAttachment Overrides

- (UIImage *)image
{
    return self.attachableThumbnailImage;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    CGRect systemImageRect = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    return ATLImageRectConstrainedToSize(systemImageRect.size, CGSizeEqualToSize(_maximumInputSize, CGSizeZero) ? CGSizeMake(150, 150) : _maximumInputSize);
}

@end

ALAsset *ATLMediaAttachmentFromAssetURL(NSURL *assetURL, ALAssetsLibrary *assetLibrary)
{
    static dispatch_queue_t asyncQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        asyncQueue = dispatch_queue_create(ATLMediaAttachmentAsyncToBlockingQueueName, DISPATCH_QUEUE_CONCURRENT);
    });
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block ALAsset *resultAsset;
    dispatch_async(asyncQueue, ^{
        [assetLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            if (asset){
                resultAsset = asset;
                dispatch_semaphore_signal(semaphore);
            } else {
                // On iOS 8.1 [library assetForUrl] Photo Streams always returns nil. Try to obtain it in an alternative way
                [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if([result.defaultRepresentation.url isEqual:assetURL]) {
                            resultAsset = result;
                            *stop = YES;
                            dispatch_semaphore_signal(semaphore);
                        }
                    }];
                } failureBlock:^(NSError *error) {
                    dispatch_semaphore_signal(semaphore);
                }];
            }
        } failureBlock:^(NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return resultAsset;
}

NSData *ATLMediaAttachmentDataFromInputStream(NSInputStream *inputStream)
{
    if (!inputStream) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"inputStream cannot be `nil`." userInfo:nil];
    }
    NSMutableData *dataFromStream = [NSMutableData data];
    
    // Open stream
    [inputStream open];
    if (inputStream.streamError) {
        NSLog(@"Failed to stream image content with %@", inputStream.streamError);
        return nil;
    }
    
    // Start streaming
    uint8_t *buffer = malloc(ATLMediaAttachmentDataFromStreamBufferSize);
    NSUInteger bytesRead;
    do {
        bytesRead = [inputStream read:buffer maxLength:(unsigned long)ATLMediaAttachmentDataFromStreamBufferSize];
        if (bytesRead != 0) {
            [dataFromStream appendBytes:buffer length:bytesRead];
        }
    } while (bytesRead != 0);
    free(buffer);
    
    // Close stream
    [inputStream close];
    
    // Done
    return dataFromStream;
}

UIImage *ATLMediaAttachmentGenerateThumbnailFromVideoFileURL(NSURL *videoFileURL)
{
    AVURLAsset *URLasset = [[AVURLAsset alloc] initWithURL:videoFileURL options:nil];
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:URLasset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    NSError *error = NULL;
    AVAssetTrack *videoAssetTrack = [[URLasset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CMTime time;
    if (videoAssetTrack) {
        time = CMTimeMake(0, videoAssetTrack.nominalFrameRate);
    }
    CGImageRef imageRef = [assetImageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
    if (error) {
        NSLog(@"Failed to create thumbnail!");
    }
    UIImage *outputImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return outputImage;
}

UIImageOrientation ATLMediaAttachmentVideoOrientationForAVAssetTrack(AVAssetTrack *assetVideoTrack)
{
    CGAffineTransform transform = assetVideoTrack.preferredTransform;
    int videoAngleInDegrees = (int)((float)atan2(transform.b, transform.a) * (float)180 / (float)M_PI);
    switch (videoAngleInDegrees) {
        case 90:
            return UIImageOrientationUp;
        case 180:
            return UIImageOrientationLeft;
        case -90:
            return UIImageOrientationDown;
        default:
            return UIImageOrientationRight;
    }
}

