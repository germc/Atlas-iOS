//
//  ATLUIImageHelper.h
//  Pods
//
//  Created by Kabir Mahal on 3/18/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ATLUIImageHelper : NSObject

+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data;

+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url;

@end
