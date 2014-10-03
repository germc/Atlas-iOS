//
//  LYRUIMediaAttachment.m
//  LayerSample
//
//  Created by Kevin Coleman on 9/12/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIMediaAttachment.h"
#import "LYRUIUtilities.h"

@implementation LYRUIMediaAttachment

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    CGRect systemImageRect = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
    return LYRUIImageRectConstrainedToSize(systemImageRect.size, CGSizeMake(150, 150));
}

@end
