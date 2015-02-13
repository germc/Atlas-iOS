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

- (void)shouldDisplayAvatarImage:(BOOL)shouldDisplayAvatarImage
{
    NSArray *constraints = [self.contentView constraints];
    if (shouldDisplayAvatarImage) {
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

- (void)updateWithParticipant:(id<ATLParticipant>)participant
{
    if (participant) {
        self.avatarImageView.hidden = NO;
        if (participant.avatarImage) {
            [self.avatarImageView setImage:participant.avatarImage];
        } else {
            [self.avatarImageView setInitialsForFullName:participant.fullName];
        }
    } else {
        self.avatarImageView.hidden = YES;
    }
}

- (void)configureConstraintsForIncomingMessage
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    self.bubbleWithAvatarLeftConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:10];
    [self.contentView addConstraint:self.bubbleWithAvatarLeftConstraint];
    self.bubbleWithoutAvatarLeftConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
}

@end
