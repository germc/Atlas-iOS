//
//  ATLMediaInputStream.m
//  Atlas
//
//  Created by Klemen Verdnik on 2/13/15.
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

#import "ATLMediaInputStream.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#ifdef DEBUG_ATLMediaInputStreamLog
#define ATLMediaInputStreamLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#define ATLMediaInputStreamLog(fmt, ...)
#endif

NSString *const ATLMediaInputStreamErrorDomain = @"com.layer.Atlas.ATLMediaInputStream";
static char const ATLMediaInputConsumerAsyncQueueName[] = "com.layer.Atlas.ATLMediaInputStream.asyncConsumerQueue";
static char const ATLMediaInputConsumerSerialTransferQueueName[] = "com.layer.Atlas.ATLMediaInputStream.serialTransferQueue";
static char const ATLMediaInputStreamAsyncToBlockingQueueName[] = "com.layer.Atlas.ATLMediaInputStream.blocking";
NSString *const ATLMediaInputStreamAppleCameraTIFFOptionsKey = @"{TIFF}";

/* Core I/O callbacks */
ALAsset *ATLMediaInputStreamAssetForAssetURL(NSURL *assetURL, ALAssetsLibrary *assetLibrary, NSError **error);
static size_t ATLMediaInputStreamGetBytesFromAssetCallback(void *assetStreamRef, void *buffer, off_t offset, size_t length);
static size_t ATLMediaInputStreamPutBytesIntoStreamCallback(void *assetStreamRef, const void *buffer, size_t length);

@interface ATLMediaInputStream ()

/* Private and public properties */
@property (nonatomic, readwrite) NSURL *sourceAssetURL;
@property (nonatomic, readwrite) UIImage *sourceImage;
@property (nonatomic, readwrite) NSDictionary *metadata;
@property (nonatomic, readwrite) BOOL isLossless;
@property (nonatomic) NSStreamStatus mediaStreamStatus;
@property (nonatomic) NSError *mediaStreamError;

/* Queues for concurrent operations */
@property (nonatomic) dispatch_semaphore_t streamFlowRequesterSemaphore;
@property (nonatomic) dispatch_semaphore_t streamFlowProviderSemaphore;
@property (nonatomic) dispatch_queue_t consumerAsyncQueue;
@property (nonatomic) dispatch_queue_t transferBufferSerialGuard;

/* Stream flow control (shared between ATLMediaInputStream API and Image I/O */
@property (nonatomic) NSData *dataConsumed;
@property (nonatomic) NSUInteger numberOfBytesRequested;
@property (nonatomic) NSUInteger numberOfBytesProvided;

/* References needed by ALAsset, Core Graphics and Image I/O used during transfer */
@property (nonatomic) ALAssetsLibrary *assetLibrary; // needs to be alive during transfer
@property (nonatomic) ALAsset *asset;
@property (nonatomic) ALAssetRepresentation *assetRepresentation;
@property (nonatomic, assign) CGDataProviderRef provider;
@property (nonatomic, assign) CGImageSourceRef source;
@property (nonatomic, assign) CGDataConsumerRef consumer;
@property (nonatomic, assign) CGImageDestinationRef destination;
@property (nonatomic) NSDictionary *sourceImageProperties;

@end

@interface ATLAssetInputStream : ATLMediaInputStream

- (instancetype)initWithAssetURL:(NSURL *)assetURL;

@end

@interface ATLImageInputStream : ATLMediaInputStream

- (instancetype)initWithImage:(UIImage *)image metadata:(NSDictionary *)metadata;;

@end

@implementation ATLAssetInputStream

- (instancetype)initWithAssetURL:(NSURL *)assetURL
{
    self = [super init];
    if (self) {
        if (!assetURL) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Cannot initialize %@ with `nil` assetURL.", self.class] userInfo:nil];
        }
        self.sourceAssetURL = assetURL;
    }
    return self;
}

@end

@implementation ATLImageInputStream

- (instancetype)initWithImage:(UIImage *)image metadata:(NSDictionary *)metadata;
{
    self = [super init];
    if (self) {
        if (!image) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Cannot initialize %@ with `nil` image.", self.class] userInfo:nil];
        }
        self.sourceImage = image;
        self.metadata = metadata;
    }
    return self;
}

@end

