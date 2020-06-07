//
//  ATLUTestInterface.h
//  Atlas
//
//  Created by Kevin Coleman on 12/16/14.
//  Copyright (c) 2015 Layer. All rights reserved.
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
#import "LYRClientMock.h"

// Testing Imports
#import <OCMock/OCMock.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import "LYRCountDownLatch.h"
#import "KIFTestCase.h"
#import <KIF/KIF.h>
#import "KIFSystemTestActor+ViewControllerActions.h"
#import <Atlas/Atlas.h>
#import "ATLTestClasses.h"
#import "LYRMockContentStore.h"

LYRMessagePartMock *ATLMessagePartWithText(NSString *text);

LYRMessagePartMock *ATLMessagePartWithJPEGImage(UIImage *image);

LYRMessagePartMock *ATLMessagePartWithGIFImage(UIImage *image);

LYRMessagePartMock *ATLMessagePartForImageSize(UIImage *image);

LYRMessagePartMock *ATLMessagePartWithLocation(CLLocation *location);

@interface ATLTestInterface : NSObject

@property (nonatomic)LYRClientMock *layerClient;

+ (instancetype)testIntefaceWithLayerClient:(LYRClientMock *)layerClient;

- (LYRConversationMock *)conversationWithParticipants:(NSSet *)participants lastMessageText:(NSString *)lastMessageText;

- (NSString *)conversationLabelForConversation:(LYRConversationMock *)conversation;

- (void)presentViewController:(UIViewController *)controller;

- (void)dismissPresentedViewController;

@end
