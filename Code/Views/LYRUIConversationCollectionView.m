//
//  LYRUIConversationCollectionView.m
//  Atlas
//
//  Created by Kevin Coleman on 1/30/15.
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
#import "LYRUIConversationCollectionView.h"

@implementation LYRUIConversationCollectionView

NSString *const LYRUIConversationViewControllerAccessibilityLabel = @"Conversation View Controller";
NSString *const LYRUIConversationCollectionViewAccessibilityIdentifier = @"Conversation Collection View";

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (void)lyr_commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.alwaysBounceVertical = YES;
    self.bounces = YES;
    self.accessibilityIdentifier = LYRUIConversationCollectionViewAccessibilityIdentifier;
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self registerReuseIdentifiers];
}

- (void)registerReuseIdentifiers
{
    [self registerClass:[LYRUIIncomingMessageCollectionViewCell class]
            forCellWithReuseIdentifier:LYRUIIncomingMessageCellIdentifier];
    
    [self registerClass:[LYRUIOutgoingMessageCollectionViewCell class]
            forCellWithReuseIdentifier:LYRUIOutgoingMessageCellIdentifier];
    
    [self registerClass:[LYRUIConversationCollectionViewMoreMessagesHeader class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:LYRUIMoreMessagesHeaderIdentifier];
    
    [self registerClass:[LYRUIConversationCollectionViewHeader class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:LYRUIConversationViewHeaderIdentifier];
    
    [self registerClass:[LYRUIConversationCollectionViewFooter class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:LYRUIConversationViewFooterIdentifier];
}

@end
