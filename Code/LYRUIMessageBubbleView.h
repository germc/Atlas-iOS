//
//  LRYUIMessageBubbleView.h
//  Pods
//
//  Created by Kevin Coleman on 9/8/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

extern CGFloat const LYRUIMessageBubbleLabelHorizontalPadding;
extern CGFloat const LYRUIMessageBubbleLabelVerticalPadding;
extern CGFloat const LYRUIMessageBubbleMapWidth;
extern CGFloat const LYRUIMessageBubbleMapHeight;

/**
 @abstract The `LYRUIMessageBubbleView` class provides a lightweight, customizable view that 
 handles displaying the actual message content within a collection view cell.
 @discussion The view provides support for multiple content types including text,
 images, and location data.
 */
@interface LYRUIMessageBubbleView : UIView <UIAppearanceContainer>


- (void)displayDownloadActivityIndicator;

/**
 @abstract Tells the bubble view to display a given string.
 */
- (void)updateWithText:(NSString *)text;

/**
 @abstract Tells the bubble view to display a given image.
 */
- (void)updateWithImage:(UIImage *)image;

/**
 @abstract Tells the bubble view to display a map image for a given location.
 */
- (void)updateWithLocation:(CLLocationCoordinate2D)location;

/**
 @abstract The view that handles displaying text.
 */
@property (nonatomic) UILabel *bubbleViewLabel;

/**
 @abstract The view that handles displaying an image.
 */
@property (nonatomic) UIImageView *bubbleImageView;

@end
