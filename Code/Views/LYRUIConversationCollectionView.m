//
//  LYRUIConversationCollectionView.m
//  Pods
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
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor clearColor];
        self.alwaysBounceVertical = YES;
        self.bounces = YES;
        self.accessibilityIdentifier = LYRUIConversationCollectionViewAccessibilityIdentifier;
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        [self registerReuseIdentifiers];
    }
    return self;
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
                   withReuseIdentifier:LYRUIMessageCellHeaderIdentifier];
    
    [self registerClass:[LYRUIConversationCollectionViewFooter class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:LYRUIMessageCellFooterIdentifier];
}
@end
