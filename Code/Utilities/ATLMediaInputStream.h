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
};

/**
 @abstract The `ATLMediaInputStream` class is responsible for streaming
 media content to the receiver.
           
 It provides direct (lossless) content streaming or resampled and compressed
 image streaming. Depending on the input source, which can be either
 an `ALAsset` URL or an `UIImage`, streaming, resampling and compression will
 be performed without bringing the full image data into the memory.
 
 @discussion Compression and resampling are enabled with setting the
 `compressionQuality` and `maximumSize` respectively.
            
 If setting the `maximumSize = 0` and `compressionQuality = 0.0f`, media content
 will be directly transferred from the `ALAsset` or `UIImage`, depending
 on the source. Property `isLossless` indicates if the streaming
 will be lossless.
 
 @warning `ATLMediaInputStream` is GCD based and doesn't utilize `NSRunLoops`.
 It may be unrealiable, if paired with a network stream.
 */
@interface ATLMediaInputStream : NSInputStream

/**
 @abstract Creates an input stream capable of direct streaming of an ALAsset's content.
 @param assetURL `NSURL` path of the asset (URL starts with `asset://`) that will be serialized for streaming.
 @return A `ATLMediaInputStream` instance ready to be open.
 */
+ (instancetype)mediaInputStreamWithAssetURL:(NSURL *)assetURL;

/**
 @abstract Creates an input stream capable of direct streaming of the UIImage's content.
 @param image `UIImage` instance that will be serialized for streaming.
 @param metadata A `NSDictionary` of metadata that will be attached in the serialized data. Passing `nil` won't attach any metadata to the serialized image.
 @return A `ATLMediaInputStream` instance ready to be open.
 */
+ (instancetype)mediaInputStreamWithImage:(UIImage *)image metadata:(NSDictionary *)metadata;

/**
 @abstract The source media asset in a form of an `NSURL`.
 */
@property (nonatomic, readonly) NSURL *sourceAssetURL;

/**
 @abstract The source media in a form of an `UIImage`.
 */
@property (nonatomic, readonly) UIImage *sourceImage;

/**
 @abstract A boolean value indicating if streaming is going to be lossless.
 */
@property (nonatomic, readonly) BOOL isLossless;

/**
 @abstract The size in pixels of the output image when being streamed. Default is set to 0.
 @discussion If set to zero `0`, resampling is disabled.
 */
@property (nonatomic) NSUInteger maximumSize;

/**
 @abstract The compression quality in percent. Default is set to 0.0f.
 @discussion 1.0f sets the quality to 100% which preserves details in images,
 but also makes a larger output. 0.1f sets the quality to 10% which
 is the lowest quality, and makes the file size smaller.
             
 Setting the property value to zero `0.0f` will disable compression.
 */
@property (nonatomic) float compressionQuality;

@end
