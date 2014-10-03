//
//  LYRUIChangeNotificationObserver.m
//  Pods
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import "LYRUIChangeNotificationObserver.h"
#import "LYRUIDataSourceChange.h"

@implementation LYRUIChangeNotificationObserver

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
