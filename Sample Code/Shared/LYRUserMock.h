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

@interface LYRUserMock : NSObject <LYRUIParticipant>

@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *fullName;
@property (nonatomic, readonly) UIImage *avatarImage;
@property (nonatomic, readonly) NSString *participantIdentifier;

+ (instancetype)userWithFirstName:(NSString *)firstName lastName:(NSString *)lastName participantIdentifier:(NSString *)participantIdentifier;

@end
