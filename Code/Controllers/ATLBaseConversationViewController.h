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
 @abstract The `ATLBaseConversationViewController` manages the basic user interface components associated with a messaging stream. 
 @discussion The controller hanldes presenting both the `ATLMessageInputToolbar` and optionally, the `ATLAddressBarViewController`. 
 The controller also handles configuring the layout of a collection view. It manages resizing the content size of the collection view
 in response to messange input toll bar activity as we. 
 */
@interface ATLBaseConversationViewController : UIViewController

/**
 @abstract The `ATLAddressBarViewController` displayed for addressing new conversations.
 */
@property (nonatomic) ATLAddressBarViewController *addressBarController;

/**
 @abstract The `ATLMessageInputToolbar` displayed for user input.
 */
@property (nonatomic) ATLMessageInputToolbar *messageInputToolbar;

/** 
 @abstract The `ATLTypingIndicatorViewController` displayed to indicate other participants in a conversation are typing. 
 */
@property (nonatomic) ATLTypingIndicatorViewController *typingIndicatorViewController;

/**
 @abstract The `UICollectionView` responsible for displaying messaging content. 
 @discussion Subclasses should set the collection view property in their `loadView` method. The controller will then 
 handle configuring autolayout constraints.
 */
@property (nonatomic) UICollectionView *collectionView;

// TODO - We can get rid of this.
/**
 @abstract Updates the typing indicator inset.
 */
@property (nonatomic) CGFloat typingIndicatorInset;

/**
 @abstract Informs the receiver if it should display a `ATLAddressBarController`. If yes, your application must implement
 `ATLAddressBarControllerDelegate` and `ATLAddressBarControllerDataSource`. Default is no.
 */
@property (nonatomic) BOOL displaysAddressBar;

/**
 @abstract Returns a boolean value that determines whether or not the controller should scroll the collection view content to the bottom. 
 @discussion Returns NO if the content is further than 50px from the bottom of the collection view or the scroll view is currently scrolling.
 */
- (BOOL)shouldScrollToBottom;

/**
 @abstract Informs the controller that it should scroll the collection view to the bottom of its content. 
 @param animated A boolean value to determine whether or not the scroll should be animated. 
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

// Calculates the bottom offset of the collection view taking into account any current insets caused by address bar and message input toolbar
- (CGPoint)bottomOffsetForContentSize:(CGSize)contentSize;

@end
