//
//  LYRUserMock.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/31/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRUserMock.h"

@interface LYRUserMock ()

@property (nonatomic, readwrite) NSString *firstName;
@property (nonatomic, readwrite) NSString *lastName;
@property (nonatomic, readwrite) NSString *fullName;
@property (nonatomic, readwrite) UIImage *avatarImage;
@property (nonatomic, readwrite) NSString *participantIdentifier;

@end

@implementation LYRUserMock

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName participantIdentifier:(NSString *)participantIdentifier
{
    self = [super init];
    if (self) {
        _firstName = firstName;
        _lastName = lastName;
        _participantIdentifier = participantIdentifier;
        _fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    return self;
}

+ (instancetype)userWithFirstName:(NSString *)firstName lastName:(NSString *)lastName participantIdentifier:(NSString *)participantIdentifier
{
    return [[LYRUserMock alloc] initWithFirstName:firstName lastName:lastName participantIdentifier:participantIdentifier];
}

@end
