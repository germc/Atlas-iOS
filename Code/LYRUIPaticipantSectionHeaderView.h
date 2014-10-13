//
//  LYRUIPaticipantSectionHeaderView.h
//  Pods
//
//  Created by Kevin Coleman on 8/31/14.
//
//

#import <UIKit/UIKit.h>

/**
 @abstract The `LYRUIPaticipantSectionHeaderView` displays a letter representing a section
 in the particpant picker
 */
@interface LYRUIPaticipantSectionHeaderView : UIView

/**
 @abstract Tells the receiver which letter to display for a given section
 @param the letter to display
 */
- (id)initWithKey:(NSString *)key;

/**
 @abstract The key representing the section of the participant picker
 */
@property (nonatomic) UILabel *keyLabel;

@end
