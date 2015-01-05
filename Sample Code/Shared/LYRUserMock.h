//
//  LYRUserMock.h
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/31/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <LayerUIKit/LYRUIParticipant.h>

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
