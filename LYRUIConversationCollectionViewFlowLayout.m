//
//  LYRUIConversationCollectionViewFlowLayout.m
//  Pods
//
//  Created by Kevin Coleman on 9/27/14.
//
//

#import "LYRUIConversationCollectionViewFlowLayout.h"

@implementation LYRUIConversationCollectionViewFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attrs = [super layoutAttributesForElementsInRect:rect];
    return attrs;
}
@end
