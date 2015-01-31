//
//  LYRUIMessageBubbleView.h
//  LayerUIKit
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
 @abstract The LYRUIMessageBubbleViewDownloadActivityOptions describes
 avaialble display options for download activity.
 */
typedef NS_ENUM(NSInteger, LYRUIDownloadProgressViewOptions) {
    LYRUIDownloadProgressViewOptionButtonStyleNone        = 0,
    LYRUIDownloadProgressViewOptionButtonStyleStart       = 1,
    LYRUIDownloadProgressViewOptionButtonStylePause       = 2,
    LYRUIDownloadProgressViewOptionButtonStyleStop        = 3,
    LYRUIDownloadProgressViewOptionShowProgress           = (1 << 5),
    LYRUIDownloadProgressViewOptionEnableBlurring         = (1 << 6),
};

typedef NS_ENUM(NSInteger, LYRUIBubbleViewContentType) {
    LYRUIBubbleViewContentTypeText,
    LYRUIBubbleViewContentTypeImage,
    LYRUIBubbleViewContentTypeLocation,
};

/**
 @abstract The `LYRUIMessageBubbleView` class provides a lightweight, customizable view that 
 handles displaying the actual message content within a collection view cell.
 @discussion The view provides support for multiple content types including text,
 images, and location data.
 */
@interface LYRUIMessageBubbleView : UIView <UIAppearanceContainer>

/**
 @abstract Tells the bubble view to display a download indicator on top of content.
 */
- (void)updateDownloadActivityIndicatorWithProgress:(float)progress options:(LYRUIDownloadProgressViewOptions)options;

/**
 @abstract Tells the bubble view to display a given string.
 */
- (void)updateWithAttributedText:(NSAttributedString *)text;

/**
 @abstract Tells the bubble view to display a given image.
 */
- (void)updateWithImage:(UIImage *)image width:(CGFloat)width;

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

@property (nonatomic) LYRUIBubbleViewContentType contentType;


@end
