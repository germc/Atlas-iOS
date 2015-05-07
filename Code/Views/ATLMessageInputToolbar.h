//
//  ATLUIMessageInputToolbar.h
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
#import "ATLMessageComposeTextView.h"
#import "ATLMediaAttachment.h"

@class ATLMessageInputToolbar;

extern NSString *const ATLMessageInputToolbarDidChangeHeightNotification;
extern NSString *const ATLMessageInputToolbarAccessibilityLabel;

//---------------------------------
// Message Input Toolbar Delegate
//---------------------------------

/**
 @abstract The `ATLMessageInputToolbarDelegate` notifies its receiver when buttons have been 
 tapped.
 */
@protocol ATLMessageInputToolbarDelegate <NSObject>

/**
 @abstract Notifies the receiver that the right accessory button was tapped.
 */
- (void)messageInputToolbar:(ATLMessageInputToolbar *)messageInputToolbar didTapRightAccessoryButton:(UIButton *)rightAccessoryButton;

/**
 @abstract Notifies the receiver that the left accessory button was tapped.
 */
- (void)messageInputToolbar:(ATLMessageInputToolbar *)messageInputToolbar didTapLeftAccessoryButton:(UIButton *)leftAccessoryButton;

@optional

/**
 @abstract Notifies the receiver that typing has occurred.
 */
- (void)messageInputToolbarDidType:(ATLMessageInputToolbar *)messageInputToolbar;

/**
 @abstract Notifies the receiver that typing has ended.
 */
- (void)messageInputToolbarDidEndTyping:(ATLMessageInputToolbar *)messageInputToolbar;

@end

/**
 @abstract The `ATLMessageInputToolbar` provides a lightweight and customizable class
 that is similar to the message input toolbar in Messages.
 @discussion The class displays two customizable `UIButton` objects separated by a message input text view.
 Instances are automatically resized in response to user or system input. The view also
 caches any content provided and exposes that content back to a consuming object via the
 mediaAttachments property.
 */
@interface ATLMessageInputToolbar : UIToolbar

//------------------------------
// Content Display Methods
//------------------------------

/**
 @abstract Inserts the mediaAttachment as an attributed text attachment which is inlined with text.
 @param mediaAttachment The `ATLMediaAttachment` instance containing information about the media.
 @discussion The view will automatically resize the attachment's thumbnail and itself to comfortably
 fit the thumbnail content. The image will also be cached and is accessible via the mediaAttachments
 property.
 */
- (void)insertMediaAttachment:(ATLMediaAttachment *)mediaAttachment;

//-----------------------------
// UI Customization
//-----------------------------

/**
 @abstract The left accessory button for the view. 
 @discussion By default, the button displays a camera icon. If set to `nil` the `textInputView` will expand to the left edge of the toolbar.
 */
@property (nonatomic) UIButton *leftAccessoryButton;
 
/**
 @abstract The right accessory button for the view.
 @discussion By default, the button displays the text "SEND".
 */
@property (nonatomic) UIButton *rightAccessoryButton;

/**
 @abstract The font color for the right accessory button in active state.
 */
@property (nonatomic) UIColor *rightAccessoryButtonActiveColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The font color for the right accessory button in disabled state.
 */
@property (nonatomic) UIColor *rightAccessoryButtonDisabledColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The image displayed on left accessory button.
 @default A `camera` icon.
 */
@property (nonatomic) UIImage *leftAccessoryImage;

/**
 @abstract The image displayed on right accessory button.
 @default A `location` icon.
 */
@property (nonatomic) UIImage *rightAccessoryImage;

/**
 @abstract Determines whether or not the right accessory button displays an icon. 
 @disucssion If NO, the right accessory button will display the text `SEND` at all times.
 @default YES
 */
@property(nonatomic) BOOL displaysRightAccessoryImage;

/**
 @abstract An automatically resizing message composition field.
 */
@property (nonatomic) ATLMessageComposeTextView *textInputView;

/**
 @abstract The delegate object for the view.
 */
@property (nonatomic, weak) id<ATLMessageInputToolbarDelegate> inputToolBarDelegate;

/**
 @abstract The maximum number of lines of next to be displayed.
 @default 8
 @discussion The text view will stop growing once the maximum number of lines are displayed. It
 will scroll its text view to keep the latest content visible.
 */
@property (nonatomic) NSUInteger maxNumberOfLines;

/**
 @abstract An array of all media attachments displayed in the text view.
 @discussion Any existing media attachments will be removed when the right accessory button is tapped.
 */
@property (nonatomic, readonly) NSArray *mediaAttachments;

@end
