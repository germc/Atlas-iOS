//
//  LYRUIParticipantSectionHeaderView.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 8/31/14.
//
//

#import <UIKit/UIKit.h>

/**
 @abstract The `LYRUIParticipantSectionHeaderView` displays a letter representing a section
 in the participant picker.
 */
@interface LYRUIParticipantSectionHeaderView : UITableViewHeaderFooterView

/**
 @abstract The label displayed in the section header.
 */
@property (nonatomic) UILabel *sectionHeaderLabel;

/**
 @abstract The font for the section header label. Default is 14pt system font.
 */
@property (nonatomic) UIFont *sectionHeaderFont UI_APPEARANCE_SELECTOR;

/**
 @abstract The color for the section header label. Default is black.
 */
@property (nonatomic) UIColor *sectionHeaderTextColor UI_APPEARANCE_SELECTOR;

/**
 @abstract The background color for the section header. Default is `LYRUILightGrayColor()`.
 */
@property (nonatomic) UIColor *sectionHeaderBackgroundColor UI_APPEARANCE_SELECTOR;

@end
