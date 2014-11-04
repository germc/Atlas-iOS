//
//  LYRUIAddressToken.m
//  Pods
//
//  Created by Kevin Coleman on 10/30/14.
//
//

#import "LYRUIAddressToken.h"

@implementation LYRUIAddressToken

+ (instancetype)tokenWithParticipant:(id<LYRUIParticipant>)particiapnt range:(NSRange)range;
{
    return [[self alloc] initWithParticipant:particiapnt range:range];
}

- (id)initWithParticipant:(id<LYRUIParticipant>)participant range:(NSRange)range
{
    self = [super init];
    if (self) {
        _participant = participant;
        _range = range;
    }
    return self;
}
@end
