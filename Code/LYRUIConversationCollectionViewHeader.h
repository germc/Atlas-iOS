//
//  LYRUIConversationCollectionViewHeader.h
//  Pods
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import <UIKit/UIKit.h>

/**
 @abstract The `LYRUIConversationCollectionViewHeader` class provides support for displaying
 dates and Sender names above message cells.
 */
@interface LYRUIConversationCollectionViewHeader : UICollectionReusableView

/**
 @abstract Displays a string of text representing a date. The string is horizontally centered in the view.
 @param date The date string to be displayed
 */
- (void)updateWithAttributedStringForDate:(NSAttributedString *)date;

/**
 @abstract Displays a string of text representing a participant. The string will be horizontally aligned with 
 the left edge of the left edge of the message bubble view.
 @param participantName The string of text to be displayed
 */
- (void)updateWithAttributedStringForParticipantName:(NSAttributedString *)participantName;

@end
