//
//  LYRUIMessagePresenting.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRUIParticipant.h"
#import <LayerKit/LayerKit.h>

/**
 @abstract The `LYRUIMessagePresenting` protocol must be adopted by objects wishing to preset 
 layer message parts via a user interface
 */
@protocol LYRUIMessagePresenting <NSObject>

/**
 @abstract Asks the reciever to display a message part
 */
- (void)presentMessagePart:(LYRMessagePart *)messagePart;

/**
 @abstract Tells the reciever how wide it's bubble view should be
 */
- (void)updateBubbleViewWidth:(CGFloat)width;

@end