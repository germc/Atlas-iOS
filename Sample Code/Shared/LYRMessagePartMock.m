//
//  LYRMessagePartMock.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 12/9/14.
//
//

#import "LYRMessagePartMock.h"

@interface LYRMessagePartMock ()

@property (nonatomic, readwrite) NSString *MIMEType;
@property (nonatomic, readwrite) NSData *data;

@end

@implementation LYRMessagePartMock

+ (instancetype)messagePartWithMIMEType:(NSString *)MIMEType data:(NSData *)data
{
    return [[self alloc] initWithMIMEType:MIMEType data:data];
}

+ (instancetype)messagePartWithMIMEType:(NSString *)MIMEType stream:(NSInputStream *)stream
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Method not yet implemented" userInfo:nil];
}

+ (instancetype)messagePartWithText:(NSString *)text
{
   return [[self alloc] initWithMIMEType:LYRUIMIMETypeTextPlain data:[text dataUsingEncoding:NSUTF8StringEncoding]];
}

- (id)initWithMIMEType:(NSString *)MIMEType data:(NSData *)data
{
    self = [super init];
    if (self) {
        _MIMEType = MIMEType;
        _data = data;
    }
    return self;
}

- (NSInputStream *)inputStream
{
    return nil;
}

@end
