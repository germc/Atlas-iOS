//
//  ATLUITestUtilities.m
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

#import "ATLTestInterface.h"
#import "ProgrammaticAppDelegate.h"
#import "LYRMessagePartMock.h"

#pragma mark - Message Parts Constructors

LYRMessagePartMock *ATLMessagePartWithText(NSString *text)
{
    return [LYRMessagePartMock messagePartWithMIMEType:ATLMIMETypeTextPlain data:[text dataUsingEncoding:NSUTF8StringEncoding]];
}

LYRMessagePartMock *ATLMessagePartWithJPEGImage(UIImage *image)
{
    return [LYRMessagePartMock messagePartWithMIMEType:ATLMIMETypeImageJPEG
                                              data:UIImageJPEGRepresentation(image, 0.1)];
}

LYRMessagePartMock *ATLMessagePartWithGIFImage(UIImage *image)
{
    return [LYRMessagePartMock messagePartWithMIMEType:ATLMIMETypeImageGIF
                                                  data:UIImageJPEGRepresentation(image, 0.1)];
}

LYRMessagePartMock *ATLMessagePartForImageSize(UIImage *image)
{
    CGSize size = ATLImageSize(image);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{ATLImagePreviewWidthKey : @(size.width), ATLImagePreviewHeightKey : @(size.height)}
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    return [LYRMessagePartMock messagePartWithMIMEType:ATLMIMETypeImageSize data:jsonData];
}

LYRMessagePartMock *ATLMessagePartWithLocation(CLLocation *location)
{
    NSNumber *lat = @(location.coordinate.latitude);
    NSNumber *lon = @(location.coordinate.longitude);
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{ATLLocationLatitudeKey: lat, ATLLocationLongitudeKey: lon} options:0 error:nil];
    return [LYRMessagePartMock messagePartWithMIMEType:ATLMIMETypeLocation data:data];
}

@interface ATLTestInterface ()

@end

@implementation ATLTestInterface

+ (instancetype)testIntefaceWithLayerClient:(LYRClientMock *)layerClient
{
    return [[self alloc] initWithLayerClient:layerClient];
}

- (id)initWithLayerClient:(LYRClientMock *)layerClient
{
    self = [super init];
    if (self) {
        _layerClient = layerClient;
        [[LYRMockContentStore sharedStore] setShouldBroadcastChanges:YES];
        
    }
    return self;
}

- (LYRConversationMock *)conversationWithParticipants:(NSSet *)participants lastMessageText:(NSString *)lastMessageText
{
    LYRConversationMock *conversation = [self.layerClient newConversationWithParticipants:participants options:nil error:nil];
    if (lastMessageText) {
        LYRMessagePart *part = [LYRMessagePart messagePartWithText:lastMessageText];
        LYRMessageMock *message = [self.layerClient newMessageWithParts:@[part] options:nil error:nil];
        [conversation sendMessage:message error:nil];
    }
    return conversation;
}

- (NSString *)conversationLabelForConversation:(LYRConversationMock *)conversation
{
    if (!self.layerClient.authenticatedUserID) return @"Not auth'd";
    NSMutableSet *participantIdentifiers = [conversation.participants mutableCopy];
    [participantIdentifiers removeObject:self.layerClient.authenticatedUserID];
    
    if (participantIdentifiers.count == 0) return @"Personal Conversation";
    
    NSMutableSet *participants = [[ATLUserMock participantsForIdentifiers:participantIdentifiers] mutableCopy];
    if (participants.count == 0) return @"No Matching Participants";
    
    // Put the latest message sender's name first
    ATLUserMock *firstUser;
    if (![conversation.lastMessage.sender.userID isEqualToString:self.layerClient.authenticatedUserID]) {
        if (conversation.lastMessage) {
            NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF.participantIdentifier IN %@", conversation.lastMessage.sender.userID];
            ATLUserMock *lastMessageSender = [[[participants filteredSetUsingPredicate:searchPredicate] allObjects] lastObject];
            if (lastMessageSender) {
                firstUser = lastMessageSender;
                [participants removeObject:lastMessageSender];
            }
        }
    } else {
        firstUser = [[participants allObjects] objectAtIndex:0];
    }
    
    NSString *conversationLabel = firstUser.fullName;
    for (int i = 1; i < [[participants allObjects] count]; i++) {
        ATLUserMock *user = [[participants allObjects] objectAtIndex:i];
        conversationLabel = [NSString stringWithFormat:@"%@, %@", conversationLabel, user.fullName];
    }
    return conversationLabel;
}

- (void)presentViewController:(UIViewController *)controller
{
    ProgrammaticAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    delegate.window.rootViewController = navigationController;
}

- (void)dismissPresentedViewController
{
    ProgrammaticAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    delegate.window.rootViewController = nil;
}

@end