//
//  ATLTestUtilities.h
//  Atlas
//
//  Created by Klemen Verdnik on 2/26/15.
//  Copyright (c) 2015 Layer. All rights reserved.
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

/**
 @abstract Reads the stream content into a NSData object.
 @param inputStream Input stream to read the content from.
 @return Returns an `NSData` object containing the content of the stream; or `nil` in case of an error.
 */
NSData *ATLTestAttachmentDataFromStream(NSInputStream *inputStream);

/**
 @abstract Generates a test image with the given size.
 @param size The size of the output image.
 @return An `UIImage` instance.
 */
UIImage *ATLTestAttachmentMakeImageWithSize(CGSize size);

/**
 @abstract Synhchronously grabs the last photo from the Photos Library.
 @param library The library to grab the last photo from.
 @return Returns ALAsset instance of the last image located in the Photos Library, or `nil` in case of a failure.
 */
ALAsset *ATLAssetTestObtainLastImageFromAssetLibrary(ALAssetsLibrary *library);

ALAsset *ATLVideoAssetTestObtainLastVideoFromAssetLibrary(ALAssetsLibrary *library);