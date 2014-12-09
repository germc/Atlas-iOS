//
//  LYRMessageMock.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
//

#import <Foundation/Foundation.h>
#import "LayerKitMock.h"

@interface LYRMessageMock : NSObject <LYRQueryable>

@property (nonatomic) NSUInteger index LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) NSURL *identifier LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) LYRConversation *conversation LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) NSArray *parts;
@property (nonatomic, readonly) BOOL isSent LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) BOOL isDeleted;
@property (nonatomic, readonly) BOOL isUnread LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) NSDate *sentAt LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) NSDate *receivedAt LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) NSString *sentByUserID LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) NSDictionary *recipientStatusByUserID;

+ (instancetype)newMessageWithParts:(NSArray *)messageParts senderID:(NSString *)senderID;

- (BOOL)markAsRead:(NSError **)error;

- (BOOL)delete:(LYRDeletionMode)deletionMode error:(NSError **)error;

- (LYRRecipientStatus)recipientStatusForUserID:(NSString *)userID;

@end
