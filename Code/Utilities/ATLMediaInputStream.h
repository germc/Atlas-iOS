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

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

extern NSString *const ATLMediaInputStreamErrorDomain;

typedef NS_ENUM(NSUInteger, ATLMediaInputStreamError) {
    /**
     @abstract An error to open stream if initializing asset provider failed.
     */
    ATLMediaInputStreamErrorFailedInitializingAssetProvider        = 1000,
    /**
     @abstract An error to open stream if initializing asset consumer failed.
     */
    ATLMediaInputStreamErrorFailedInitializingImageIOConsumer      = 1001,
    /**
     @abstract An error to open stream if initializing asset destination failed.
     */
    ATLMediaInputStreamErrorFailedFinalizingDestination            = 1002,
    /**
     @abstract An error to open stream if the source asset doesn't contain any items.
     */
    ATLMediaInputStreamErrorAssetHasNoImages                       = 1003,
    /**
     @abstract An error to open stream when device doesn't have any compatible export presets.
     */
    ATLMediaInputStreamErrorNoVideoExportPresetsAvailable          = 1004,
    /**
     @abstract An error during video export process.
     */
    ATLMediaInputStreamErrorVideoExportFailed                      = 1005,
};

/**
 @abstract The `ATLMediaInputStream` class is responsible for streaming
   media content to the receiver.
 
   It provides direct (lossless) content streaming or resampled and compressed
   image streaming. Depending on the input source, which can be either
   an `ALAsset` URL, an `UIImage` or a direct file URL, streaming, resampling
   and encoding will be performed without bringing the full media data
   into the memory.
 
 @discussion Media encoding and resampling are enabled by setting the
   `compressionQuality` and `maximumSize` respectively.
 
   If setting the `maximumSize = 0` and `compressionQuality = 0.0f`, media content
   will be directly transferred from the `ALAsset`, `UIImage` or `fileURL`,
   depending on the source. Property `isLossless` indicates the streaming
   will be lossless.
 
 @warning `ATLMediaInputStream` is GCD based and doesn't utilize `NSRunLoops`.
   It may be unrealiable, if paired with a network stream.
 */
@interface ATLMediaInputStream : NSInputStream

/**
 @abstract Creates an input stream capable of direct or re-encoded streaming
   of an ALAsset's content.
 @param assetURL `NSURL` path of the asset (URL starts with `asset://`) that
   will be serialized for streaming.
 @return A `ATLMediaInputStream` instance ready to be open.
 */
+ (instancetype)mediaInputStreamWithAssetURL:(NSURL *)assetURL;

/**
 @abstract Creates an input stream capable of direct or re-encoded streaming
   of the UIImage's content.
 @param image `UIImage` instance that will be serialized for streaming.
 @param metadata A `NSDictionary` of metadata that will be embedded into the
   image. Passing `nil` won't embed any metadata information.
 @return A `ATLMediaInputStream` instance ready to be open.
 */
+ (instancetype)mediaInputStreamWithImage:(UIImage *)image metadata:(NSDictionary *)metadata;

/**
 @abstract Creates an input stream capable of direct or re-encoded media
   streaming from the file system.
 @param fileURL File URL path to the media content (URL starts with `file://`).
 @return A `ATLMediaInputStream` instance ready to be open.
 @discussion The input stream will attempt to preserve any embedded
   metadata information of the media content.
 */
+ (instancetype)mediaInputStreamWithFileURL:(NSURL *)fileURL;

/**
 @abstract The source media asset in a form of an `NSURL`.
 @discussion Set only when input stream is initialized with the `assetURL`,
   otherwise it's `nil`.
 */
@property (nonatomic, readonly) NSURL *sourceAssetURL;

/**
 @abstract The source image in a form of an `UIImage`.
 @discussion Set only when input stream is initialized with the `image`,
   otherwise it's `nil`.
 */
@property (nonatomic, readonly) UIImage *sourceImage;

/**
 @abstract The source media file URL in a form of `NSURL`.
 @discussion Set only when input stream is initialized with the `fileURL`,
   otherwise it's `nil`.
 */
@property (nonatomic, readonly) NSURL *sourceFileURL;

/**
 @abstract A boolean value indicating if streaming is going to be lossless.
 */
@property (nonatomic, readonly) BOOL isLossless;

/**
 @abstract The size in pixels of the output image when being streamed.
   Default is set to 0.
 @discussion If set to zero `0`, resampling is disabled.
 */
@property (nonatomic) NSUInteger maximumSize;

/**
 @abstract The compression quality in percent. Default is set to 0.0f.
 @discussion 1.0f sets the quality to 100% which preserves details in images,
   but also makes a larger output. 0.1f sets the quality to 10% which
   is the lowest quality, and makes the file size smaller.
 @note Setting the property value to zero `0.0f` will disable compression.
 */
@property (nonatomic) float compressionQuality;

@end
