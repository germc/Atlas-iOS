//
//  LYRUIConversationCollectionViewFooter.h
//  Pods
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import <UIKit/UIKit.h>

/**
 @abstract The `LYRUIConversationCollectionViewFooter` class provides support for displaying
 read receipts below message cells.
 */
@interface LYRUIConversationCollectionViewFooter : UICollectionReusableView

/**
 @abstract Displays a string of text representing the read status of the message
 @param recipientStatus the string representing the status
 */
- (void)updateWithAttributedStringForRecipientStatus:(NSString *)recipientStatus;

@end
