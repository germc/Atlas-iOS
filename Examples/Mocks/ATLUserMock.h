//
//  LYRUserMock.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Atlas/Atlas.h>

// Layer Client Engineering Team

typedef NS_ENUM(NSUInteger, ATLMockUserName){
    ATLMockUserNameBlake,
    ATLMockUserNameKlemen,
    ATLMockUserNameKevin,
    ATLMockUserNameSteven,
    ATLMockUserNameVivek,
    ATLMockUserNameAmar,
};

/**
 @abstract The `ATLUserMock` models a sample user within the Atlas sample project. Instances of `ATLUserMock` conform to the `ATLParticipant` protocol.
 */
@interface ATLUserMock : NSObject <ATLParticipant>


@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *fullName;
@property (nonatomic) UIImage *avatarImage;
@property (nonatomic) NSURL *avatarImageURL;
@property (nonatomic) NSString *participantIdentifier;

/**
 @abstract Creates and returns an instance of `ATLUserMock` for the given `ATLMockUserName` enumeration.
 @param mockUserName An `ATLMockUserName` enumerated value.
 */
+ (instancetype)userWithMockUserName:(ATLMockUserName)mockUserName;

/**
 @abstract Creates and retruns an instance of `ATLUserMock` for a given identifier. 
 @param userIdentifier can be any number between 0 and 5. 
 @return an instance of `ATLUserMock`.
 */
+ (instancetype)mockUserForIdentifier:(NSString *)userIdentifier;

/**
 @abstract Returns a random `ATLMockuser` instance.
 */
+ (instancetype)randomUser;

/**
 @abstract Returns a `NSSet` of all possible `ATLUserMock` objects.
 */
+ (NSSet *)allMockParticipants;

/**
 @abstract Returns a `NSSet` of `ATLUserMock` objects whose participantIdentifiers match the supplied set.
 */
+ (NSSet *)participantsForIdentifiers:(NSSet *)identifiers;

/**
 @abstract Returns an `NSSet` of `ATLUserMock` object whose `fullName` property containst the text.
 */
+ (NSSet *)participantsWithText:(NSString *)text;

@end
