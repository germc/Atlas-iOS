//
//  LayerUIKit.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 10/27/14.
//
//


#import <Foundation/Foundation.h>

#import "LYRUIConversationListViewController.h"
#import "LYRUIConversationViewController.h"
#import "LYRUIParticipantPickerController.h"
#import "LYRUIMessageInputToolbar.h"
#import "LYRUIAddressBarViewController.h"

#import "LYRUIOutgoingMessageCollectionViewCell.h"
#import "LYRUIIncomingMessageCollectionViewCell.h"
#import "LYRUIConversationCollectionViewHeader.h"
#import "LYRUIConversationCollectionViewFooter.h"
#import "LYRUIConversationTableViewCell.h"
#import "LYRUIMessagingUtilities.h"
#import "LYRUIParticipant.h"

/**
 @abstract Returns the version of the Layer UIKit as a string.
 */
extern NSString *const LYRUIKitVersionString;

/**
 @abstract Posted when a user taps a link in a message bubble.
 */
extern NSString *const LYRUIUserDidTapLinkNotification;
