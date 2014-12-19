//
//  LYRUIParticipantSectionHeaderView.h
//  Pods
//
//  Created by Kevin Coleman on 8/31/14.
//
//

#import <UIKit/UIKit.h>

/**
 @abstract The `LYRUIParticipantSectionHeaderView` displays a letter representing a section
 in the participant picker.
 */
@interface LYRUIParticipantSectionHeaderView : UIView

/**
 @abstract Tells the receiver which letter to display for a given section.
 @param key The letter to display.
 */
- (id)initWithKey:(NSString *)key;

/**
 @abstract The label representing the section of the participant picker.
 */
@property (nonatomic) UILabel *keyLabel;

@end
