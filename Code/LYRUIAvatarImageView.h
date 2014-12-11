//
//  LYRUIAvatarImageView.h
//  Pods
//
//  Created by Kevin Coleman on 10/22/14.
//
//

#import <UIKit/UIKit.h>

@interface LYRUIAvatarImageView : UIImageView

@property (nonatomic) UIFont *initialFont UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *initialColor UI_APPEARANCE_SELECTOR;

- (void)setInitialsForName:(NSString *)name;

@end
