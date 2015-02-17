//
//  ATLMediaInputStream.h
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

#ifdef DEBUG_ATLMediaInputStreamLog
#define ATLMediaInputStreamLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#define ATLMediaInputStreamLog(fmt, ... )
#endif

NSString *const ATLMediaInputStreamErrorDomain = @"com.layer.Atlas.ATLMediaInputStream";
static char const ATLMediaInputConsumerAsyncQueueName[] = "com.layer.Atlas.ATLMediaInputStream.asyncConsumerQueue";
static char const ATLMediaInputConsumerSerialTransferQueueName[] = "com.layer.Atlas.ATLMediaInputStream.serialTransferQueue";

/* Core I/O callbacks */
ALAsset *ATLMediaInputStreamAssetForAssetURL(NSURL *assetURL, ALAssetsLibrary *assetLibrary, NSError **error);
static size_t ATLMediaInputStreamGetBytesFromAssetCallback(void *assetStreamRef, void *buffer, off_t offset, size_t length);
static size_t ATLMediaInputStreamPutBytesIntoStreamCallback(void *assetStreamRef, const void *buffer, size_t length);
static void ATLMediaInputStreamReleaseAssetCallback(void *assetStreamRef);
static void ATLMediaInputStreamReleaseStreamCallback(void *assetStreamRef);

@interface ATLMediaInputStream ()

/* Private and public properties */
@property (nonatomic, readwrite) NSURL *assetURL;
@property (nonatomic, readwrite) UIImage *image;
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
@property (nonatomic) CGDataProviderRef provider;
@property (nonatomic) CGImageSourceRef source;
@property (nonatomic) CGDataConsumerRef consumer;
@property (nonatomic) CGImageDestinationRef destination;

@end

@implementation ATLMediaInputStream

#pragma mark - Initializers

- (instancetype)initWithAssetURL:(NSURL *)assetURL
{
    self = [super init];
    if (self) {
        if (!assetURL) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Cannot initialize %@ with `nil` assetURL.", self.class] userInfo:nil];
        }
        _assetURL = assetURL;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        if (!image) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Cannot initialize %@ with `nil` image.", self.class] userInfo:nil];
        }
        _image = image;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _mediaStreamStatus = NSStreamStatusNotOpen;
    _mediaStreamError = nil;
    _dataConsumed = [NSData data];
    _numberOfBytesRequested = 0;
    _numberOfBytesProvided = 0;
    _streamFlowRequesterSemaphore = dispatch_semaphore_create(0);
    _streamFlowProviderSemaphore = dispatch_semaphore_create(0);
    _consumerAsyncQueue = dispatch_queue_create(ATLMediaInputConsumerAsyncQueueName, DISPATCH_QUEUE_CONCURRENT);
    _transferBufferSerialGuard = dispatch_queue_create(ATLMediaInputConsumerSerialTransferQueueName, DISPATCH_QUEUE_SERIAL);
    [self updateIsLossless];
}

+ (id)mediaInputStreamWithAssetURL:(NSURL *)assetURL
{
    return [[self alloc] initWithAssetURL:assetURL];
}

+ (id)mediaInputStreamWithImage:(UIImage *)image
{
    return [[self alloc] initWithImage:image];
}

- (void)dealloc
{
    if (self.streamStatus != NSStreamStatusClosed) {
        [self close];
    }
}

#pragma mark - Public Accessors

- (void)setMaximumSize:(NSUInteger)maximumSize
{
    _maximumSize = maximumSize;
    [self updateIsLossless];
}

- (void)setCompressionQuality:(float)compressionQuality
{
    _compressionQuality = compressionQuality;
    [self updateIsLossless];
}

