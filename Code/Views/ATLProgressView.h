//
//  ATLUIProgressView.h
//  Atlas
//
//  Created by Klemen Verdnik on 1/17/15.
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

/**
 @abstract A custom progress view that displays the progress in a circular
 shape. It includes two visual components: a subtle transparent background 
 ring as a placeholder and a foreground ring representing the current
 progress state.
 
 Progress changes can be animated using the `setProgress:animated:` method
 where a `YES` value has to be passed as the `animated` argument.
 */
@interface ATLProgressView : UIView

/**
 @abstract Progress in percentage, 0.0f being at 0% and 1.0f being at full 100%.
 @discussion Use `setProgress:animated:` to set the progress's value.
 */
@property (nonatomic, readonly) float progress;

/**
 @abstract Sets the `progress` float value.
 @param newProgress The value the progress will be set to.
 @param animated Pass `YES` to animate the progress change, or `NO` to do an immediate update.
 */
- (void)setProgress:(float)newProgress animated:(BOOL)animated;

@end
