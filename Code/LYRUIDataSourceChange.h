//
//  LYRUIDataSourceChange.h
//  Pods
//
//  Created by Kevin Coleman on 9/20/14.
//
//

#import <Foundation/Foundation.h>
#import <LayerKit/LayerKit.h>

@interface LYRUIDataSourceChange : NSObject

+ (instancetype)changeObjectWithType:(LYRQueryControllerChangeType)type newIndex:(NSUInteger)newIndex currentIndex:(NSUInteger)currentIndex;

@property (nonatomic) LYRQueryControllerChangeType type;

@property (nonatomic) NSInteger newIndex;

@property (nonatomic) NSInteger currentIndex;

@end
