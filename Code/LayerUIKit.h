//
//  LayerUIKit.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 10/27/14.
//
//


#import <Foundation/Foundation.h>

///------------------------
/// @name Controllers
///------------------------
#import "LYRUIAddressBarViewController.h"
#import "LYRUIConversationListViewController.h"
#import "LYRUIConversationViewController.h"
#import "LYRUIMessageInputToolbar.h"
#import "LYRUIParticipantTableViewController.h"
#import "LYRUITypingIndicatorViewController.h"

///------------------------
/// @name Models
///-----------------------
#import "LYRUIConversationDataSource.h"
#import "LYRUIDataSourceChange.h"
#import "LYRUIMediaAttachment.h"
#import "LYRUIParticipantTableDataSet.h"

///------------------------
/// @name Protocols
///------------------------
#import "LYRUIAvatarItem.h"
#import "LYRUIConversationPresenting.h"
#import "LYRUIMessagePresenting.h"
#import "LYRUIParticipantPresenting.h"
#import "LYRUIParticipant.h"

///------------------------
/// @name Utilities
///------------------------
#import "LYRUIConstants.h"
#import "LYRUIErrors.h"
#import "LYRUIMessagingUtilities.h"

///------------------------
/// @name Views
///------------------------
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

