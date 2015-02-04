//
//  LYRTypingIndicatorView.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 11/11/14.
//
//

#import <UIKit/UIKit.h>

@interface LYRUITypingIndicatorViewController : UIViewController

@property (nonatomic) UILabel *label;

- (void)updateWithParticipants:(NSMutableArray *)participants animated:(BOOL)animated;

@end
