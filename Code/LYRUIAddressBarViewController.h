//
//  LYRUIAddressBarController.h
//  
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import <UIKit/UIKit.h>
#import "LYRUIAddressBarView.h"
#import "LYRUIParticipant.h"

@class LYRUIAddressBarViewController;

@protocol LYRUIAddressBarControllerDataSource <NSObject>

- (void)searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSSet *participants))completion;

@end

@protocol LYRUIAddressBarControllerDelegate <NSObject>

- (void)addressBarViewControllerDidBeginSearching:(LYRUIAddressBarViewController *)addressBarViewController;

- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController didSelectParticipants:(NSSet *)participants;

- (void)addressBarViewControllerDidEndSearching:(LYRUIAddressBarViewController *)addressBarViewController;

- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton;

@end

@interface LYRUIAddressBarViewController : UIViewController

@property (nonatomic) LYRUIAddressBarView *addressBarView;

@property (nonatomic, weak) id <LYRUIAddressBarControllerDataSource>dataSource;

@property (nonatomic, weak) id <LYRUIAddressBarControllerDelegate>delegate;

- (void)setPermanent;

- (void)selectParticipant:(id<LYRUIParticipant>)participant;

@end
