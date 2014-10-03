//
//  LYRUIErrors.h
//  Pods
//
//  Created by Kevin Coleman on 9/26/14.
//
//

#import <Foundation/Foundation.h>

extern NSString *const LYRUIErrorDomain;

typedef NS_ENUM(NSUInteger, LYRUIError) {
    LYRErrorUnknownError                            = 1000,
    
    /* Messaging Errors */
    LYRErrorUnauthenticated                         = 1001,
    LYRErrorInvalidMessage                          = 1002,
    LYRErrorTooManyParticipants                     = 1003,
    LYRErrorDataLengthExceedsMaximum                = 1004,
    LYRErrorMessageAlreadyMarkedAsRead              = 1005,
    LYRErrorObjectNotSent                           = 1006
};




