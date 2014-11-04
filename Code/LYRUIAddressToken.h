//
//  LYRUIAddressToken.h
//  Pods
//
//  Created by Kevin Coleman on 10/30/14.
//
//

#import <Foundation/Foundation.h>
#import "LYRUIParticipant.h"

@interface LYRUIAddressToken : NSObject

@property (nonatomic) id<LYRUIParticipant>participant;
@property (nonatomic) NSRange range;

+ (instancetype)tokenWithParticipant:(id<LYRUIParticipant>)particiapnt range:(NSRange)range;

@end