- (void)updateIsLossless
{
    if (self.maximumSize == 0 && self.compressionQuality == 0.0f) {
        // If the transfer is going to be lossless.
        self.isLossless = YES;
    } else {
        // If the transfer includes re-sampling and compression.
        self.isLossless = NO;
    }
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
    BOOL success;
    NSError *error;
    if (self.assetURL) {
        success = [self setupProviderForAssetStreamingWithError:&error];
    } else if (self.image) {
        success = [self setupProviderForImageDataStreamingWithError:&error];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed setting up data provider because source media not defined." userInfo:nil];
    }
    if (!success) {
        self.mediaStreamStatus = NSStreamStatusError;
        self.mediaStreamError = error;
        return;
    }
    
    // Setup data consumer.
    success = [self setupConsumerWithError:&error];
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
    if (self.mediaStreamStatus == NSStreamStatusReading) {
        // Close the stream gracefully.
        self.numberOfBytesRequested = 0;
        ATLMediaInputStreamLog(@"closing stream...");
    }
    // Release Image I/O references
    if (self.destination) {
        CFRelease(self.destination);
    }
    if (self.consumer) {
        CFRelease(self.consumer);
    }
    if (self.source) {
        CFRelease(self.source);
    }
    if (self.provider) {
        CFRelease(self.provider);
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
            if (self.isLossless) {
                CFErrorRef error;
                success = CGImageDestinationCopyImageSource(self.destination, self.source, NULL, &error);
                if (!success) {
                    self.mediaStreamError = (__bridge NSError *)error;
                }
            } else {
                success = CGImageDestinationFinalize(self.destination);
                if (!success) {
                    self.mediaStreamError = [NSError errorWithDomain:ATLMediaInputStreamErrorDomain code:ATLMediaInputStreamErrorFailedFinalizingDestination userInfo:nil];
                }
            }
            ATLMediaInputStreamLog(@"input stream: stopping the consumer...");
            
            // Notify requester that consumer is done.
            dispatch_semaphore_signal(self.streamFlowRequesterSemaphore);
            self.mediaStreamStatus = NSStreamStatusAtEnd;
        });
    });
}

/**
 @abstract Prepares the CGDataProvider which slurps data directly from the ALAsset based on the self.assetURL defined at init.
 @return Returns `YES` if setup was successful; On failures, method sets the `error` and returns `NO`.
 */
- (BOOL)setupProviderForAssetStreamingWithError:(NSError **)error
{
    // Creating the asset library that needs to be alive during transfer.
    self.assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // Retrieve the asset, based on the URL (blocking method).
    NSError *assetFetchError;
    self.asset = ATLMediaInputStreamAssetForAssetURL(self.assetURL, self.assetLibrary, &assetFetchError);
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
        .releaseInfo = ATLMediaInputStreamReleaseAssetCallback,
    };
    self.provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(self), [self.assetRepresentation size], &dataProviderCallbacks);
    self.source = CGImageSourceCreateWithDataProvider(self.provider, NULL);
    if (self.provider == NULL || self.source == NULL) {
        if (error) {
            *error = [NSError errorWithDomain:ATLMediaInputStreamErrorDomain code:ATLMediaInputStreamErrorFailedInitializingAssetProvider userInfo:nil];
        }
        return NO;
    }
    
    // There should be at least one image found in the source.
    size_t count = CGImageSourceGetCount(self.source);
    if (count <= 0) {
        if (error) {
            *error = [NSError errorWithDomain:ATLMediaInputStreamErrorDomain code:ATLMediaInputStreamErrorAssetHasNoImages userInfo:nil];
        }
        return NO;
    }
    return YES;
}

/**
 @abstract Prepares the CGDataProvider which slurps data directly from the UIImage based on the self.image defined at init.
 @return Returns `YES` if setup was successful; On failures, method sets the `error` and returns `NO`.
 */
- (BOOL)setupProviderForImageDataStreamingWithError:(NSError **)error
{
    // Setting up source-reader (provider) that will grab data from the `UIImage`.
    self.provider = CGImageGetDataProvider(self.image.CGImage);
    self.source = CGImageSourceCreateWithDataProvider(self.provider, NULL);
    if (self.provider == NULL || self.source == NULL) {
        if (error) {
            *error = [NSError errorWithDomain:ATLMediaInputStreamErrorDomain code:ATLMediaInputStreamErrorFailedInitializingAssetProvider userInfo:nil];
        }
        return NO;
    }
    return YES;
}

/**
 @abstract Prepares the CGDataConsumer which provides data to the stream.
 @return Returns `YES` if setup was successful; On failures, method sets the `error` and returns `NO`.
 */
