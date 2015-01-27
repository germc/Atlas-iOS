//
//  LYRUIAvatarImageView.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 10/22/14.
//
//

#import <UIKit/UIKit.h>

extern CGFloat const LYRUIAvatarImageDiameter;

/**
 @abstract The `LYRUIAvatarImageView` displays a circular avatar image representing a participant in a conversation. 
 If no image is present, the image view can optionally display initials for a participant.
 */
@interface LYRUIAvatarImageView : UIImageView

/**
 @abstract Sets the diameter for the avatar image view. Default is 30.
 @discussion Bounds for the image view are clipped to half of the diameter to create a circular
 image.
 */
@property (nonatomic) CGFloat avatarImageViewDiameter UI_APPEARANCE_SELECTOR;

/**
 @abstract Sets the font for the avatar initials. Default is 14pt system font.
 */
@property (nonatomic) UIFont *initialsFont UI_APPEARANCE_SELECTOR;

/**
 @abstract Sets the text color for the avatar initials. Default is black.
 */
@property (nonatomic) UIColor *initialsColor UI_APPEARANCE_SELECTOR;
 
/*
 @abstract Sets the initials to be displayed in the image view.
 @param fullName The full name string representing a participant in a conversation. 
 @discussion The string supplied will be split into components seperated by `whitespaceCharacterSet`. The first 
 letter of each component will be concatened and displayed as the initials. It is reccomended that the `fullName` string
 only consist of a first and last name, seperated by one white space. 
 */
- (void)setInitialsForFullName:(NSString *)fullName;

@end
