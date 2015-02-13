//
//  Atlas.h
//  Atlas
//
//  Created by Kevin Coleman on 10/27/14.
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

#import <Foundation/Foundation.h>

///------------------
/// @name Controllers
///------------------

#import "LYRUIAddressBarViewController.h"
#import "LYRUIConversationListViewController.h"
#import "LYRUIConversationViewController.h"
#import "LYRUIMessageInputToolbar.h"
#import "LYRUIParticipantTableViewController.h"
#import "LYRUITypingIndicatorViewController.h"

///-------------
/// @name Models
///-------------

#import "LYRUIConversationDataSource.h"
#import "LYRUIDataSourceChange.h"
#import "LYRUIMediaAttachment.h"
#import "LYRUIParticipantTableDataSet.h"

///----------------
/// @name Protocols
///----------------

#import "LYRUIAvatarItem.h"
#import "LYRUIConversationPresenting.h"
#import "LYRUIMessagePresenting.h"
#import "LYRUIParticipantPresenting.h"
#import "LYRUIParticipant.h"

///----------------
/// @name Utilities
///----------------

#import "LYRUIConstants.h"
#import "LYRUIErrors.h"
#import "LYRUIMessagingUtilities.h"

///------------
/// @name Views
///------------

#import "LYRUIAddressBarContainerView.h"
#import "LYRUIAddressBarView.h"
#import "LYRUIAvatarImageView.h"
#import "LYRUIConversationCollectionView.h"
#import "LYRUIConversationCollectionViewFooter.h"
#import "LYRUIConversationCollectionViewHeader.h"
#import "LYRUIConversationCollectionViewMoreMessagesHeader.h"
#import "LYRUIConversationTableViewCell.h"
#import "LYRUIConversationView.h"
#import "LYRUIIncomingMessageCollectionViewCell.h"
#import "LYRUIMessageBubbleView.h"
#import "LYRUIMessageCollectionViewCell.h"
#import "LYRUIMessageComposeTextView.h"
#import "LYRUIOutgoingMessageCollectionViewCell.h"
#import "LYRUIParticipantSectionHeaderView.h"
#import "LYRUIParticipantTableViewCell.h"
#import "LYRUIProgressView.h"

/**
 @abstract Returns the version of the Layer UIKit as a string.
 */
extern NSString *const LYRUIKitVersionString;

