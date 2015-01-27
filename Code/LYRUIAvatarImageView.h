//
//  LYRUIAvatarImageView.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 10/22/14.
//
//

#import <UIKit/UIKit.h>

extern CGFloat const LYRUIAvatarImageDiameter;

@interface LYRUIAvatarImageView : UIImageView

@property (nonatomic) UIFont *initialsFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *initialsColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat avatarImageViewDiameter UI_APPEARANCE_SELECTOR;

- (void)setInitialsForName:(NSString *)name;

@end
