//
//  ATLUIConversationCollectionViewHeader.h
//  Atlas
//
//  Created by Kevin Coleman on 9/10/14.
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

@class LYRMessage;

extern NSString *const ATLConversationViewHeaderIdentifier;

/**
 @abstract The `ATLConversationCollectionViewHeader` class provides support for displaying
 dates and sender names above message cells.
 */
@interface ATLConversationCollectionViewHeader : UICollectionReusableView

/**
 @abstract The message associated with the header.
 */
@property (nonatomic) LYRMessage *message;

/**
 @abstract The font for the participant label displayed in the header. Default is 10pt system font.
 */
@property (nonatomic) UIFont *participantLabelFont UI_APPEARANCE_SELECTOR;

/**
 @abstract The text color for the participant label displayed in the header. Default is gray.
 */
@property (nonatomic) UIColor *participantLabelTextColor UI_APPEARANCE_SELECTOR;

/**
 @abstract Displays a string of text representing a participant. The string will be horizontally aligned with
 the left edge of the message bubble view.
 @param participantName The string of text to be displayed.
 */
- (void)updateWithParticipantName:(NSString *)participantName;

/**
 @abstract Displays a string of text representing a date. The string is horizontally centered in the view.
 @param date The date string to be displayed.
 */
- (void)updateWithAttributedStringForDate:(NSAttributedString *)date;

/**
 @abstract Performs calculations to determine the header height.
 @param dateString An `NSAttributedString` containing attributes that will be used in the calculation.
 @param participantName An `NSString` to which UIAppearance defaults will be applied and used in the calculation.
 @param view The superview for the header.
 @return The height for the header.
 */
+ (CGFloat)headerHeightWithDateString:(NSAttributedString *)dateString participantName:(NSString *)participantName inView:(UIView *)view;

@end
