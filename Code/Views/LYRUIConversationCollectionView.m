//
//  LYRUIConversationCollectionView.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 1/30/15.
//
//

#import "LYRUIConversationCollectionView.h"

@implementation LYRUIConversationCollectionView

NSString *const LYRUIConversationViewControllerAccessibilityLabel = @"Conversation View Controller";
NSString *const LYRUIConversationCollectionViewAccessibilityIdentifier = @"Conversation Collection View";

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (void)lyr_commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.alwaysBounceVertical = YES;
    self.bounces = YES;
    self.accessibilityIdentifier = LYRUIConversationCollectionViewAccessibilityIdentifier;
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self registerReuseIdentifiers];
}

- (void)registerReuseIdentifiers
{
    [self registerClass:[LYRUIIncomingMessageCollectionViewCell class]
            forCellWithReuseIdentifier:LYRUIIncomingMessageCellIdentifier];
    
    [self registerClass:[LYRUIOutgoingMessageCollectionViewCell class]
            forCellWithReuseIdentifier:LYRUIOutgoingMessageCellIdentifier];
    
    [self registerClass:[LYRUIConversationCollectionViewMoreMessagesHeader class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:LYRUIMoreMessagesHeaderIdentifier];
    
    [self registerClass:[LYRUIConversationCollectionViewHeader class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:LYRUIConversationViewHeaderIdentifier];
    
    [self registerClass:[LYRUIConversationCollectionViewFooter class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:LYRUIConversationViewFooterIdentifier];
}

@end