@implementation ATLMediaInputStream

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([[self class] isEqual:[ATLMediaInputStream class]]) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Failed to call designated initializer. Use one of the following initialiers: %@", [@[ NSStringFromSelector(@selector(mediaInputStreamWithAssetURL:)), NSStringFromSelector(@selector(mediaInputStreamWithImage:metadata:)) ] componentsJoinedByString:@", "]] userInfo:nil];
        }
        _mediaStreamStatus = NSStreamStatusNotOpen;
        _mediaStreamError = nil;
        _dataConsumed = [NSData data];
        _numberOfBytesRequested = 0;
        _numberOfBytesProvided = 0;
        _maximumSize = 0;
        _compressionQuality = 0.0f;
        _streamFlowRequesterSemaphore = dispatch_semaphore_create(0);
        _streamFlowProviderSemaphore = dispatch_semaphore_create(0);
        _consumerAsyncQueue = dispatch_queue_create(ATLMediaInputConsumerAsyncQueueName, DISPATCH_QUEUE_CONCURRENT);
        _transferBufferSerialGuard = dispatch_queue_create(ATLMediaInputConsumerSerialTransferQueueName, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (instancetype)mediaInputStreamWithAssetURL:(NSURL *)assetURL
{
    return [[ATLAssetInputStream alloc] initWithAssetURL:assetURL];
}

+ (instancetype)mediaInputStreamWithImage:(UIImage *)image metadata:(NSDictionary *)metadata;
{
    return [[ATLImageInputStream alloc] initWithImage:image metadata:metadata];
}

- (void)dealloc
{
    if (self.streamStatus != NSStreamStatusClosed) {
        [self close];
    }
}

#pragma mark - Transient isLossless implementation

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"isLossless"]) {
        NSSet *affectingKey = [NSSet setWithObjects:@"maximumSize", @"compressionQuality", nil];
        keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
    }
    return keyPaths;
}

- (BOOL)isLossless
{
    return (self.maximumSize == 0 && self.compressionQuality == 0.0f);
}

#pragma mark - Public Overrides

- (NSStreamStatus)streamStatus
{
    return self.mediaStreamStatus;
}

- (NSError *)streamError
{
    return self.mediaStreamError;
}

- (void)open
{
    // Tell receiver we're openning the stream.
    self.mediaStreamStatus = NSStreamStatusOpening;
    
    ATLMediaInputStreamLog(@"opening stream...");
    
    // Setup data provider.
    NSInteger numberOfSourceImages = 0;
    NSError *error;
    if (self.sourceAssetURL) {
        numberOfSourceImages = [self setupProviderForAssetStreamingWithError:&error];
    } else if (self.sourceImage) {
        // UIImages don't need a data provider, we're adding them to CGImageDestination directly.
        numberOfSourceImages = 1;
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed setting up data provider because source media not defined." userInfo:nil];
    }
    if (numberOfSourceImages == 0) {
        self.mediaStreamStatus = NSStreamStatusError;
        self.mediaStreamError = error;
        return;
    }
    
    // iOS7 specific
    BOOL success;
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        success = [self setupiOS7SpecificConsumerPrerequisite:&error];
        if (!success) {
            self.mediaStreamStatus = NSStreamStatusError;
            self.mediaStreamError = error;
            return;
        }
    }   
    
    // Setup data consumer.
    success = [self setupConsumerWithError:&error numberOfSourceImages:numberOfSourceImages];
    if (!success) {
        self.mediaStreamStatus = NSStreamStatusError;
        self.mediaStreamError = error;
        return;
    }

    // Tell receiver stream is successfully open
    self.mediaStreamStatus = NSStreamStatusOpen;
    return;
}

