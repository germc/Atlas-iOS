//
//  ATLUIOutgoingMessageCollectionViewCell.m
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

#import "ATLOutgoingMessageCollectionViewCell.h"

@implementation ATLOutgoingMessageCollectionViewCell

NSString *const ATLOutgoingMessageCellIdentifier = @"ATLOutgoingMessageCellIdentifier";

+ (void)initialize
{
    ATLOutgoingMessageCollectionViewCell *proxy = [self appearance];
    proxy.bubbleViewColor = ATLBlueColor();
    proxy.messageTextColor = [UIColor whiteColor];
    proxy.messageLinkTextColor = [UIColor whiteColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lyr_outgoingCommonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self lyr_outgoingCommonInit];
    }
    return self;
}

- (void)lyr_outgoingCommonInit
{
    self.avatarImageView.hidden = YES;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView  attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-ATLMessageCellHorizontalMargin]];
}

@end
