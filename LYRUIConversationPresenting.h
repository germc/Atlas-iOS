//
//  LYRUIConversationPresenting.h
//  
//
//  Created by Kevin Coleman on 8/29/14.
//
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

NSString *LYRUIMIMETypeTextPlain; /// text/plain
NSString *LYRUIMIMETypeImagePNG;  /// image/png
NSString *LYRUIMIMETypeImageJPEG;  /// image/jpeg
NSString *LYRUIMIMETypeLocation;  /// location

/**
 @abstract The `LYRUIConversationPresenting` protocol must be adopted by any view component
 that wishes to present a Layer conversation object.
 */
@protocol LYRUIConversationPresenting <NSObject>

/**
 @abstract Tells the receiver to present a given Layer Conversation.
 @param conversation The conversation to present.
 */
- (void)presentConversation:(LYRConversation *)conversation withLabel:(NSString *)conversationLabel;

/**
 @abstract Tells the receiver to display an avatar image or no.
 */
- (void)shouldShowConversationImage:(BOOL)shouldShowConversationImage;

/**
 @abstract The image to be displayed with the conversation. If `shouldShowConversationImage:` is set to `NO`
 no, image will be displayed
 */
@property (nonatomic) UIImage *conversationImage;

@end
