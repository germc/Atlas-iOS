//
//  LYRUserMock.m
//  Atlas
//
//  Created by Klemen Verdnik on 10/31/14.
//  Copyright (c) 2014 Layer. All rights reserved.
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

#import "ATLUserMock.h"

NSString *const ATLMockUserIDBlake = @"0";
NSString *const ATLMockUserIDKlemen = @"1";
NSString *const ATLMockUserIDKevin = @"2";
NSString *const ATLMockUserIDSteven = @"3";
NSString *const ATLMockUserIDVivek = @"4";
NSString *const ATLMockUserIDAmar = @"5";

@interface ATLUserMock ()

@end

@implementation ATLUserMock

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName participantIdentifier:(NSString *)participantIdentifier
{
    self = [super init];
    if (self) {
        _firstName = firstName;
        _lastName = lastName;
        _participantIdentifier = participantIdentifier;
        _fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        _avatarImageURL = [NSURL URLWithString:@"http://lorempixel.com/400/200/"];
    }
    return self;
}

+ (instancetype)userWithMockUserName:(ATLMockUserName)mockUserName
{
    switch (mockUserName) {
        case ATLMockUserNameBlake:
            return [[ATLUserMock alloc] initWithFirstName:@"Blake" lastName:@"Watter" participantIdentifier:ATLMockUserIDBlake];
            break;
        case ATLMockUserNameKlemen:
            return [[ATLUserMock alloc] initWithFirstName:@"Klemen" lastName:@"Verdnik" participantIdentifier:ATLMockUserIDKlemen];
            break;
        case ATLMockUserNameKevin:
            return [[ATLUserMock alloc] initWithFirstName:@"Kevin" lastName:@"Coleman" participantIdentifier:ATLMockUserIDKevin];
            break;
        case ATLMockUserNameSteven:
            return [[ATLUserMock alloc] initWithFirstName:@"Steven" lastName:@"Jones" participantIdentifier:ATLMockUserIDSteven];
            break;
        case ATLMockUserNameVivek:
            return [[ATLUserMock alloc] initWithFirstName:@"Vivek" lastName:@"Trehan" participantIdentifier:ATLMockUserIDVivek];
            break;
        case ATLMockUserNameAmar:
            return [[ATLUserMock alloc] initWithFirstName:@"Amar" lastName:@"Srivisan" participantIdentifier:ATLMockUserIDAmar];
            break;
        default:
            break;
    }
}

+ (instancetype)mockUserForIdentifier:(NSString *)userIdentifier
{
    if ([userIdentifier isEqualToString:ATLMockUserIDBlake]) {
        return [ATLUserMock userWithMockUserName:ATLMockUserNameBlake];
    } else if ([userIdentifier isEqualToString:ATLMockUserIDKlemen]) {
        return [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen];
    } else if ([userIdentifier isEqualToString:ATLMockUserIDKevin]) {
        return [ATLUserMock userWithMockUserName:ATLMockUserNameKevin];
    } else if ([userIdentifier isEqualToString:ATLMockUserIDSteven]) {
        return [ATLUserMock userWithMockUserName:ATLMockUserNameSteven];
    } else if ([userIdentifier isEqualToString:ATLMockUserIDVivek]) {
        return [ATLUserMock userWithMockUserName:ATLMockUserNameVivek];
    } else if ([userIdentifier isEqualToString:ATLMockUserIDAmar    ]) {
        return [ATLUserMock userWithMockUserName:ATLMockUserNameAmar];
    }
    return nil;
}

+ (NSSet *)allMockParticipants
{
    return [NSSet setWithObjects:
                  [ATLUserMock userWithMockUserName:ATLMockUserNameBlake],
                  [ATLUserMock userWithMockUserName:ATLMockUserNameKlemen],
                  [ATLUserMock userWithMockUserName:ATLMockUserNameKevin],
                  [ATLUserMock userWithMockUserName:ATLMockUserNameSteven],
                  [ATLUserMock userWithMockUserName:ATLMockUserNameVivek],
                  [ATLUserMock userWithMockUserName:ATLMockUserNameAmar],
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

+ (NSSet *)participantsWithText:(NSString *)text
{
    NSMutableArray *users = [NSMutableArray new];
    NSMutableSet *allUsers = [[self allMockParticipants] mutableCopy];
    for (ATLUserMock *mock in allUsers) {
        if ([mock.fullName rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [users addObject:mock];
        }
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

- (NSString *)avatarInitials
{
    return [NSString stringWithFormat:@"%@%@", [self.firstName substringToIndex:1], [self.lastName substringToIndex:1]];
}

@end
