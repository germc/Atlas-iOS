//
//  LYRUITypingIndicatorViewController.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 11/11/14.
//
//

#import <UIKit/UIKit.h>

/*
 @abstract Displays a simple typing indicator view with a list of participant names.
 */
@interface LYRUITypingIndicatorViewController : UIViewController

/*
 @abstract Updates the typing indicator with an array of participants currently typing. 
 @param participants The participants currently typing in a conversation.
 @param animated A boolean value to determine if the typing indicator should animate its opacity.
 @discussion If an empty array is supplied, the typing indicator opacity will be set to 0.0. If
 a non-empty array is supplied, the opacity will be set to 1.0.
 */
- (void)updateWithParticipants:(NSMutableArray *)participants animated:(BOOL)animated;

@end
