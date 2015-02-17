//
//  ATLUIIncomingMessageCollectionViewCell.m
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

#import "ATLIncomingMessageCollectionViewCell.h"

@interface ATLIncomingMessageCollectionViewCell ()

@property (nonatomic) NSLayoutConstraint *bubbleWithAvatarLeftConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithoutAvatarLeftConstraint;

@end

@implementation ATLIncomingMessageCollectionViewCell

NSString *const ATLIncomingMessageCellIdentifier = @"ATLIncomingMessageCellIdentifier";
CGFloat const ATLAvatarImageLeftPadding = 12.0f;
CGFloat const ATLAvatarImageRightPadding = 7.0f;

+ (void)initialize
{
    ATLIncomingMessageCollectionViewCell *proxy = [self appearance];
    proxy.bubbleViewColor = ATLLightGrayColor();
    proxy.messageLinkTextColor = ATLBlueColor();
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lyr_incommingCommonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self lyr_incommingCommonInit];
    }
    return self;
}

- (void)lyr_incommingCommonInit
{
    [self configureConstraintsForIncomingMessage];
}

- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem
{
    NSArray *constraints = [self.contentView constraints];
    if (shouldDisplayAvatarItem) {
        if ([constraints containsObject:self.bubbleWithAvatarLeftConstraint]) return;
        [self.contentView removeConstraint:self.bubbleWithoutAvatarLeftConstraint];
        [self.contentView addConstraint:self.bubbleWithAvatarLeftConstraint];
    } else {
        if ([constraints containsObject:self.bubbleWithoutAvatarLeftConstraint]) return;
        [self.contentView removeConstraint:self.bubbleWithAvatarLeftConstraint];
        [self.contentView addConstraint:self.bubbleWithoutAvatarLeftConstraint];
    }
    [self setNeedsUpdateConstraints];
}

- (void)updateWithSender:(id<ATLParticipant>)sender
{
    if (sender) {
        self.avatarImageView.hidden = NO;
        self.avatarImageView.avatarItem = sender;
    } else {
        self.avatarImageView.hidden = YES;
    }
}

- (void)configureConstraintsForIncomingMessage
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:ATLAvatarImageLeftPadding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    self.bubbleWithAvatarLeftConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:ATLAvatarImageRightPadding];
    [self.contentView addConstraint:self.bubbleWithAvatarLeftConstraint];
    self.bubbleWithoutAvatarLeftConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:ATLMessageCellHorizontalMargin];
}

@end
