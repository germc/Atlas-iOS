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
#import <LayerUIKit/LayerUIKit.h>

typedef NS_ENUM(NSUInteger, LYRClientMockUserName){
    LYRClientMockFactoryNameMarshawn,
    LYRClientMockFactoryNameRussell,
    LYRClientMockFactoryNameCam,
    LYRClientMockFactoryNameEarl,
    LYRClientMockFactoryNameBobby,
    LYRClientMockFactoryNameRichard,
    LYRClientMockFactoryNameDoug
};

@interface LYRUserMock : NSObject <LYRUIParticipant>

@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *fullName;
@property (nonatomic) UIImage *avatarImage;
@property (nonatomic) NSString *participantIdentifier;

+ (instancetype)userWithMockUserName:(LYRClientMockUserName)mockUserName;

+ (instancetype)mockUserForIdentifier:(NSString *)userIdentifier;

+ (instancetype)randomUser;

+ (NSSet *)allMockParticipants;

+ (NSSet *)participantsForIdentifiers:(NSSet *)identifiers;

@end
