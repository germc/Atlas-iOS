//
//  LYRUITestUtilities.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/16/14.
//
//

#import "LYRUITestUtilities.h"

@implementation LYRUITestUtilities

+ (LYRClientMock *)layerClientMock
{
    LYRUserMock *mockUser = [LYRUserMock userWithMockUserName:LYRClientMockFactoryNameRussell];
    return [LYRClientMock layerClientMockWithAuthenticatedUserID:mockUser.participantIdentifier];
}

@end