- (void)close
{
    if (self.mediaStreamStatus == NSStreamStatusClosed) {
        return;
    }
    
    if (self.mediaStreamStatus == NSStreamStatusReading) {
        // Close the stream gracefully.
        self.numberOfBytesRequested = 0;
        ATLMediaInputStreamLog(@"closing stream...");
    }
    // Release Image I/O references
    if (_destination != NULL) {
        CFRelease(_destination);
        _destination = NULL;
    }
    if (_consumer != NULL) {
        CGDataConsumerRelease(_consumer);
        _consumer = NULL;
    }
    if (_source != NULL) {
        CFRelease(_source);
        _source = NULL;
    }
    if (_provider != NULL) {
        CGDataProviderRelease(_provider);
        _provider = NULL;
    }
    self.asset = nil;
    self.assetLibrary = nil;
    // Signal any ongoing requests.
    dispatch_semaphore_signal(self.streamFlowRequesterSemaphore);
    self.mediaStreamStatus = NSStreamStatusClosed;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)bytesToConsume
{
    if (self.mediaStreamStatus == NSStreamStatusOpen) {
        [self startConsumption];
    }
    
    // If already completed
    if (self.mediaStreamStatus == NSStreamStatusAtEnd) {
        return 0; // EOS
    }
    
    // Cannot provide data, if not in reading state.
    if (self.mediaStreamStatus != NSStreamStatusReading) {
        return -1; // Operation fails
    }

    // Setting the data stream request.
    ATLMediaInputStreamLog(@"input stream: requesting %lu of bytes", bytesToConsume);
    self.numberOfBytesRequested = bytesToConsume;
    
    // Notify data provider that request is ready.
    dispatch_semaphore_signal(self.streamFlowProviderSemaphore);
    
    // Wait for the response.
    ATLMediaInputStreamLog(@"input stream: waiting for cosumer to prepare data");
    dispatch_semaphore_wait(self.streamFlowRequesterSemaphore, DISPATCH_TIME_FOREVER);
    
    if (self.mediaStreamStatus == NSStreamStatusError) {
        return -1; // Operation failed, see self.streamError;
    }

    // Copy the consumed image data to `buffer`.
    [self.dataConsumed getBytes:buffer];
    ATLMediaInputStreamLog(@"input stream: passed data to receiver");
    
    // Clear transfer buffer.
    NSInteger bytesConsumed = self.dataConsumed.length;
    self.dataConsumed = [NSData data];
    return bytesConsumed;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Method %@ on %@ not implemented", NSStringFromSelector(@selector(getBuffer:length:)), self.class] userInfo:nil];
}

#pragma mark - Private Methods

- (void)startConsumption
{
    dispatch_sync(self.transferBufferSerialGuard, ^{
        self.mediaStreamStatus = NSStreamStatusReading;
        dispatch_async(self.consumerAsyncQueue, ^{
            // This will cause the Image I/O consumer to start transfering
            // image data on a async queue.
            ATLMediaInputStreamLog(@"input stream: starting the consumer...");
            BOOL success;
            success = CGImageDestinationFinalize(self.destination);
            if (!success) {
                self.mediaStreamError = [NSError errorWithDomain:ATLMediaInputStreamErrorDomain code:ATLMediaInputStreamErrorFailedFinalizingDestination userInfo:nil];
                ATLMediaInputStreamLog(@"input stream failed to finalize image destination with %@", self.mediaStreamError);
            }
            ATLMediaInputStreamLog(@"input stream: stopping the consumer...");
            
            // Notify requester that consumer is done.
            dispatch_semaphore_signal(self.streamFlowRequesterSemaphore);
            if (!success) {
                self.mediaStreamStatus = NSStreamStatusError;
            } else {
                self.mediaStreamStatus = NSStreamStatusAtEnd;
            }
        });
    });
}

/**
 @abstract Prepares the CGDataProvider which slurps data directly from the ALAsset based on the self.assetURL defined at init.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return Returns the number of images that source will provide if the setup was successful; On failures, method sets the `error` and returns `0`.
 */
- (NSInteger)setupProviderForAssetStreamingWithError:(NSError **)error
{
    // Creating the asset library that needs to be alive during transfer.
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Retrieve the asset, based on the URL (blocking method).
    NSError *assetFetchError;
    self.asset = ATLMediaInputStreamAssetForAssetURL(self.sourceAssetURL, self.assetLibrary, &assetFetchError);
    if (!self.asset) {
        if (error) {
            *error = assetFetchError;
        }
        return NO;
    }
    
    // Setting up source-reader (provider) that will grab data from the
    // ALAssetRepresentation using the callbacks.
    self.assetRepresentation = [self.asset defaultRepresentation];
    CGDataProviderDirectCallbacks dataProviderCallbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = ATLMediaInputStreamGetBytesFromAssetCallback,
        .releaseInfo = NULL
    };
    _provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(self), [self.assetRepresentation size], &dataProviderCallbacks);
    _source = CGImageSourceCreateWithDataProvider(_provider, NULL);
    if (self.provider == NULL || self.source == NULL) {
        if (error) {
            *error = [NSError errorWithDomain:ATLMediaInputStreamErrorDomain code:ATLMediaInputStreamErrorFailedInitializingAssetProvider userInfo:@{ NSLocalizedDescriptionKey: @"Failed initializing the Quartz image data provider/source pair." }];
        }
        return 0;
    }
    
    // There should be at least one image found in the source.
    size_t count = CGImageSourceGetCount(_source);
    if (count <= 0) {
        if (error) {
            *error = [NSError errorWithDomain:ATLMediaInputStreamErrorDomain code:ATLMediaInputStreamErrorAssetHasNoImages userInfo:@{ NSLocalizedDescriptionKey: @"Failed initializing the Quartz image data provider/source, because source asset doesn't include any images." }];
        }
        return 0;
    }
    
    // Get source image's properties, because we'll copy it to the destination later.
    self.sourceImageProperties = (__bridge NSDictionary *)(CGImageSourceCopyProperties(_source, NULL));
    return count;
}

