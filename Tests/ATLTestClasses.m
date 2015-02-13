//
//  ATLUITestClasses.m
//  Atlas
//
//  Created by Kevin Coleman on 1/19/15.
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
#import "ATLTestClasses.h"

@implementation ATLTestClasses

@end

#pragma mark - Test Conversation Cell Implementaion

@implementation ATLTestConversationCell

- (void)presentConversation:(LYRConversation *)conversation
{
    [super presentConversation:conversation];
}

- (void)updateWithConversationLabel:(NSString *)conversationLabel
{
    [super updateWithConversationLabel:conversationLabel];
}

- (void)updateWithConversationImage:(UIImage *)image
{
    [super updateWithAvatarItem:nil];
}

@end

#pragma mark - Test Message Cell Implementaion

@implementation ATLTestMessageCollectionViewCell

- (void)presentMessage:(LYRMessage *)message
{
    [super presentMessage:message];
}

- (void)updateWithParticipant:(id<ATLParticipant>)participant
{
    [super updateWithParticipant:participant];
}

- (void)shouldDisplayAvatarImage:(BOOL)shouldDisplayAvatarImage
{
    [super shouldDisplayAvatarImage:shouldDisplayAvatarImage];
}

@end

@implementation ATLTestParticipantCell

@end
