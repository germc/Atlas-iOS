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

/**
 @abstract Fetches the ALAsset from library based on given `assetURL`.
 @param assetURL URL identifier representing the asset.
 @param assetLibrary Library instance from whence to fetch the asset.
 @return An `ALAsset` if successfully retrieved from asset library, otherwise `nil`.
 */
ALAsset *ATLMediaAttachmentFromAssetURL(NSURL *assetURL, ALAssetsLibrary *assetLibrary);
NSData *ATLMediaAttachmentDataFromInputStream(NSInputStream *inputStream);

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
        self.mediaMIMEType = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)(asset.defaultRepresentation.UTI), kUTTagClassMIMEType));
        
        // --------------------------------------------------------------------
        // Prepare the input stream and MIMEType for the thumbnail.
        // --------------------------------------------------------------------
        self.thumbnailInputStream = [ATLMediaInputStream mediaInputStreamWithAssetURL:asset.defaultRepresentation.url];
        if ([self.mediaMIMEType isEqualToString:ATLMIMETypeImageGIF]) {
            ((ATLMediaInputStream *)self.thumbnailInputStream).maximumSize = ATLDefaultGIFThumbnailSize;
            self.thumbnailMIMEType = ATLMIMETypeImageGIFPreview;
        } else {
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
        if ([assetType isEqualToString:ALAssetTypePhoto]) {
            self.mediaType = ATLMediaAttachmentTypeImage;
        } else {
            return nil;
        }
        
        self.textRepresentation = @"Attachment: Image";
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
