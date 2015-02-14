//
//  ATLUIMessagePresenting.h
//  Atlas
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
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
#import "ATLParticipant.h"
#import <LayerKit/LayerKit.h>

/**
 @abstract The `ATLMessagePresenting` protocol must be adopted by objects wishing to present
 Layer message parts via a user interface.
 */
@protocol ATLMessagePresenting <NSObject>

/**
 @abstract Tells the receiver to display a message.
 */
- (void)presentMessage:(LYRMessage *)message;

/**
 @abstract Informs the receiver of its sender.
 */
- (void)updateWithSender:(id<ATLParticipant>)sender;

/**
 @abstract A boolean to determine whether or not the receiver should display an avatar item.
 */
- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem;

@end
