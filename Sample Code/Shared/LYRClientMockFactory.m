//
//  LYRClientMockFactory.m
//  LayerUIKit
//
//  Created by Klemen Verdnik on 10/31/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import "LYRClientMockFactory.h"
#import <LayerKit/LayerKit.h>

NSString *const LYRClientMockFactoryNameAlice       = @"Alice";
NSString *const LYRClientMockFactoryNameBob         = @"Bob";
NSString *const LYRClientMockFactoryNameCarol       = @"Carol";

@interface LYRClientMockFactory ()

@property (nonatomic, readwrite) LYRClientMock *layerClient;
@property (nonatomic) dispatch_queue_t dispatchQueue;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) dispatch_source_t dispatchSource;
@property (nonatomic, getter=isTimerRunning) BOOL timerRunning;
@property (nonatomic) NSUInteger minimumTimeInterval;
@property (nonatomic) NSUInteger maximumTimeInterval;

@end

@interface LYRMessageMock ()

@property (nonatomic, readwrite) NSString *sentByUserID;
@property (nonatomic, readwrite) NSDate *sentAt;
@property (nonatomic, readwrite) NSDate *receivedAt;

@end

@implementation LYRClientMockFactory

#pragma mark - Initializers

- (instancetype)initWithAuthenticatedUserID:(NSString *)authenticatedUserID
{
    self = [super init];
    if (self) {
        _layerClient = [LYRClientMock layerClientMockWithAuthenticatedUserID:authenticatedUserID];
        _dispatchQueue = dispatch_queue_create("com.layer.LayerUIKit.TimedIncomingMessages", NULL);
        _timerRunning = NO;
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterNoStyle;
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        _minimumTimeInterval = 2;
        _maximumTimeInterval = 7;
    }
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"Failed to call designated initializer, use %@", NSStringFromSelector(@selector(initWithAuthenticatedUserID:))]  userInfo:nil];
}

+ (instancetype)emptyClientWithAuthenticatedUserID:(NSString *)authenticatedUserID
{
    return [[LYRClientMockFactory alloc] initWithAuthenticatedUserID:authenticatedUserID];
}

- (NSString *)authenticatedUserID
{
    return self.layerClient.authenticatedUserID;
}

- (void)dealloc
{
    [self stopTimedIncomingMessages];
}

#pragma mark - Factory methods

+ (LYRClientMockFactory *)emptyClientForAlice
{
    return [LYRClientMockFactory emptyClientWithAuthenticatedUserID:LYRClientMockFactoryNameAlice];
}

+ (LYRClientMockFactory *)emptyClientForBob
{
    return [LYRClientMockFactory emptyClientWithAuthenticatedUserID:LYRClientMockFactoryNameBob];
}

+ (LYRClientMockFactory *)emptyClientForCarol
{
    return [LYRClientMockFactory emptyClientWithAuthenticatedUserID:LYRClientMockFactoryNameCarol];
}

+ (LYRClientMockFactory *)clientForAliceWithConversation
{
    LYRClientMockFactory *factory = [LYRClientMockFactory emptyClientWithAuthenticatedUserID:LYRClientMockFactoryNameAlice];
    [factory addConversationBetweenAliceAndBob];
    return factory;
}

#pragma mark - ParticipantID-to-user resolver

+ (LYRUserMock *)userForParticipantIdentifier:(NSString *)participantIdentifier
{
    if ([participantIdentifier isEqualToString:LYRClientMockFactoryNameAlice]) {
        return [LYRUserMock userWithFirstName:@"Alice" lastName:@"Liddell" participantIdentifier:LYRClientMockFactoryNameAlice];
    } else if ([participantIdentifier isEqualToString:LYRClientMockFactoryNameBob]) {
        return [LYRUserMock userWithFirstName:@"Bob" lastName:@"Wiley" participantIdentifier:LYRClientMockFactoryNameBob];
    } else if ([participantIdentifier isEqualToString:LYRClientMockFactoryNameCarol]) {
        return [LYRUserMock userWithFirstName:@"Carol" lastName:@"Peletier" participantIdentifier:LYRClientMockFactoryNameCarol];
    }
    return [LYRUserMock userWithFirstName:@"John" lastName:@"Doe" participantIdentifier:participantIdentifier];
}

#pragma mark - Timed incoming messages

