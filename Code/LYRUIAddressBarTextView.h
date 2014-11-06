//
//  LYRUIAddresBarTextView.h
//  Pods
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import <UIKit/UIKit.h>

extern NSString *const LYRUIPlaceHolderText;

@interface LYRUIAddressBarTextView : UITextView

@property (nonatomic) UIFont *addressBarFont UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIColor *addressBarTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIColor *addressBarHightlightColor UI_APPEARANCE_SELECTOR;

@end
