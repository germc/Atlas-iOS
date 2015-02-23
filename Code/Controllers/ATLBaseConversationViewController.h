//
//  ATLBaseConversationViewController.h
//  Pods
//
//  Created by Kevin Coleman on 2/22/15.
//
//

#import <UIKit/UIKit.h>
#import "ATLAddressBarViewController.h"
#import "ATLMessageInputToolbar.h"
#import "ATLTypingIndicatorViewController.h"

/**
 @abstract The `ATLBaseConversationViewController` manages a suite of user interface components associated with a messaging view controller.
 @discussion The controller handles presenting the `ATLMessageInputToolbar`, the `ATLTypingIndicatorViewController`, and optionally, the `ATLAddressBarViewController`. It also manages configuring the layout and content insets of its collection view property in response to changes in the state or size of its `addressBarController`, `messageInputToolbar`, and `typingIndicatorController` properties.
 */
@interface ATLBaseConversationViewController : UIViewController

/**
 @abstract The `ATLAddressBarViewController` displayed for addressing new conversations or displaying names of current conversation participants.
 */
@property (nonatomic) ATLAddressBarViewController *addressBarController;

/**
 @abstract The `ATLMessageInputToolbar` displayed for user input.
 */
@property (nonatomic) ATLMessageInputToolbar *messageInputToolbar;

/** 
 @abstract An `ATLTypingIndicatorViewController` displayed to represent participants typing in a conversation.
 */
@property (nonatomic) ATLTypingIndicatorViewController *typingIndicatorController;

/**
 @abstract The `UICollectionView` responsible for displaying messaging content. 
 @discussion Subclasses should set the collection view property in their `loadView` method. The controller will then handle configuring autolayout constraints for the collection view.
 */
@property (nonatomic) UICollectionView *collectionView;

/**
 @abstract A constant representing the current height of the typing indicator.
 */
@property (nonatomic) CGFloat typingIndicatorInset;

/**
 @abstract IA boolean value to determine whether or not the receiver should display an `ATLAddressBarController`. If yes, applications should implement `ATLAddressBarControllerDelegate` and `ATLAddressBarControllerDataSource`. Default is no.
 */
@property (nonatomic) BOOL displaysAddressBar;

/**
 @abstract Returns a boolean value to determines whether or not the controller should scroll the collection view content to the bottom.
 @discussion Returns NO if the content is further than 50px from the bottom of the collection view or the collection view is currently scrolling.
 */
- (BOOL)shouldScrollToBottom;

/**
 @abstract Informs the controller that it should scroll the collection view to the bottom of its content. 
 @param animated A boolean value to determine whether or not the scroll should be animated. 
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

/**
 @abstract Calculates the bottom offset of the collection view taking into account any current insets caused by `addressBarController`, `typingIndicatorViewController` or `messageInputToolbar`.
 */
- (CGPoint)bottomOffsetForContentSize:(CGSize)contentSize;

@end
