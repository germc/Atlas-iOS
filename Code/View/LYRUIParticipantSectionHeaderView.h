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
 @abstract The label representing the section of the participant picker.
 */
@property (nonatomic) UILabel *nameLabel;

@end
