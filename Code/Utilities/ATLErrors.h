//
//  ATLUIErrors.h
//  Atlas
//
//  Created by Kevin Coleman on 9/26/14.
//  Copyright (c) 2015 Layer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>

extern NSString *const ATLErrorDomain;

typedef NS_ENUM(NSUInteger, ATLError) {
    ATLErrorUnknownError                            = 1000,
    
    /* Messaging Errors */
    ATLErrorUnauthenticated                         = 1001,
    ATLErrorInvalidMessage                          = 1002,
    ATLErrorTooManyParticipants                     = 1003,
    ATLErrorDataLengthExceedsMaximum                = 1004,
    ATLErrorMessageAlreadyMarkedAsRead              = 1005,
    ATLErrorObjectNotSent                           = 1006,
    ATLErrorNoPhotos                                = 1007
};




