//
//  LYRUIAvatarImageView.h
//  Pods
//
//  Created by Kevin Coleman on 10/22/14.
//
//

#import <UIKit/UIKit.h>

@interface LYRUIAvatarImageView : UIImageView

@property (nonatomic) UIFont *initialsFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *initialsColor UI_APPEARANCE_SELECTOR;

- (void)setInitialsForName:(NSString *)name;

@end
