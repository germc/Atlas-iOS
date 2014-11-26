//
//  LYRUIAddresBarTextView.h
//  Pods
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import <UIKit/UIKit.h>

extern NSString *const LYRUIAddressBarPartAttributeName;

extern NSString *const LYRUIAddressBarNamePart;
extern NSString *const LYRUIAddressBarDelimiterPart;

@interface LYRUIAddressBarTextView : UITextView

@property (nonatomic) UIFont *addressBarFont UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIColor *addressBarTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic) UIColor *addressBarHighlightColor UI_APPEARANCE_SELECTOR;

@end
