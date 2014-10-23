//
//  LYRUIAvatarImageView.m
//  Pods
//
//  Created by Kevin Coleman on 10/22/14.
//
//

#import "LYRUIAvatarImageView.h"

@implementation LYRUIAvatarImageView

- (void)setInitialsForName:(NSString *)name
{
    NSArray *names = [name componentsSeparatedByString:@" "];
    NSMutableString *initials = @"";
    for (NSString *name in names) {
        [initials appendString:[name substringToIndex:1]];
    }
    
}

@end
