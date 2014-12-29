//
//  LYRConversationMock.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/8/14.
//
//

#import <Foundation/Foundation.h>
#import "LYRMessageMock.h"
#import <LayerKit/LayerKit.h>

@class LYRMessageMock;

@interface LYRConversationMock : NSObject <LYRQueryable>

@property (nonatomic, readonly) NSURL *identifier LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) NSSet *participants LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) NSDate *createdAt LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) LYRMessageMock *lastMessage LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) BOOL hasUnreadMessages LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) BOOL isDeleted;
@property (nonatomic, readonly) NSDictionary *metadata;

+ (instancetype)newConversationWithParticipants:(NSSet *)participants options:(NSDictionary *)options;

- (BOOL)sendMessage:(LYRMessageMock *)message error:(NSError **)error;

- (BOOL)addParticipants:(NSSet *)participants error:(NSError **)error;

- (BOOL)removeParticipants:(NSSet *)participants error:(NSError **)error;

- (void)setValue:(NSString *)value forMetadataAtKeyPath:(NSString *)keyPath;

- (void)setValuesForMetadataKeyPathsWithDictionary:(NSDictionary *)metadata merge:(BOOL)merge;

- (void)deleteValueForMetadataAtKeyPath:(NSString *)keyPath;

- (void)sendTypingIndicator:(LYRTypingIndicator)typingIndicator;

- (BOOL)delete:(LYRDeletionMode)deletionMode error:(NSError **)error;

- (BOOL)markAllMessagesAsRead:(NSError **)error;

@end