- (BOOL)setupConsumerWithError:(NSError **)error
{
    // Setting up destination-writer (consumer).
    CGDataConsumerCallbacks dataConsumerCallbacks = {
        .putBytes = ATLMediaInputStreamPutBytesIntoStreamCallback,
        .releaseConsumer = ATLMediaInputStreamReleaseStreamCallback,
    };
    self.consumer = CGDataConsumerCreate((void *)CFBridgingRetain(self), &dataConsumerCallbacks);
    self.destination = CGImageDestinationCreateWithDataConsumer(self.consumer, (CFStringRef)self.assetRepresentation.UTI, 1, NULL);
    if (self.consumer == NULL || self.destination == NULL) {
        if (error) {
            *error = [NSError errorWithDomain:ATLMediaInputStreamErrorDomain code:ATLMediaInputStreamErrorFailedInitializingImageIOConsumer userInfo:nil];
        }
        return NO;
    }
    
    NSDictionary *compressionConfiguration = @{ };
    if (self.maximumSize > 0 && self.compressionQuality > 0) {
        // If image should be resampled and compressed.
        compressionConfiguration = @{ (NSString *)kCGImageDestinationLossyCompressionQuality : @(self.compressionQuality),
                                      (NSString *)kCGImageDestinationImageMaxPixelSize : @(self.maximumSize) };
    } else if (self.maximumSize > 0 && self.compressionQuality == 0) {
        // If image should only be resampled.
        compressionConfiguration = @{ (NSString *)kCGImageDestinationImageMaxPixelSize : @(self.maximumSize) };
    } else if (self.maximumSize == 0 && self.compressionQuality > 0) {
        // If image should only be compressed.
        compressionConfiguration = @{ (NSString *)kCGImageDestinationLossyCompressionQuality : @(self.compressionQuality) };
    }
    CGImageDestinationAddImageFromSource(self.destination, self.source, 0, (__bridge CFDictionaryRef)compressionConfiguration);
    return YES;
}

@end

#pragma mark - Image I/O Callback Implementation

ALAsset *ATLMediaInputStreamAssetForAssetURL(NSURL *assetURL, ALAssetsLibrary *assetLibrary, NSError **error)
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_queue_t asyncQueue = dispatch_queue_create("com.layer.ATLAssetTestObtainLastImage.async", DISPATCH_QUEUE_CONCURRENT);
    __block ALAsset *resultAsset;
    dispatch_async(asyncQueue, ^{
        [assetLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            resultAsset = asset;
            dispatch_semaphore_signal(semaphore);
        } failureBlock:^(NSError *libraryError) {
            if (error) {
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

static void ATLMediaInputStreamReleaseAssetCallback(void *assetStreamRef)
{
    CFRelease(assetStreamRef);
}

static size_t ATLMediaInputStreamPutBytesIntoStreamCallback(void *assetStreamRef, const void *buffer, size_t length)
{
    ATLMediaInputStream *assetStream = (__bridge ATLMediaInputStream *)assetStreamRef;
    
    // Consumption continues, after flow control logic in readBytes:len: signals it.
    dispatch_sync(assetStream.transferBufferSerialGuard, ^{
        ATLMediaInputStreamLog(@"consumer: waiting for request from stream");
        dispatch_semaphore_wait(assetStream.streamFlowProviderSemaphore, DISPATCH_TIME_FOREVER);
    });
    
    // Copy buffer into NSData that was consumed by Image I/O process.
    NSData *dataConsumed = [NSData dataWithBytes:buffer length:MIN(assetStream.numberOfBytesRequested, length)];
    assetStream.dataConsumed = dataConsumed;
    ATLMediaInputStreamLog(@"consumer: consumed %lu bytes (requested %lu bytes)", dataConsumed.length, assetStream.numberOfBytesRequested);
    
    // Signal the requester data is ready for consumption.
    dispatch_semaphore_signal(assetStream.streamFlowRequesterSemaphore);
    return assetStream.dataConsumed.length;
}

static void ATLMediaInputStreamReleaseStreamCallback(void *assetStreamRef)
{
    CFRelease(assetStreamRef);
}
