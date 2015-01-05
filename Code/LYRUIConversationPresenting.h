//
//  LYRUIConversationPresenting.h
//  
//
//  Created by Kevin Coleman on 8/29/14.
//
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

/**
 @abstract The `LYRUIConversationPresenting` protocol must be adopted by any view component
 that wishes to present a Layer conversation object.
 */
@protocol LYRUIConversationPresenting <NSObject>

/**
 @abstract Tells the receiver to present a given Layer Conversation.
 @param conversation The conversation to present.
 */
- (void)presentConversation:(LYRConversation *)conversation;

/**
 @abstract Gives the receiver a string to display representing the conversation label
 @param conversation The conversation label to display
 */
- (void)updateWithConversationLabel:(NSString *)conversationLabel;

/**
 @abstract Gives the receiver an image to display representing the conversation image
 @param conversation The conversation image to display
 */
- (void)updateWithConversationImage:(UIImage *)image;

/**
 @abstract Gives the receiver a number to display representing the number of unread messages in a conversation
 @param conversation The conversation image to display
 */
- (void)updateWithLastMessageRecipientStatus:(LYRRecipientStatus)recipientStatus;

@end
