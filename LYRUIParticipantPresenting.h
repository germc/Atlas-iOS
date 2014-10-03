//
//  LYRUIParticipantPresenting.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRUIParticipant.h"

/**
 @abstract The `LYRUIParticipantPresenting` protocol must be adopted by objects that wish to present Layer
 participants in the user interface.
 */
@protocol LYRUIParticipantPresenting <NSObject>

/**
 @abstract Tells the receiver to present an interface for the given participant.
 @param participant The participant to present.
 */
- (void)presentParticipant:(id<LYRUIParticipant>)participant;

- (void)shouldDisplaySelectionIndicator:(BOOL)shouldDisplaySelectionIndicator;

@end
