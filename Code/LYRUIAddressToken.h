//
//  LYRUIAddressToken.h
//  Pods
//
//  Created by Kevin Coleman on 10/30/14.
//
//

#import <Foundation/Foundation.h>
#import "LYRUIParticipant.h"

/**
 @abstract The `LYRUIAddressToken` represents an individual participant which is displayed in the 
 `LYRUIAddressBarController`. 
 @discussion The class contains an object which conforms to the `LYRUIParticipant`
 protocol and an `NSRange` object. The `NSRange` object allows for selection of the entire text
 of a participants name upon reciept of a tap event.
 */

@interface LYRUIAddressToken : NSObject

+ (instancetype)tokenWithParticipant:(id<LYRUIParticipant>)particiapnt range:(NSRange)range;

@property (nonatomic) id<LYRUIParticipant>participant;

@property (nonatomic) NSRange range;

@end
