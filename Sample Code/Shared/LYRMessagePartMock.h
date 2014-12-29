//
//  LYRMessagePartMock.h
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/9/14.
//
//

#import <Foundation/Foundation.h>
#import "LayerKitMock.h"

@interface LYRMessagePartMock : NSObject

+ (instancetype)messagePartWithMIMEType:(NSString *)MIMEType data:(NSData *)data;

+ (instancetype)messagePartWithMIMEType:(NSString *)MIMEType stream:(NSInputStream *)stream;

+ (instancetype)messagePartWithText:(NSString *)text;

@property (nonatomic, readonly) NSString *MIMEType;
@property (nonatomic, readonly) NSData *data;

- (NSInputStream *)inputStream;

@end
