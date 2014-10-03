//
//  LYRUIParticipant.h
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @abstract The `LYRUIParticipant` protocol must be adopted by objects wishing to represent Layer
 participants in the user interface.
 */
@protocol LYRUIParticipant <NSObject>

/**
 @abstract The first name of the participant as it should be presented in the user interface.
 */
@property (nonatomic, readonly) NSString *firstName;

/**
 @abstract The last name of the participant as it should be presented in the user interface.
 */
@property (nonatomic, readonly) NSString *lastName;

/**
 @abstract The full name of the participant as it should be presented in the user interface.
 */
@property (nonatomic, readonly) NSString *fullName;

/**
@abstract Returns the avatar image of the receiver.
*/
@property (nonatomic, readonly) UIImage *avatarImage;

/**
 @abstract The unique identifier of the participant as it should be used for Layer addressing.
 @discussion This identifier is issued by the Layer identity provider backend.
 */
@property (nonatomic, readonly) NSString *participantIdentifier;

/**
 @abstract Returns the text to be used for sectioning.
 @discussion Typically the first name, last name, or company name is used for sectioning.
 */
@property (nonatomic, readonly) NSString *sectionText;

@end

