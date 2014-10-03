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
 dates and Sender names above message cells
 */
@interface LYRUIConversationCollectionViewHeader : UICollectionReusableView

/**
 @abstract Displays a string of text representing a date
 @param date The date string to be displayed
 */
- (void)updateWithAttributedStringForDate:(NSString *)date;

/**
 @abstract Displays a string of text representing a participant
 @param participantName The string of text to be displayed
 */
- (void)updateWithAttributedStringForParticipantName:(NSString *)participantName;

@end
