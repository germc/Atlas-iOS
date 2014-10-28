//
//  LYRUIAddressBarController.h
//  
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import <UIKit/UIKit.h>
#import "LYRUIAddresBarView.h"

@class LYRUIAddressBarViewController;

@protocol LYRUIAddressBarControllerDelegate <NSObject>

/**
 @abstract Tells the receiver that the user has selected a set of participants from a participant selection view.
 @param participantSelectionViewController The participant selection view in which the selection was made.
 @param participants The set of participants that was selected.
 */
- (void)participantSelectionViewController:(LYRUIAddressBarViewController *)participantSelectionViewController didSelectParticipants:(NSSet *)participants;

@end

@interface LYRUIAddressBarViewController : UITableViewController

@property (nonatomic) LYRUIAddresBarView *addressBarView;

@end
