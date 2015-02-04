//
//  LYRUIConversationCollectionViewFooter.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import <UIKit/UIKit.h>

@class LYRMessage;

extern NSString *const LYRUIConversationViewFooterIdentifier;

/**
 @abstract The `LYRUIConversationCollectionViewFooter` class provides support for displaying
 read receipts below message cells.
 */
@interface LYRUIConversationCollectionViewFooter : UICollectionReusableView

/**
 @abstract The message associated with the footer.
 */
@property (nonatomic) LYRMessage *message;

/**
 @abstract Displays a string of text representing the read status of a message.
 @param recipientStatus The string representing the status.
 */
- (void)updateWithAttributedStringForRecipientStatus:(NSAttributedString *)recipientStatus;

/**
 @abstract Performs calculations to determine the footer height.
 @param recipientStatus An `NSAttributedString` containing attributes that will be used in the calculation.
 @return The height for the footer.
 */
+ (CGFloat)footerHeightWithRecipientStatus:(NSAttributedString *)recipientStatus;

@end
