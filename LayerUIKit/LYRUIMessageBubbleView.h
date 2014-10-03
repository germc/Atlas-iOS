//
//  LRYUIMessageBubbleView.h
//  Pods
//
//  Created by Kevin Coleman on 9/8/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

/**
 @abstract The `LYRUIMessageBubbleView` class provides a lightweight, customizable view that 
 handles displaying the actual message content within a collectionViewCell. 
 @discussion The view provides support for multiple different content types including text,
 images, and location data.
 */
@interface LYRUIMessageBubbleView : UIView <UIAppearanceContainer>

/**
 @abstract Tells the bubble view to display a given string
 */
- (void)updateWithText:(NSString *)text;

/**
 @abstract Tells the bubble view to display a given image
 */
- (void)updateWithImage:(UIImage *)image;

/**
 @abstract Tells the bubble view to display a map image for a given location
 */
- (void)updateWithLocation:(CLLocationCoordinate2D)location;

/**
 @abstract The textView object that handles displaying text
 */
@property (nonatomic)UILabel *bubbleTextView;

/**
 @abstract imageView object that handles displaying images
 */
@property (nonatomic)UIImageView *bubbleImageView;

@end