- (void)startTimedIncomingMessages
{
    if (self.timerRunning) [self stopTimedIncomingMessages];
    self.timerRunning = YES;
    double randomInterval = ((double)arc4random_uniform((uint32_t)(self.maximumTimeInterval * 10)) + (uint32_t)(self.minimumTimeInterval *10))/10;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(randomInterval * NSEC_PER_SEC)), self.dispatchQueue, ^{
        [self receiveIncomingMessageFromRandomParticipant];
        if (self.timerRunning) [self startTimedIncomingMessages];
    });
//    _dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _dispatchQueue);
//    uint64_t interval = (uint64_t)(((double)arc4random_uniform(30)/10) * NSEC_PER_SEC);
//    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, interval);
//    dispatch_source_set_timer(_dispatchSource, startTime, interval, 1.0);
//    dispatch_source_set_event_handler(_dispatchSource, ^{
//        [self receiveIncomingMessageFromRandomParticipant];
//        if (self.timerRunning) [self startTimedIncomingMessages];
//    });
//    dispatch_resume(self.dispatchSource);
}

- (void)stopTimedIncomingMessages
{
    self.timerRunning = NO;
//    if (!_dispatchSource) return;
//    dispatch_source_cancel(_dispatchSource);
//    _dispatchSource = NULL;
}

- (void)receiveIncomingMessageFromRandomParticipant
{
    LYRConversationMock *conversation = [[self.layerClient conversationsForIdentifiers:nil] anyObject];
    if (!conversation) {
        conversation = [LYRClientMockFactory conversationBetweenAliceAndBob];
    }
    NSMutableSet *participantsWithoutAuthenticatedUser = conversation.participants.mutableCopy;
    [participantsWithoutAuthenticatedUser removeObject:self.layerClient.authenticatedUserID];
    NSString *participant = [[participantsWithoutAuthenticatedUser allObjects] objectAtIndex:arc4random_uniform((uint32_t)participantsWithoutAuthenticatedUser.count)];
    LYRMessageMock *message = [LYRClientMockFactory messageForConversation:conversation sentByUserID:participant text:[NSString stringWithFormat:@"Hi from '%@' sent at: %@", participant, [self.dateFormatter stringFromDate:[NSDate date]]]];
    [self.layerClient receiveMessage:message];
}

#pragma mark - Conversation department

- (void)addConversationBetweenAliceAndBob
{
    LYRConversationMock *conversation = [LYRClientMockFactory conversationBetweenAliceAndBob];
    [self.layerClient receiveMessage:[LYRClientMockFactory messageForConversation:conversation sentByUserID:LYRClientMockFactoryNameAlice text:@"You've got a lot of explaining to do."]];
    [self.layerClient receiveMessage:[LYRClientMockFactory messageForConversation:conversation sentByUserID:LYRClientMockFactoryNameBob text:@"She told you about the noodles, didn't she?!"]];
    [self.layerClient receiveMessage:[LYRClientMockFactory messageForConversation:conversation sentByUserID:LYRClientMockFactoryNameBob text:@"NO ONE CAN PROVE I DID THAT!"]];
    [self.layerClient receiveMessage:[LYRClientMockFactory messageForConversation:conversation sentByUserID:LYRClientMockFactoryNameAlice text:@"sure, sure ..."]];
}

+ (LYRConversationMock *)conversationBetweenAliceAndBob
{
    return [LYRConversationMock conversationWithParticipants:[NSSet setWithArray:@[LYRClientMockFactoryNameAlice, LYRClientMockFactoryNameBob]]];
}

+ (LYRMessageMock *)messageForConversation:(LYRConversationMock *)conversation sentByUserID:(NSString *)sentByUserID text:(NSString *)text
{
    LYRMessageMock *message = [LYRMessageMock messageWithConversation:conversation parts:@[[LYRMessagePart messagePartWithText:text]] userID:sentByUserID];
    message.sentByUserID = sentByUserID;
    message.sentAt = [NSDate date];
    message.receivedAt = [NSDate date];
    return message;
}

+ (NSArray *)messagesForConversation:(LYRConversationMock *)conversation sentByUserID:(NSString *)sentByUserID textArray:(NSArray *)textArray
{
    NSMutableArray *messages = [NSMutableArray array];
    for (NSString *text in textArray) {
        [messages addObject:[LYRClientMockFactory messageForConversation:conversation sentByUserID:sentByUserID text:text]];
    }
    return messages;
}

@end
