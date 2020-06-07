//
//  ATLUIAvatarItem.h
//  Atlas 
//
//  Created by Kevin Coleman on 1/30/15.
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

#import <UIKit/UIKit.h>

/**
 @abstract Objects conforming to the `ATLAvatarItem` protocol will be used to display images or
 initials in a `ATLAvatarImageView`.  The objects can return `nil` if they do not want to use the
 specific property.
 */
@protocol ATLAvatarItem <NSObject>

/**
 @abstract Returns the image URL for an avatar image for the receiver.
 */
@property (nonatomic, readonly) NSURL *avatarImageURL;

/**
 @abstract Returns the avatar image of the receiver.
 */
@property (nonatomic, readonly) UIImage *avatarImage;

/** 
 @abstract Returns the avatar initials of the receiver.
 */
@property (nonatomic, readonly) NSString *avatarInitials;

@end
