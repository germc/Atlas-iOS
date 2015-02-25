//
//  ATLBaseConversationViewController.h
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

#import <UIKit/UIKit.h>
#import "ATLAddressBarViewController.h"
#import "ATLMessageInputToolbar.h"
#import "ATLTypingIndicatorViewController.h"

/**
 @abstract The `ATLBaseConversationViewController` manages a suite of user interface components associated with a messaging view controller.
 @discussion The controller handles presenting the `ATLMessageInputToolbar`, the `ATLTypingIndicatorViewController`, and optionally, the `ATLAddressBarViewController`. It also manages configuring the layout and content insets of its collection view property in response to changes in the state or size of its `addressBarController`, `messageInputToolbar`, and `typingIndicatorController` properties.
 */
@interface ATLBaseConversationViewController : UIViewController

///---------------------------------------------------------------
/// @name Accessing User Interface Components
///---------------------------------------------------------------

/**
 @abstract The `ATLAddressBarViewController` displayed for addressing new conversations or displaying names of current conversation participants.
 */
@property (nonatomic) ATLAddressBarViewController *addressBarController;

/**
 @abstract The `ATLMessageInputToolbar` displayed for user input.
 */
@property (nonatomic) ATLMessageInputToolbar *messageInputToolbar;

/** 
 @abstract An `ATLTypingIndicatorViewController` displayed to represent participants typing in a conversation.
 */
@property (nonatomic) ATLTypingIndicatorViewController *typingIndicatorController;

/**
 @abstract The `UICollectionView` responsible for displaying messaging content. 
 @discussion Subclasses should set the collection view property in their `loadView` method. The controller will then handle configuring autolayout constraints for the collection view.
 */
@property (nonatomic) UICollectionView *collectionView;

///----------------------------------------------
/// @name Configuring View Options
///----------------------------------------------

/**
 @abstract A constant representing the current height of the typing indicator.
 */
@property (nonatomic) CGFloat typingIndicatorInset;

/**
 @abstract IA boolean value to determine whether or not the receiver should display an `ATLAddressBarController`. If yes, applications should implement `ATLAddressBarControllerDelegate` and `ATLAddressBarControllerDataSource`. Default is no.
 */
@property (nonatomic) BOOL displaysAddressBar;

///-------------------------------------
/// @name Managing Scrolling
///-------------------------------------

/**
 @abstract Returns a boolean value to determines whether or not the controller should scroll the collection view content to the bottom.
 @discussion Returns NO if the content is further than 150px from the bottom of the collection view or the collection view is currently scrolling.
 */
- (BOOL)shouldScrollToBottom;

/**
 @abstract Informs the controller that it should scroll the collection view to the bottom of its content. 
 @param animated A boolean value to determine whether or not the scroll should be animated. 
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

/**
 @abstract Calculates the bottom offset of the collection view taking into account any current insets caused by `addressBarController`, `typingIndicatorViewController` or `messageInputToolbar`.
 */
- (CGPoint)bottomOffsetForContentSize:(CGSize)contentSize;

@end
