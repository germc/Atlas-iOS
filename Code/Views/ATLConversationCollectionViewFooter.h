//
//  ATLUIConversationCollectionViewFooter.h
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

extern NSString *const ATLConversationViewFooterIdentifier;

/**
 @abstract The `ATLConversationCollectionViewFooter` class provides support for displaying
 read receipts below message cells.
 */
@interface ATLConversationCollectionViewFooter : UICollectionReusableView

/**
 @abstract The message associated with the footer.
 */
@property (nonatomic) LYRMessage *message;

/**
 @abstract Displays a string of text representing the read status of a message.
 @param recipientStatus The string representing the status.
 */
- (void)updateWithAttributedStringForRecipientStatus:(NSAttributedString *)recipientStatus;

/**
 @abstract Performs calculations to determine the footer height.
 @param recipientStatus An `NSAttributedString` containing attributes that will be used in the calculation.
 @param clustered A boolean value to determines whether the message cell corresponding to the footer should be clustered with the previous cell. Messages sent within 60 seconds of each other are clustered.
 @return The height for the footer.
 */
+ (CGFloat)footerHeightWithRecipientStatus:(NSAttributedString *)recipientStatus  clustered:(BOOL)clustered;

@end
