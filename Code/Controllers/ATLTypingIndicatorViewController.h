//
//  ATLUITypingIndicatorViewController.h
//  Atlas
//
//  Created by Kevin Coleman on 11/11/14.
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
 @abstract Displays a simple typing indicator view with a list of participant names.
 */
@interface ATLTypingIndicatorViewController : UIViewController

/**
 @abstract Updates the typing indicator with an array of participants currently typing. 
 @param participants The participants currently typing in a conversation.
 @param animated A boolean value to determine if the typing indicator should animate its opacity.
 @discussion If an empty array is supplied, the typing indicator opacity will be set to 0.0. If
 a non-empty array is supplied, the opacity will be set to 1.0.
 */
- (void)updateWithParticipants:(NSOrderedSet *)participants animated:(BOOL)animated;

@end