/**
 @abstract Takes the content of the self.sourceAssetURL (ALAssetRepresentation) or sourceImage (UIImage) and resamples the image back into self.sourceImage.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return Returns `YES` if setup was successful; On failures, method sets the `error` and returns `NO`.
 @note This method is only meant for devices running iOS7.1 or lower.
 */
- (BOOL)setupiOS7SpecificConsumerPrerequisite:(NSError **)error
{
    if (self.maximumSize > 0 && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) {
        CFDataRef cfDataPNGRepresentation;
        if (!self.sourceAssetURL && self.sourceImage) {
            // In case the we need to resample an UIImage (which might be
            // coming from the camera picker or pasteboard).
            NSData *dataWithPNGRepresentation = UIImagePNGRepresentation(self.sourceImage);
            cfDataPNGRepresentation = (__bridge CFDataRef)dataWithPNGRepresentation;
            _provider = CGDataProviderCreateWithCFData(cfDataPNGRepresentation);
            _source = CGImageSourceCreateWithDataProvider(_provider, NULL);
        }
        // Resample the image data.
        NSDictionary *thumbnailOptions = @{ (NSString *)kCGImageSourceCreateThumbnailFromImageIfAbsent : @YES, // Demand resampling, even if it doesn't exist in cache.
                                            (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES, // Demand resampling, even if the image does exist in cache (which is probably not in size we want).
                                            (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES, // Rotate the image in correct orientation in the resampled output.
                                            (NSString *)kCGImageSourceThumbnailMaxPixelSize : @(self.maximumSize) };
        CGImageRef thumbnailCGImage = CGImageSourceCreateThumbnailAtIndex(self.source, 0, (__bridge CFDictionaryRef)thumbnailOptions);
        if (thumbnailCGImage == NULL) {
            if (error) {
                *error = [NSError errorWithDomain:ATLMediaInputStreamErrorDomain code:ATLMediaInputStreamErrorFailedInitializingAssetProvider userInfo:@{ NSLocalizedDescriptionKey: @"Failed creating resampled image using CGImageSourceCreateThumbnailAtIndex." }];
            }
            return NO;
        }
        self.sourceImage = [UIImage imageWithCGImage:thumbnailCGImage];
        CGImageRelease(thumbnailCGImage);
    }
    return YES;
}

/**
 @abstract Prepares the CGDataConsumer which provides data to the stream.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return Returns `YES` if setup was successful; On failures, method sets the `error` and returns `NO`.
 */
- (BOOL)setupConsumerWithError:(NSError **)error numberOfSourceImages:(NSInteger)numberOfSourceImages
{
    // Setting up destination-writer (consumer).
    CGDataConsumerCallbacks dataConsumerCallbacks = {
        .putBytes = ATLMediaInputStreamPutBytesIntoStreamCallback,
        .releaseConsumer = NULL
    };
    _consumer = CGDataConsumerCreate((void *)CFBridgingRetain(self), &dataConsumerCallbacks);
    if (self.assetRepresentation) {
        // In case source is the ALAsset.
        _destination = CGImageDestinationCreateWithDataConsumer(_consumer, (CFStringRef)self.assetRepresentation.UTI, numberOfSourceImages, NULL);
    } else {
        // In case source is the UIImage.
        _destination = CGImageDestinationCreateWithDataConsumer(_consumer, kUTTypeJPEG, 1, NULL);
    }

    if (_consumer == NULL || _destination == NULL) {
        if (error) {
            *error = [NSError errorWithDomain:ATLMediaInputStreamErrorDomain code:ATLMediaInputStreamErrorFailedInitializingImageIOConsumer userInfo:nil];
        }
        return NO;
    }
    
    NSMutableDictionary *destinationOptions = self.metadata ? [self.metadata mutableCopy] : [NSMutableDictionary dictionary];
    if (self.maximumSize > 0) {
        // Resample image if requested.
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
            // Unfortunately, this feature is only available on iOS8+. If we're
            // on <= iOS7.1, image had to be resampled beforehand (see setupiOS7SpecificConsumerPrerequisite:).
            [destinationOptions setObject:@(self.maximumSize) forKey:(NSString *)kCGImageDestinationImageMaxPixelSize];
        }
    }
    if (self.compressionQuality > 0) {
        // If image should only be compressed.
        [destinationOptions setObject:@(self.compressionQuality) forKey:(NSString *)kCGImageDestinationLossyCompressionQuality];
    }
    if (self.metadata && self.metadata[ATLMediaInputStreamAppleCameraTIFFOptionsKey] && self.metadata[(NSString *)kCGImagePropertyOrientation]) {
        NSMutableDictionary *mutableTiffDict = [self.metadata[ATLMediaInputStreamAppleCameraTIFFOptionsKey] mutableCopy];
        [mutableTiffDict setObject:self.metadata[(NSString *)kCGImagePropertyOrientation] forKey:(NSString *)kCGImagePropertyTIFFOrientation];
        [destinationOptions setObject:mutableTiffDict forKey:ATLMediaInputStreamAppleCameraTIFFOptionsKey];
    }
    if (self.assetRepresentation) {
        for (NSInteger idx=0; idx<numberOfSourceImages; idx++) {
            CGImageDestinationAddImageFromSource(_destination, self.source, idx, (__bridge CFDictionaryRef)destinationOptions);
        }
    } else {
        CGImageDestinationAddImage(_destination, self.sourceImage.CGImage, (__bridge CFDictionaryRef)destinationOptions);
    }
    // Apply the image properties (we took from the source earlier) onto destination.
    if (self.sourceImageProperties) {
        CGImageDestinationSetProperties(_destination, (__bridge CFDictionaryRef)self.sourceImageProperties);
    }
    return YES;
}

@end

#pragma mark - Image I/O Callback Implementation

ALAsset *ATLMediaInputStreamAssetForAssetURL(NSURL *assetURL, ALAssetsLibrary *assetLibrary, NSError **error)
{
    static dispatch_queue_t asyncQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        asyncQueue = dispatch_queue_create(ATLMediaInputStreamAsyncToBlockingQueueName, DISPATCH_QUEUE_CONCURRENT);
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
                } failureBlock:^(NSError *libraryError) {
                    if (libraryError) {
                        *error = libraryError;
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
            }
        } failureBlock:^(NSError *libraryError) {
            if (libraryError) {
                *error = libraryError;
            }
            dispatch_semaphore_signal(semaphore);
        }];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return resultAsset;
}

