//
//  ATLUIParticipantSectionHeaderView.h
//  Atlas
//
//  Created by Kevin Coleman on 8/31/14.
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
 @abstract The `ATLParticipantSectionHeaderView` displays a letter representing a section
 in the participant picker.
 */
@interface ATLParticipantSectionHeaderView : UITableViewHeaderFooterView

/**
 @abstract The label displayed in the section header.
 */
@property (nonatomic) UILabel *sectionHeaderLabel;

/**
 @abstract The font for the section header label. Default is 14pt system font.
 */
@property (nonatomic) UIFont *sectionHeaderFont UI_APPEARANCE_SELECTOR;

/**
 @abstract The color for the section header label. Default is black.
 */
@property (nonatomic) UIColor *sectionHeaderTextColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The background color for the section header. Default is `ATLLightGrayColor()`.
 */
@property (nonatomic) UIColor *sectionHeaderBackgroundColor UI_APPEARANCE_SELECTOR;

@end
