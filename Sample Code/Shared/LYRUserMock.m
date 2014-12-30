//
//  LYRUserMock.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/31/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRUserMock.h"

NSString *const LYRMockUserIDMarshawn = @"0000000001";
NSString *const LYRMockUserIDRussell = @"0000000002";
NSString *const LYRMockUserIDCam = @"0000000003";
NSString *const LYRMockUserIDEarl = @"0000000004";
NSString *const LYRMockUserIDBobby = @"0000000005";
NSString *const LYRMockUserIDRichard = @"0000000006";
NSString *const LYRMockUserIDDoug = @"0000000007";

@interface LYRUserMock ()

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

+ (instancetype)userWithMockUserName:(LYRClientMockUserName)mockUserName
{
    switch (mockUserName) {
        case LYRClientMockFactoryNameMarshawn:
            return [[LYRUserMock alloc] initWithFirstName:@"Marshawn" lastName:@"Lynch" participantIdentifier:LYRMockUserIDMarshawn];
            break;
        case LYRClientMockFactoryNameRussell:
            return [[LYRUserMock alloc] initWithFirstName:@"Russell" lastName:@"Wilson" participantIdentifier:LYRMockUserIDRussell];
            break;
        case LYRClientMockFactoryNameCam:
            return [[LYRUserMock alloc] initWithFirstName:@"Cam" lastName:@"Chancellor" participantIdentifier:LYRMockUserIDCam];
            break;
        case LYRClientMockFactoryNameEarl:
            return [[LYRUserMock alloc] initWithFirstName:@"Earl" lastName:@"Thomas" participantIdentifier:LYRMockUserIDEarl];
            break;
        case LYRClientMockFactoryNameBobby:
            return [[LYRUserMock alloc] initWithFirstName:@"Bobby" lastName:@"Wagner" participantIdentifier:LYRMockUserIDBobby];
            break;
        case LYRClientMockFactoryNameRichard:
            return [[LYRUserMock alloc] initWithFirstName:@"Richard" lastName:@"Sherman" participantIdentifier:LYRMockUserIDRichard];
            break;
        case LYRClientMockFactoryNameDoug:
            return [[LYRUserMock alloc] initWithFirstName:@"Doug" lastName:@"Baldwin" participantIdentifier:LYRMockUserIDDoug];
            break;
        default:
            break;
    }
}

+ (instancetype)mockUserForIdentifier:(NSString *)userIdentifier
{
    if ([userIdentifier isEqualToString:LYRMockUserIDMarshawn]) {
        return [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameMarshawn];
    } else if ([userIdentifier isEqualToString:LYRMockUserIDRussell]) {
        return [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    } else if ([userIdentifier isEqualToString:LYRMockUserIDCam]) {
        return [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameCam];
    } else if ([userIdentifier isEqualToString:LYRMockUserIDEarl]) {
        return [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameEarl];
    } else if ([userIdentifier isEqualToString:LYRMockUserIDBobby]) {
        return [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby];
    } else if ([userIdentifier isEqualToString:LYRMockUserIDRichard]) {
        return [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRichard];
    } else if ([userIdentifier isEqualToString:LYRMockUserIDDoug]) {
        return [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameDoug];
    }
    return nil;
}

+ (NSSet *)allMockParticipants
{
    return [NSSet setWithObjects:
                  [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameMarshawn],
                  [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell],
                  [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameCam],
                  [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameEarl],
                  [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameBobby],
                  [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRichard],
                  [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameDoug],
            nil];
    
}

+ (NSSet *)participantsForIdentifiers:(NSSet *)identifiers
{
    NSMutableArray *users = [NSMutableArray new];
    for (NSString *identifier in [identifiers allObjects]) {
        [users addObject:[self mockUserForIdentifier:identifier]];
    }
    return [NSSet setWithArray:users];
}

+ (instancetype)randomUser
{
    int randomUserName = arc4random_uniform(6);
    return  [self userWithMockUserName:randomUserName];
}

- (NSString *)fullName
{
    return _fullName;
}

@end
