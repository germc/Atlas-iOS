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
#import "LYRUIMessageInputToolbar.h"
#import "LYRUIParticipantPickerController.h"
#import "LYRUIOutgoingMessageCollectionViewCell.h"
#import "LYRUIIncomingMessageCollectionViewCell.h"
#import "LYRUIConversationTableViewCell.h"
#import "LYRUIMessagingUtilities.h"

/**
 @abstract Returns the version of the Layer UIKit as a string.
 */
extern NSString *const LYRUIKitVersionString;

/**
 @abstract Posted when a user taps on a link in a message bubble.
 */
extern NSString *const LYRUIUserDidTapLinkNotification;
