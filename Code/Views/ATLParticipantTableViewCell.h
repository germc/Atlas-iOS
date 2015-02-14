//
//  ATLUIParticipantTableViewCell.h
//  Atlas
//
//  Created by Kevin Coleman on 8/29/14.
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

#import <UIKit/UIKit.h>
#import "ATLParticipantPresenting.h"
#import "ATLParticipant.h"    

/**
 @abstract The `ATLParticipantTableViewCell` class provides a lightweight, customizable table
 view cell for presenting Layer conversation participants.
 */
@interface ATLParticipantTableViewCell : UITableViewCell <ATLParticipantPresenting>

/**
 @abstract The font for the title label displayed in the cell. Default is 14pt system font.
 */
@property (nonatomic) UIFont *titleFont UI_APPEARANCE_SELECTOR;

/**
 @abstract The bold font for the title label displayed in the cell. Default is 14pt bold system font.
 */
@property (nonatomic) UIFont *boldTitleFont UI_APPEARANCE_SELECTOR;

/**
 @abstract The color for the title label displayed in the cell. Default is black.
 */
@property (nonatomic) UIColor *titleColor UI_APPEARANCE_SELECTOR;

@end