static size_t ATLMediaInputStreamGetBytesFromAssetCallback(void *assetStreamRef, void *buffer, off_t offset, size_t length)
{
    ATLMediaInputStream *assetStream = (__bridge ATLMediaInputStream *)assetStreamRef;
    NSError *error = nil;
    size_t bytesRead = [assetStream.assetRepresentation getBytes:(uint8_t *)buffer fromOffset:offset length:length error:&error];
    if (bytesRead == 0 && error) {
        ATLMediaInputStreamLog(@"provider: failed reading bytes from the assetRepresentation=%@ with %@", assetStream.assetRepresentation, error);
    } else {
        ATLMediaInputStreamLog(@"provider: provided %lu bytes", length);
    }
    return bytesRead;
}

static size_t ATLMediaInputStreamPutBytesIntoStreamCallback(void *assetStreamRef, const void *buffer, size_t length)
{
    ATLMediaInputStream *assetStream = (__bridge ATLMediaInputStream *)assetStreamRef;
    
    // Consumption continues, after flow control logic in readBytes:len: signals it.
    dispatch_sync(assetStream.transferBufferSerialGuard, ^{
        ATLMediaInputStreamLog(@"consumer: waiting for request from stream (have %lu bytes ready)", length);
        dispatch_semaphore_wait(assetStream.streamFlowProviderSemaphore, DISPATCH_TIME_FOREVER);
    });
    
    // Copy buffer into NSData that was consumed by Image I/O process.
    NSUInteger bytesConsumed = MIN(assetStream.numberOfBytesRequested, length);
    NSData *dataConsumed = [NSData dataWithBytes:buffer length:bytesConsumed];
    assetStream.dataConsumed = dataConsumed;
    ATLMediaInputStreamLog(@"consumer: consumed %lu bytes (requested %lu bytes, provided %lu bytes)", (unsigned long)dataConsumed.length, (unsigned long)assetStream.numberOfBytesRequested, length);
    
    // Signal the requester data is ready for consumption.
    dispatch_semaphore_signal(assetStream.streamFlowRequesterSemaphore);
    ATLMediaInputStreamLog(@"return %lu", (unsigned long)bytesConsumed);
    return bytesConsumed;
}
