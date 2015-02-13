//
//  LYRUIMessageInputToolbar.h
//  Atlas
//
//  Created by Kevin Coleman on 9/18/14.
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
#import "LYRUIMessageComposeTextView.h"

@class LYRUIMessageInputToolbar;

extern NSString *const LYRUIMessageInputToolbarDidChangeHeightNotification;

//---------------------------------
// Message Input Toolbar Delegate
//---------------------------------

/**
 @abstract The `LYRUIMessageInputToolbarDelegate` notifies its receiver when buttons have been 
 tapped.
 */
@protocol LYRUIMessageInputToolbarDelegate <NSObject>

/**
 @abstract Notifies the receiver that the right accessory button was tapped.
 */
- (void)messageInputToolbar:(LYRUIMessageInputToolbar *)messageInputToolbar didTapRightAccessoryButton:(UIButton *)rightAccessoryButton;

/**
 @abstract Notifies the receiver that the left accessory button was tapped.
 */
- (void)messageInputToolbar:(LYRUIMessageInputToolbar *)messageInputToolbar didTapLeftAccessoryButton:(UIButton *)leftAccessoryButton;

@optional

/**
 @abstract Notifies the receiver that typing has occurred.
 */
- (void)messageInputToolbarDidType:(LYRUIMessageInputToolbar *)messageInputToolbar;

/**
 @abstract Notifies the receiver that typing has ended.
 */
- (void)messageInputToolbarDidEndTyping:(LYRUIMessageInputToolbar *)messageInputToolbar;

@end

/**
 @abstract The `LYRUIMessageInputToolbar` provides a lightweight and customizable class
 that is similar to the message input toolbar in Messages.
 @discussion The class displays two customizable UIButtons seperated by a message input text view.
 The class automatically resizes itself in response to user or system input content. The view also
 caches any content provided and exposes that content back to a consuming object via the
 messageParts property.
 */
@interface LYRUIMessageInputToolbar : UIToolbar

//------------------------------
// Content Display Methods
//------------------------------

/**
 @abstract Displays an image in the textInputView.
 @discussion The view will automatically resize the image and itself to comfortably
 fit the image content. The image will also be cached and is accessible via the messageParts
 property.
 */
- (void)insertImage:(UIImage *)image;

//-----------------------------
// UI Customization
//-----------------------------

/**
 @abstract The left accessory button for the view. 
 @discussion By default, the button displays a camera icon.
 */
@property (nonatomic) UIButton *leftAccessoryButton;

/**
 @abstract The right accessory button for the view.
 @discussion By default, the button displays the text "SEND".
 */
@property (nonatomic) UIButton *rightAccessoryButton;

/**
 @abstract A boolean value indicating whether the receiver can enable its send button.
 @discussion By default, the button can be enabled.
 */
@property (nonatomic) BOOL canEnableSendButton;

/**
 @abstract An automatically resizing message composition field.
 */
@property (nonatomic) LYRUIMessageComposeTextView *textInputView;

/**
 @abstract The delegate object for the view.
 */
@property (nonatomic, weak) id<LYRUIMessageInputToolbarDelegate> inputToolBarDelegate;

/**
 @abstract The maximum number of lines of next to be displayed.
 @default 8
 @discussion The text view will stop growing once the maximum number of lines are displayed. It
 will scroll its text view to keep the latest content visible.
 */
@property (nonatomic) NSUInteger maxNumberOfLines;

/**
 @abstract An array of all content parts displayed in the view. 
 @discussion Any existing objects will be removed when the right accessory button is tapped.
 */
@property (nonatomic, readonly) NSArray *messageParts;

@end
