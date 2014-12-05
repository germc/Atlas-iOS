//
//  LYRUIMessageComposeTextView.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

/**
 @abstract The LYRUIMessageComposeTextView handles displaying content in an 
 `LYRUIMessageInputToolbar`. The class provides support for displaying text, 
 images, and locations objects represented by a map image via NSTextAttachemts.
 */
@interface LYRUIMessageComposeTextView : UITextView

/**
 @abstract Configures the placeholder text for the textView
 */
@property (nonatomic) NSString *placeHolderText;

@end
