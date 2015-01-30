//
//  LYRUIErrors.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 9/26/14.
//
//

#import <Foundation/Foundation.h>

extern NSString *const LYRUIErrorDomain;

typedef NS_ENUM(NSUInteger, LYRUIError) {
    LYRUIErrorUnknownError                            = 1000,
    
    /* Messaging Errors */
    LYRUIErrorUnauthenticated                         = 1001,
    LYRUIErrorInvalidMessage                          = 1002,
    LYRUIErrorTooManyParticipants                     = 1003,
    LYRUIErrorDataLengthExceedsMaximum                = 1004,
    LYRUIErrorMessageAlreadyMarkedAsRead              = 1005,
    LYRUIErrorObjectNotSent                           = 1006,
    LYRUIErrorNoPhotos                                = 1007
};




