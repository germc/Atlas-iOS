//
//  ATLUIImageHelper.h
//  Pods
//
//  Created by Kabir Mahal on 3/18/15.
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

/**
 @abstract Processes GIFs by finding frame count and duration and returns an auto-looping GIF
 @param data The NSData instance that should be returned as a looping GIF
 @return Returns a UIImage instance that has a looping GIF.  Can be used with any UIImageView
 */
UIImage *ATLAnimatedImageWithAnimatedGIFData(NSData *data);

/**
 @abstract Processes GIFs by finding frame count and duration and returns an auto-looping GIF
 @param url The NSURL instance that should be returned as a looping GIF
 @return Returns a UIImage instance that has a looping GIF.  Can be used with any UIImageView
 */
 UIImage *ATLAnimatedImageWithAnimatedGIFURL(NSURL *url);