//
//  ATLMessagePartMock.h
//  Atlas
//
//  Created by Kevin Coleman on 12/9/14.
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
#import "LayerKitMock.h"
#import "ATLMessagingUtilities.h"

@interface LYRMessagePartMock : NSObject

+ (instancetype)messagePartWithMIMEType:(NSString *)MIMEType data:(NSData *)data;

+ (instancetype)messagePartWithMIMEType:(NSString *)MIMEType stream:(NSInputStream *)stream;

+ (instancetype)messagePartWithText:(NSString *)text;

@property (nonatomic, readonly) NSURL *identifier LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) NSUInteger index LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) LYRMessage *message LYR_QUERYABLE_PROPERTY;
@property (nonatomic, readonly) NSString *MIMEType LYR_QUERYABLE_PROPERTY LYR_QUERYABLE_FROM(LYRMessage);
@property (nonatomic) NSData *data;
@property (nonatomic) NSURL *fileURL;
@property (nonatomic, readonly) NSUInteger size LYR_QUERYABLE_PROPERTY LYR_QUERYABLE_FROM(LYRMessage);
@property (nonatomic, readonly) LYRContentTransferStatus transferStatus LYR_QUERYABLE_PROPERTY LYR_QUERYABLE_FROM(LYRMessage);
@property (nonatomic, readonly) LYRProgress *progress;

- (NSInputStream *)inputStream;

@end
