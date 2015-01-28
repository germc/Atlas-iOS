//
//  LYRUIConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "LYRUIConversationViewController.h"
#import "LYRUIOutgoingMessageCollectionViewCell.h"
#import "LYRUIIncomingMessageCollectionViewCell.h"
#import "LYRUIConversationCollectionViewMoreMessagesHeader.h"
#import "LYRUIConversationCollectionViewHeader.h"
#import "LYRUIConversationCollectionViewFooter.h"
#import "LYRUIConstants.h"
#import "LYRUIDataSourceChange.h"
#import "LYRUIMessagingUtilities.h"
#import "LYRUITypingIndicatorView.h"
#import "LYRQueryController.h"
#import "LYRUIDataSourceChange.h"
#import "LYRUIConversationView.h"

@interface LYRUIConversationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LYRUIMessageInputToolbarDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate, LYRQueryControllerDelegate>

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) LYRQueryController *queryController;
@property (nonatomic) LYRUIConversationView *view;
@property (nonatomic) UILabel *typingIndicatorLabel;
@property (nonatomic) LYRUITypingIndicatorView *typingIndicatorView;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) BOOL shouldDisplayAvatarImage;
@property (nonatomic) NSLayoutConstraint *typingIndicatorViewBottomConstraint;
@property (nonatomic) NSMutableArray *typingParticipantIDs;
@property (nonatomic) NSMutableArray *objectChanges;
@property (nonatomic) NSHashTable *sectionFooters;
@property (nonatomic, getter=isFirstAppearance) BOOL firstAppearance;
@property (nonatomic) LYRUIIncomingMessageCollectionViewCell *sizingIncomingMessageCell;
@property (nonatomic) LYRUIOutgoingMessageCollectionViewCell *sizingOutgoingMessageCell;
@property (nonatomic) BOOL expandingPaginationWindow;
@property (nonatomic) BOOL showingMoreMessagesIndicator;

@end

@implementation LYRUIConversationViewController

NSString *const LYRUIConversationViewControllerAccessibilityLabel = @"Conversation View Controller";
NSString *const LYRUIConversationCollectionViewAccessibilityIdentifier = @"Conversation Collection View";

static NSString *const LYRUIIncomingMessageCellIdentifier = @"LYRUIIncomingMessageCellIdentifier";
static NSString *const LYRUIOutgoingMessageCellIdentifier = @"LYRUIOutgoingMessageCellIdentifier";
static NSString *const LYRUIMoreMessagesHeaderIdentifier = @"LYRUIMoreMessagesHeaderIdentifier";
static NSString *const LYRUIMessageCellHeaderIdentifier = @"LYRUIMessageCellHeaderIdentifier";
static NSString *const LYRUIMessageCellFooterIdentifier = @"LYUIMessageCellFooterIdentifier";

static CGFloat const LYRUITypingIndicatorHeight = 20;
static NSInteger const LYRUIMoreMessagesSection = 0;
static NSInteger const LYRUINumberOfSectionsBeforeFirstMessageSection = 1;

+ (instancetype)conversationViewControllerWithConversation:(LYRConversation *)conversation layerClient:(LYRClient *)layerClient;
{
    NSAssert(layerClient, @"`Layer Client` cannot be nil");
    return [[self alloc] initWithConversation:conversation layerClient:layerClient];
}

- (id)initWithConversation:(LYRConversation *)conversation layerClient:(LYRClient *)layerClient
{
    self = [super init];
    if (self) {
         // Set properties from designated initializer
        _conversation = conversation;
        _layerClient = layerClient;
        
        // Set default configuration for public configuration properties
        _dateDisplayTimeInterval = 60*15;
        _showsAddressBar = NO;
        _typingParticipantIDs = [NSMutableArray new];
        _sectionFooters = [NSHashTable weakObjectsHashTable];
        _firstAppearance = YES;
        _objectChanges = [NSMutableArray new];
    }
    return self;
}

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
    return nil;
}

#pragma mark - Lifecycle

- (void)loadView
{
    self.view = [LYRUIConversationView new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.accessibilityLabel = LYRUIConversationViewControllerAccessibilityLabel;
    // Collection View Setup
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.bounces = YES;
    self.collectionView.accessibilityIdentifier = LYRUIConversationCollectionViewAccessibilityIdentifier;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

    [self.collectionView registerClass:[LYRUIIncomingMessageCollectionViewCell class]
            forCellWithReuseIdentifier:LYRUIIncomingMessageCellIdentifier];

    [self.collectionView registerClass:[LYRUIOutgoingMessageCollectionViewCell class]
            forCellWithReuseIdentifier:LYRUIOutgoingMessageCellIdentifier];

    [self.collectionView registerClass:[LYRUIConversationCollectionViewMoreMessagesHeader class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:LYRUIMoreMessagesHeaderIdentifier];

    [self.collectionView registerClass:[LYRUIConversationCollectionViewHeader class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:LYRUIMessageCellHeaderIdentifier];

    [self.collectionView registerClass:[LYRUIConversationCollectionViewFooter class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:LYRUIMessageCellFooterIdentifier];

    [self.view addSubview:self.collectionView];
    
    // Set the accessoryView to be a Message Input Toolbar
    self.messageInputToolbar = [LYRUIMessageInputToolbar new];
    self.messageInputToolbar.inputToolBarDelegate = self;
    // An apparent system bug causes a view controller to not be deallocated if the view controller's own inputAccessoryView property is used.
    self.view.inputAccessoryView = self.messageInputToolbar;
    [self configureSendButtonEnablement];
    
    // Set the typing indicator label
    self.typingIndicatorView = [[LYRUITypingIndicatorView alloc] init];
    self.typingIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    // Make dragging on the typing indicator scroll the scroll view / keyboard.
    self.typingIndicatorView.userInteractionEnabled = NO;
    self.typingIndicatorView.alpha = 0.0;
    [self.view addSubview:self.typingIndicatorView];
    
    if (!self.conversation && self.showsAddressBar) {
        self.addressBarController = [[LYRUIAddressBarViewController alloc] init];
        self.addressBarController.delegate = self;
        [self addChildViewController:self.addressBarController];
        [self.view addSubview:self.addressBarController.view];
        [self.addressBarController didMoveToParentViewController:self];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    }

    [self updateAutoLayoutConstraints];
    [self updateCollectionViewInsets];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:self.messageInputToolbar.textInputView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageInputToolbarDidChangeHeight:) name:LYRUIMessageInputToolbarDidChangeHeightNotification object:self.messageInputToolbar];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTypingIndicator:) name:LYRConversationDidReceiveTypingIndicatorNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.conversation && !self.queryController) {
        [self fetchLayerMessages];
    }

    [self setConversationViewTitle];
    [self configureAvatarImageDisplay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (self.addressBarController && !self.addressBarController.isPermanent) {
        [self.addressBarController.addressBarView.addressBarTextView becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // Workaround for view's content flashing onscreen after pop animation concludes on iOS 8.
    BOOL isPopping = ![self.navigationController.viewControllers containsObject:self];
    if (isPopping) {
        [self.messageInputToolbar.textInputView resignFirstResponder];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (self.addressBarController) {
        UIEdgeInsets contentInset = self.collectionView.contentInset;
        UIEdgeInsets scrollIndicatorInsets = self.collectionView.scrollIndicatorInsets;
        CGRect frame = [self.view convertRect:self.addressBarController.addressBarView.frame fromView:self.addressBarController.addressBarView.superview];
        contentInset.top = CGRectGetMaxY(frame);
        scrollIndicatorInsets.top = contentInset.top;
        self.collectionView.contentInset = contentInset;
        self.collectionView.scrollIndicatorInsets = scrollIndicatorInsets;
    }

    // To get the toolbar to slide onscreen with the view controller's content, we have to make the view the first responder here. Even so, it will not animate on iOS 8 the first time.
    if (!self.presentedViewController && !self.view.inputAccessoryView.superview) {
        [self.view becomeFirstResponder];
    }

    if (self.isFirstAppearance) {
        self.firstAppearance = NO;
        [self scrollToBottomOfCollectionViewAnimated:NO];

        // This works around an issue where in some situations iOS 7.1 will crash with 'Auto Layout still required after sending -viewDidLayoutSubviews to the view controller.' apparently due to our usage of the collection view layout's content size when scrolling to the bottom in the above method call.
        [self.view layoutIfNeeded];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
}

- (void)updateViewConstraints
{
    CGFloat typingIndicatorBottomConstraintConstant = -self.collectionView.scrollIndicatorInsets.bottom;
    if (self.messageInputToolbar.superview) {
        CGRect toolbarFrame = [self.view convertRect:self.messageInputToolbar.frame fromView:self.messageInputToolbar.superview];
        CGFloat keyboardOnscreenHeight = CGRectGetHeight(self.view.frame) - CGRectGetMinY(toolbarFrame);
        if (-keyboardOnscreenHeight > typingIndicatorBottomConstraintConstant) {
            typingIndicatorBottomConstraintConstant = -keyboardOnscreenHeight;
        }
    }
    self.typingIndicatorViewBottomConstraint.constant = typingIndicatorBottomConstraintConstant;

    [super updateViewConstraints];
}

- (void)dealloc
{
    self.collectionView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleApplicationWillEnterForeground:(NSNotification *)notification
{
    if (self.conversation) {
        NSError *error;
        BOOL success = [self.conversation markAllMessagesAsRead:&error];
        if (!success) {
            NSLog(@"Failed to mark all messages as read with error: %@", error);
        }
    }
}

#pragma mark - Conversation Setup

- (void)fetchLayerMessages
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"conversation" operator:LYRPredicateOperatorIsEqualTo value:self.conversation];
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
    NSUInteger numberOfMessagesAvailable = [self.layerClient countForQuery:query error:nil];
    NSUInteger numberOfMessagesToDisplay = MIN(numberOfMessagesAvailable, 30);
    
    self.queryController = [self.layerClient queryControllerWithQuery:query];
    self.queryController.paginationWindow = -numberOfMessagesToDisplay;
    self.queryController.delegate = self;
    NSError *error = nil;
    BOOL success = [self.queryController execute:&error];
    if (!success) NSLog(@"LayerKit failed to execute query with error: %@", error);
    self.showingMoreMessagesIndicator = [self moreMessagesAvailable];
    [self.collectionView reloadData];
}

- (void)setConversation:(LYRConversation *)conversation
{
    if (!conversation && !_conversation) return;
    if ([conversation isEqual:_conversation]) return;

    _conversation = conversation;

    [self.typingParticipantIDs removeAllObjects];
    [self updateTypingIndicatorOverlay:NO];

    [self configureSendButtonEnablement];
    if (conversation) {
        [self fetchLayerMessages];
    } else {
        self.queryController.delegate = nil;
        self.queryController = nil;
        [self.collectionView reloadData];
    }
}

- (void)configureAvatarImageDisplay
{
    NSMutableSet *otherParticipantIDs = [self.conversation.participants mutableCopy];
    if (self.layerClient.authenticatedUserID) [otherParticipantIDs removeObject:self.layerClient.authenticatedUserID];
    self.shouldDisplayAvatarImage = otherParticipantIDs.count > 1;
}

- (void)setConversationViewTitle
{
    if (self.conversationTitle) {
        self.title = self.conversationTitle;
        return;
    }

    if (!self.conversation) {
        self.title = @"New Message";
        return;
    }

    NSMutableSet *otherParticipantIDs = [self.conversation.participants mutableCopy];
    if (self.layerClient.authenticatedUserID) [otherParticipantIDs removeObject:self.layerClient.authenticatedUserID];

    if (otherParticipantIDs.count == 0) {
        self.title = @"Personal";
    } else if (otherParticipantIDs.count == 1) {
        NSString *otherParticipantID = [otherParticipantIDs anyObject];
        id<LYRUIParticipant> participant = [self participantForIdentifier:otherParticipantID];
        if (participant) {
            self.title = participant.firstName;
        } else {
            self.title = @"Unknown";
        }
    } else {
        self.title = @"Group";
    }
}

#pragma mark - Conversation Title

- (void)setConversationTitle:(NSString *)conversationTitle
{
    _conversationTitle = conversationTitle;
    
    // Update UI if possible
    if (self.isViewLoaded) {
        [self setConversationViewTitle];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // When the keyboard is being dragged, we need to update the position of the typing indicator.
    [self.view setNeedsUpdateConstraints];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) return;
    [self configurePaginationWindow];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self configurePaginationWindow];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self configurePaginationWindow];
}

# pragma mark - UICollectionViewDataSource

/**
 
 LAYER - The `LYRUIConversationViewController` component uses one `LYRMessage` to represent each row.
 
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == LYRUIMoreMessagesSection) return 0;

    // Each message is represented by one cell no matter how many parts it has.
    return 1;
}

/**
 
 LAYER - The `LYRUIConversationViewController` component uses `LYRMessages` to represent sections.
 
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Messages correspond to sections
    NSInteger numberOfSections = [self.queryController numberOfObjectsInSection:0];
    numberOfSections += LYRUINumberOfSectionsBeforeFirstMessageSection;
    return numberOfSections;
}

/**
 
 LAYER - Configuring a subclass of `LYRUIMessageCollectionViewCell` to be displayed on screen. `LayerUIKit` supports both
 `LYRUIIncomingMessageCollectionViewCell` and `LYRUIOutgoingMessageCollectionViewCell`.
 
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self messageAtCollectionViewIndexPath:indexPath];
    NSString *reuseIdentifier;
    if ([self.dataSource respondsToSelector:@selector(conversationViewController:reuseIdentifierForMessage:)]) {
        reuseIdentifier = [self.dataSource conversationViewController:self reuseIdentifierForMessage:message];
    }
    if (!reuseIdentifier) {
        if ([self.layerClient.authenticatedUserID isEqualToString:message.sentByUserID]) {
            // If the message was sent by the currently authenticated user, it is outgoing
            reuseIdentifier = LYRUIOutgoingMessageCellIdentifier;
        } else {
            // If the message was sent by someone other than the currently authenticated user, it is incoming
            reuseIdentifier = LYRUIIncomingMessageCellIdentifier;
        }
    }
    UICollectionViewCell<LYRUIMessagePresenting> *cell =  [self.collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [self configureCell:cell forMessage:message indexPath:indexPath];
    return cell;
}

/**
 
 LAYER - Extracting the proper message part and analyzing its properties to determine the cell configuration.
 
 */
- (void)configureCell:(UICollectionViewCell<LYRUIMessagePresenting> *)cell forMessage:(LYRMessage *)message indexPath:(NSIndexPath *)indexPath
{
    [cell presentMessage:message];
    [cell shouldDisplayAvatarImage:self.shouldDisplayAvatarImage];

    if ([self shouldDisplayParticipantInfoAtIndexPath:indexPath]) {
        [cell updateWithParticipant:[self participantForIdentifier:message.sentByUserID]];
    } else {
        [cell updateWithParticipant:nil];
    }
    if ([self.dataSource respondsToSelector:@selector(conversationViewController:shouldUpdateRecipientStatusForMessage:)]) {
        if ([self.dataSource conversationViewController:self shouldUpdateRecipientStatusForMessage:message]) {
            [self updateRecipientStatusForMessage:message];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(conversationViewController:didSelectMessage:)]) {
        LYRMessage *message = [self messageAtCollectionViewIndexPath:indexPath];
        [self.delegate conversationViewController:self didSelectMessage:message];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = self.collectionView.bounds.size.width;
    CGFloat height = 0;
    if ([self.delegate respondsToSelector:@selector(conversationViewController:heightForMessage:withCellWidth:)]) {
        LYRMessage *message = [self messageAtCollectionViewIndexPath:indexPath];
        height = [self.delegate conversationViewController:self heightForMessage:message withCellWidth:width];
    }
    if (!height) {
        height = [self cellHeightForItemAtIndexPath:indexPath];
    }
    return CGSizeMake(width, height);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == LYRUIMoreMessagesSection) {
        LYRUIConversationCollectionViewMoreMessagesHeader *header = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:LYRUIMoreMessagesHeaderIdentifier forIndexPath:indexPath];
        return header;
    }

    if (kind == UICollectionElementKindSectionHeader) {
        LYRUIConversationCollectionViewHeader *header = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:LYRUIMessageCellHeaderIdentifier forIndexPath:indexPath];
        [self configureHeader:header atIndexPath:indexPath];
        return header;
    } else {
        LYRUIConversationCollectionViewFooter *footer = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:LYRUIMessageCellFooterIdentifier forIndexPath:indexPath];
        [self configureFooter:footer atIndexPath:indexPath];
        [self.sectionFooters addObject:footer];
        return footer;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == LYRUIMoreMessagesSection) {
        if (self.showingMoreMessagesIndicator) return CGSizeMake(0, 30);
        return CGSizeZero;
    }

    CGFloat height = 0;
    LYRMessage *message = [self messageAtCollectionViewSection:section];
    NSUInteger firstMessageSection = LYRUINumberOfSectionsBeforeFirstMessageSection;
    if (section > firstMessageSection) {
        // 1. If previous message was sent by a different user, add 10px
        LYRMessage *previousMessage = [self messageAtCollectionViewSection:section - 1];
        if (![message.sentByUserID isEqualToString:previousMessage.sentByUserID]) {
            height += 10;
        }
    }
    // 2. If date label is shown, add 30px
    if ([self shouldDisplayDateLabelForSection:section]) {
        height += 30;
    }
    // 3. If sender label is shown, add 30px
    if ([self shouldDisplaySenderLabelForSection:section]) {
        height += 30;
    }
    return CGSizeMake(CGRectGetWidth(collectionView.frame), height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == LYRUIMoreMessagesSection) return CGSizeZero;

    // If we display a read receipt...
    if ([self shouldDisplayReadReceiptForSection:section]) {
        return CGSizeMake(CGRectGetWidth(collectionView.frame), 28);
    }
    return CGSizeMake(CGRectGetWidth(collectionView.frame), 6);
}

#pragma mark - Recipient Status

- (void)updateRecipientStatusForMessage:(LYRMessage *)message
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) return;
    if (!message) return;
    NSNumber *recipientStatusNumber = [message.recipientStatusByUserID objectForKey:self.layerClient.authenticatedUserID];
    LYRRecipientStatus recipientStatus = [recipientStatusNumber integerValue];
    if (recipientStatus != LYRRecipientStatusRead) {
        NSError *error;
        BOOL success = [message markAsRead:&error];
        if (success) {
            NSLog(@"Message successfully marked as read");
        } else {
            NSLog(@"Failed to mark message as read with error %@", error);
        }
    }
}

#pragma mark - UI Configuration

- (BOOL)shouldDisplayDateLabelForSection:(NSUInteger)section
{
    // Always show date label for the first section
    NSUInteger firstMessageSection = LYRUINumberOfSectionsBeforeFirstMessageSection;
    if (section == firstMessageSection) return YES;
    LYRMessage *message = [self messageAtCollectionViewSection:section];
    if (section > firstMessageSection) {
        LYRMessage *previousMessage = [self messageAtCollectionViewSection:section - 1];
        NSTimeInterval interval = [message.receivedAt timeIntervalSinceDate:previousMessage.receivedAt];
        // If it has been 60min since last message, show date label
        if (interval > self.dateDisplayTimeInterval) {
            return YES;
        }
    }
    // Otherwise, don't show date label
    return NO;
}

- (BOOL)shouldDisplaySenderLabelForSection:(NSUInteger)section
{
    // 1. If the conversation only has 2 participants, don't show sender label
    if (self.conversation.participants.count <= 2) {
        return NO;
    }
    
    // 2. If the message is from the current user, don't show sender label
    LYRMessage *message = [self messageAtCollectionViewSection:section];
    if ([message.sentByUserID isEqualToString:self.layerClient.authenticatedUserID]) {
        return NO;
    }

    // 3. If the previous message was sent by the same user, don't show label
    NSUInteger firstMessageSection = LYRUINumberOfSectionsBeforeFirstMessageSection;
    if (section > firstMessageSection) {
        LYRMessage *previousMessage = [self messageAtCollectionViewSection:section - 1];
        if ([previousMessage.sentByUserID isEqualToString:message.sentByUserID]) {
            return NO;
        }
    }

    return YES;
}

- (BOOL)shouldDisplayReadReceiptForSection:(NSUInteger)section
{
    // Only show read receipt if last message was sent by currently authenticated user
    NSInteger lastQueryControllerRow = [self.queryController numberOfObjectsInSection:0] - 1;
    NSInteger lastSection = [self collectionViewSectionForQueryControllerRow:lastQueryControllerRow];
    if (section != lastSection) return NO;

    LYRMessage *message = [self messageAtCollectionViewSection:section];
    if ([message.sentByUserID isEqualToString:self.layerClient.authenticatedUserID]) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldDisplayParticipantInfoAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.shouldDisplayAvatarImage) return NO;
    LYRMessage *message = [self messageAtCollectionViewIndexPath:indexPath];
    if ([message.sentByUserID isEqualToString:self.layerClient.authenticatedUserID]) {
        return NO;
    }
    NSInteger lastQueryControllerRow = [self.queryController numberOfObjectsInSection:0] - 1;
    NSInteger lastSection = [self collectionViewSectionForQueryControllerRow:lastQueryControllerRow];
    if (indexPath.section < lastSection) {
        LYRMessage *nextMessage = [self messageAtCollectionViewSection:indexPath.section + 1];
        // If the next message is sent by the same user, no
        if ([nextMessage.sentByUserID isEqualToString:message.sentByUserID]) {
            return NO;
        }
    }
    return YES;
}

- (void)registerClass:(Class<LYRUIMessagePresenting>)cellClass forMessageCellWithReuseIdentifier:(NSString *)reuseIdentifier
{
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:reuseIdentifier];
}

- (UICollectionViewCell<LYRUIMessagePresenting> *)collectionViewCellForMessage:(LYRMessage *)message
{
    NSIndexPath *indexPath = [self.queryController indexPathForObject:message];
    if (indexPath) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[self collectionViewIndexPathForQueryControllerIndexPath:indexPath]];
        if (cell) return (UICollectionViewCell<LYRUIMessagePresenting> *)cell;
    }
    return nil;
}

- (CGFloat)cellHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self messageAtCollectionViewIndexPath:indexPath];
    LYRMessagePart *part = message.parts.firstObject;
    // Guarding against external content in old SDKs
    if (!part.data.length) {
        return 48;
    }
    CGFloat height;
    if ([part.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
        NSString *text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        UIFont *font = [self messageCellFontForMessage:message];
        CGSize size = LYRUITextPlainSize(text, font);
        height = size.height + LYRUIMessageBubbleLabelVerticalPadding * 2;
    } else if ([part.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [part.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
        UIImage *image = [UIImage imageWithData:part.data];
        CGSize size = LYRUIImageSize(image);
        height = size.height;
    } else if ([part.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
        height = LYRUIMessageBubbleMapHeight;
    } else {
        height = 10;
    }
    height = ceil(height);
    return height;
}

- (UIFont *)messageCellFontForMessage:(LYRMessage *)message
{
    // The font is customizable via UIAppearance and the system doesn't set the custom value until a view is added to the hierarchy. So we create dummy cells and add them to the hierarchy temporarily. We only add them once (not on every use) assuming that the font won't be changed later.
    LYRUIMessageCollectionViewCell<LYRUIMessagePresenting> *cell;
    BOOL firstUse = NO;
    if ([self.layerClient.authenticatedUserID isEqualToString:message.sentByUserID]) {
        if (!self.sizingOutgoingMessageCell) {
            self.sizingOutgoingMessageCell = [LYRUIOutgoingMessageCollectionViewCell new];
            firstUse = YES;
        }
        cell = self.sizingOutgoingMessageCell;
    } else {
        if (!self.sizingIncomingMessageCell) {
            self.sizingIncomingMessageCell = [LYRUIIncomingMessageCollectionViewCell new];
            firstUse = YES;
        }
        cell = self.sizingIncomingMessageCell;
    }
    if (firstUse) {
        [self.view addSubview:cell];
        [cell removeFromSuperview];
    }
    return cell.messageTextFont;
}

#pragma mark - Notification Handlers

- (void)messageInputToolbarDidChangeHeight:(NSNotification *)notification
{
    CGPoint existingOffset = self.collectionView.contentOffset;
    CGPoint bottomOffset = [self bottomOffset];
    CGFloat distanceToBottom = bottomOffset.y - existingOffset.y;
    BOOL shouldScrollToBottom = distanceToBottom <= 50;

    CGRect toolbarFrame = [self.view convertRect:self.messageInputToolbar.frame fromView:self.messageInputToolbar.superview];
    CGFloat keyboardOnscreenHeight = CGRectGetHeight(self.view.frame) - CGRectGetMinY(toolbarFrame);
    if (keyboardOnscreenHeight == self.keyboardHeight) return;
    self.keyboardHeight = keyboardOnscreenHeight;
    [self updateCollectionViewInsets];
    self.typingIndicatorViewBottomConstraint.constant = -self.collectionView.scrollIndicatorInsets.bottom;

    if (shouldScrollToBottom) {
        self.collectionView.contentOffset = existingOffset;
        [self scrollToBottomOfCollectionViewAnimated:YES];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view convertRect:keyboardFrame fromView:nil];
    keyboardFrame = CGRectIntersection(self.view.bounds, keyboardFrame);
    self.keyboardHeight = CGRectGetHeight(keyboardFrame);
    [self.view layoutIfNeeded];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self updateCollectionViewInsets];
    self.typingIndicatorViewBottomConstraint.constant = -self.collectionView.scrollIndicatorInsets.bottom;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    self.keyboardHeight = 0;
    [self updateCollectionViewInsets];
    [self.view setNeedsUpdateConstraints];
}

- (void)textViewTextDidBeginEditing:(NSNotification *)notification
{
    [self scrollToBottomOfCollectionViewAnimated:YES];
}

- (void)didReceiveTypingIndicator:(NSNotification *)notification
{
    if (!self.conversation) return;
    if (!notification.object) return;
    if (![notification.object isEqual:self.conversation]) return;

    NSString *participantID = notification.userInfo[LYRTypingIndicatorParticipantUserInfoKey];
    NSNumber *statusNumber = notification.userInfo[LYRTypingIndicatorValueUserInfoKey];
    LYRTypingIndicator status = statusNumber.unsignedIntegerValue;
    if (status == LYRTypingDidBegin) {
        [self.typingParticipantIDs addObject:participantID];
    } else {
        [self.typingParticipantIDs removeObject:participantID];
    }
    [self updateTypingIndicatorOverlay:YES];
}

#pragma mark - Typing Indicator

- (void)updateTypingIndicatorOverlay:(BOOL)animated
{
    NSMutableArray *knownParticipantsTyping = [NSMutableArray array];
    __block NSUInteger unknownParticipantsTypingCount = 0;
    [self.typingParticipantIDs enumerateObjectsUsingBlock:^(NSString *participantID, NSUInteger idx, BOOL *stop) {
        id<LYRUIParticipant> participant = [self participantForIdentifier:participantID];
        if (!participant) {
            unknownParticipantsTypingCount++;
            return;
        }
        [knownParticipantsTyping addObject:participant];
    }];

    BOOL visible = knownParticipantsTyping.count + unknownParticipantsTypingCount > 0;
    if (visible) {
        NSString *text = [self typingIndicatorTextWithKnownParticipants:knownParticipantsTyping unknownParticipantsCount:unknownParticipantsTypingCount];
        self.typingIndicatorView.label.text = text;
    }

    NSTimeInterval duration;
    if (!animated) {
        duration = 0;
    } else if (visible) {
        duration = 0.3;
    } else {
        duration = 0.1;
    }

    [UIView animateWithDuration:duration animations:^{
        self.typingIndicatorView.alpha = visible ? 1.0 : 0.0;
    }];
}

- (NSString *)typingIndicatorTextWithKnownParticipants:(NSArray *)knownParticipants unknownParticipantsCount:(NSUInteger)unknownParticipantsCount
{
    NSUInteger participantsCount = knownParticipants.count + unknownParticipantsCount;
    if (participantsCount == 0) return nil;

    NSString *unknownParticipantsSummary;
    if (unknownParticipantsCount == 1) {
        unknownParticipantsSummary = @"Unknown";
    } else if (unknownParticipantsCount > 1) {
        unknownParticipantsSummary = [NSString stringWithFormat:@"%ld unknowns", (unsigned long)unknownParticipantsCount];
    }

    NSMutableArray *fullNameComponents = [[knownParticipants valueForKey:@"fullName"] mutableCopy];
    if (unknownParticipantsSummary) {
        [fullNameComponents addObject:unknownParticipantsSummary];
    }
    NSString *fullNamesText = [self typingIndicatorTextWithParticipantStrings:fullNameComponents participantsCount:participantsCount];
    if ([self typingIndicatorLabelHasSpaceForText:fullNamesText]) return fullNamesText;

    NSArray *firstNames = [knownParticipants valueForKey:@"firstName"];
    NSMutableArray *firstNameComponents = [firstNames mutableCopy];
    if (unknownParticipantsSummary) {
        [firstNameComponents addObject:unknownParticipantsSummary];
    }
    NSString *firstNamesText = [self typingIndicatorTextWithParticipantStrings:firstNameComponents participantsCount:participantsCount];
    if ([self typingIndicatorLabelHasSpaceForText:firstNamesText]) return firstNamesText;

    NSMutableArray *strings = [NSMutableArray new];
    for (NSInteger displayedFirstNamesCount = knownParticipants.count; displayedFirstNamesCount >= 0; displayedFirstNamesCount--) {
        [strings removeAllObjects];

        NSRange displayedRange = NSMakeRange(0, displayedFirstNamesCount);
        NSArray *displayedFirstNames = [firstNames subarrayWithRange:displayedRange];
        [strings addObjectsFromArray:displayedFirstNames];

        NSUInteger undisplayedCount = participantsCount - displayedRange.length;
        NSMutableString *textForUndisplayedParticipants = [NSMutableString new];;
        [textForUndisplayedParticipants appendFormat:@"%ld", (unsigned long)undisplayedCount];
        if (displayedFirstNamesCount > 0 && undisplayedCount == 1) {
            [textForUndisplayedParticipants appendString:@" other"];
        } else if (displayedFirstNamesCount > 0) {
            [textForUndisplayedParticipants appendString:@" others"];
        }
        [strings addObject:textForUndisplayedParticipants];

        NSString *proposedSummary = [self typingIndicatorTextWithParticipantStrings:strings participantsCount:participantsCount];
        if ([self typingIndicatorLabelHasSpaceForText:proposedSummary]) {
            return proposedSummary;
        }
    }

    return nil;
}

- (NSString *)typingIndicatorTextWithParticipantStrings:(NSArray *)participantStrings participantsCount:(NSUInteger)participantsCount
{
    NSMutableString *text = [NSMutableString new];
    NSUInteger lastIndex = participantStrings.count - 1;
    [participantStrings enumerateObjectsUsingBlock:^(NSString *participantString, NSUInteger index, BOOL *stop) {
        if (index == lastIndex && participantStrings.count == 2) {
            [text appendString:@" and "];
        } else if (index == lastIndex && participantStrings.count > 2) {
            [text appendString:@", and "];
        } else if (index > 0) {
            [text appendString:@", "];
        }
        [text appendString:participantString];
    }];
    if (participantsCount == 1) {
        [text appendString:@" is typing…"];
    } else {
        [text appendString:@" are typing…"];
    }
    return text;
}

- (BOOL)typingIndicatorLabelHasSpaceForText:(NSString *)text
{
    UILabel *label = self.typingIndicatorView.label;
    CGSize fittedSize = [text sizeWithAttributes:@{NSFontAttributeName: label.font}];
    return fittedSize.width <= CGRectGetWidth(label.frame);
}

#pragma mark - LYRUIMessageInputToolbarDelegate

- (void)messageInputToolbar:(LYRUIMessageInputToolbar *)messageInputToolbar didTapLeftAccessoryButton:(UIButton *)leftAccessoryButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Take Photo", @"Last Photo Taken", @"Photo Library", nil];
    [actionSheet showInView:self.view];
}

- (void)messageInputToolbar:(LYRUIMessageInputToolbar *)messageInputToolbar didTapRightAccessoryButton:(UIButton *)rightAccessoryButton
{
    if (!self.conversation) return;
    if (!messageInputToolbar.messageParts.count) return;
    
    NSOrderedSet *messages = [NSOrderedSet new];
    if ([self.delegate respondsToSelector:@selector(conversationViewController:messagesForContentParts:)]) {
        messages = [self.delegate conversationViewController:self messagesForContentParts:messageInputToolbar.messageParts];
    } else  {
        messages = [self messagesForMessageParts:messageInputToolbar.messageParts];
    }
    
    for (LYRMessage *message in messages) {
        [self sendMessage:message];
    }
    
    if (self.addressBarController) [self.addressBarController setPermanent];
}

- (void)messageInputToolbarDidType:(LYRUIMessageInputToolbar *)messageInputToolbar
{
    if (!self.conversation) return;
    [self.conversation sendTypingIndicator:LYRTypingDidBegin];
}

- (void)messageInputToolbarDidEndTyping:(LYRUIMessageInputToolbar *)messageInputToolbar
{
    if (!self.conversation) return;
    [self.conversation sendTypingIndicator:LYRTypingDidFinish];
}

#pragma mark - Message Sending

- (NSOrderedSet *)messagesForMessageParts:(NSArray *)messageParts
{
    NSMutableOrderedSet *messages = [NSMutableOrderedSet new];
    for (id part in messageParts){
        LYRMessagePart *messagePart;
        if ([part isKindOfClass:[NSString class]]) {
            messagePart = LYRUIMessagePartWithText(part);
        } else if ([part isKindOfClass:[UIImage class]]) {
            messagePart = LYRUIMessagePartWithJPEGImage(part);
        } else if ([part isKindOfClass:[CLLocation class]]) {
            messagePart = LYRUIMessagePartWithLocation(part);
        }
        [messages addObject:[self messageForMessagePart:messagePart]];
    }
    return messages;
}

- (LYRMessage *)messageForMessagePart:(LYRMessagePart *)messagePart
{
    NSString *senderName = [[self participantForIdentifier:self.layerClient.authenticatedUserID] fullName];
    NSDictionary *pushOptions = @{LYRMessageOptionsPushNotificationAlertKey: LYRUIPushTextWithPartAndSenderName(messagePart, senderName),
                                  LYRMessageOptionsPushNotificationSoundNameKey: @"default"};
    NSError *error;
    LYRMessage *message = [self.layerClient newMessageWithParts:@[messagePart] options:pushOptions error:&error];
    if (error) {
        return nil;
    }
    return message;
}

- (void)sendMessage:(LYRMessage *)message
{
    NSError *error;
    BOOL success = [self.conversation sendMessage:message error:&error];
    if (success) {
        if ([self.delegate respondsToSelector:@selector(conversationViewController:didSendMessage:)]) {
            [self.delegate conversationViewController:self didSendMessage:message];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(conversationViewController:didFailSendingMessage:error:)]) {
            [self.delegate conversationViewController:self didFailSendingMessage:message error:error];
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
            
        case 1:
           [self captureLastPhotoTaken];
            break;
          
        case 2:
            [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
        default:
            break;
    }
}

#pragma mark - Image Picking

- (void)displayImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType;
{
    [self.messageInputToolbar.textInputView resignFirstResponder];
    BOOL pickerSourceTypeAvailable = [UIImagePickerController isSourceTypeAvailable:sourceType];
    if (pickerSourceTypeAvailable) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = sourceType;
        [self.navigationController presentViewController:picker animated:YES completion:nil];
    }
}

- (void)captureLastPhotoTaken
{
    LYRUILastPhotoTaken(^(UIImage *image, NSError *error) {
        if (error) {
            NSLog(@"Failed to capture last photo with error: %@", [error localizedDescription]);
        } else {
            [self.messageInputToolbar insertImage:image];
        }
    });
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        UIImage *selectedImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
        [self.messageInputToolbar insertImage:selectedImage];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.view becomeFirstResponder];

    // Workaround for collection view not displayed on iOS 7.1.
    [self.collectionView setNeedsLayout];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.view becomeFirstResponder];

    // Workaround for collection view not displayed on iOS 7.1.
    [self.collectionView setNeedsLayout];
}

#pragma mark - Collection View Content Inset

- (void)updateCollectionViewInsets
{
    [self.messageInputToolbar layoutIfNeeded];
    UIEdgeInsets insets = self.collectionView.contentInset;
    CGFloat keyboardHeight = MAX(self.keyboardHeight, CGRectGetHeight(self.messageInputToolbar.frame));
    insets.bottom = keyboardHeight;
    self.collectionView.scrollIndicatorInsets = insets;
    insets.bottom += LYRUITypingIndicatorHeight;
    self.collectionView.contentInset = insets;
}

- (CGPoint)bottomOffset
{
    CGFloat contentSizeHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
    CGFloat collectionViewFrameHeight = self.collectionView.frame.size.height;
    CGFloat collectionViewBottomInset = self.collectionView.contentInset.bottom;
    CGFloat collectionViewTopInset = self.collectionView.contentInset.top;
    CGPoint offset = CGPointMake(0, MAX(-collectionViewTopInset, contentSizeHeight - (collectionViewFrameHeight - collectionViewBottomInset)));
    return offset;
}

#pragma mark - Device Rotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - LYRQueryControllerDelegate

- (void)queryController:(LYRQueryController *)controller
        didChangeObject:(id)object
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(LYRQueryControllerChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.expandingPaginationWindow) return;
    NSInteger currentIndex = indexPath ? [self collectionViewSectionForQueryControllerRow:indexPath.row] : NSNotFound;
    NSInteger newIndex = newIndexPath ? [self collectionViewSectionForQueryControllerRow:newIndexPath.row] : NSNotFound;
    [self.objectChanges addObject:[LYRUIDataSourceChange changeObjectWithType:type newIndex:newIndex currentIndex:currentIndex]];
}

- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController
{
    if (self.expandingPaginationWindow) {
        self.showingMoreMessagesIndicator = [self moreMessagesAvailable];
        [self reloadCollectionViewAdjustingForContentHeightChange];
        return;
    }

    if (self.objectChanges.count == 0) {
        [self configurePaginationWindow];
        [self configureMoreMessagesIndicatorVisibility];
        return;
    }

    CGPoint bottomOffset = [self bottomOffset];
    CGFloat distanceToBottom = bottomOffset.y - self.collectionView.contentOffset.y;
    BOOL shouldScrollToBottom = distanceToBottom <= 50 && !self.collectionView.isTracking && !self.collectionView.isDragging && !self.collectionView.isDecelerating;

    [self.collectionView performBatchUpdates:^{
        for (LYRUIDataSourceChange *change in self.objectChanges) {
            switch (change.type) {
                case LYRQueryControllerChangeTypeInsert:
                    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:change.newIndex]];
                    break;
                    
                case LYRQueryControllerChangeTypeMove:
                    [self.collectionView moveSection:change.currentIndex toSection:change.newIndex];
                    break;
                    
                case LYRQueryControllerChangeTypeDelete:
                    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:change.currentIndex]];
                    break;
                    
                case LYRQueryControllerChangeTypeUpdate:
                    // If we call reloadSections: for a section that is already being animated due to another move (e.g. moving section 17 to 16 causes section 16 to be moved/animated to 17 and then we also reload section 16), UICollectionView will throw an exception. But since all onscreen sections will be reconfigured (see below) we don't need to reload the sections here anyway.
                    break;
                    
                default:
                    break;
            }
        }
        [self.objectChanges removeAllObjects];
    } completion:nil];

     [self configureCollectionViewElements];

    if (shouldScrollToBottom)  {
        [self scrollToBottomOfCollectionViewAnimated:YES];
    } else {
        [self configurePaginationWindow];
        [self configureMoreMessagesIndicatorVisibility];
    }
}

- (void)configureCollectionViewElements
{
    // Since each section's content depends on other messages, we need to update each visible section even when a section's corresponding message has not changed. This also solves the issue with LYRQueryControllerChangeTypeUpdate (see above).
    for (UICollectionViewCell<LYRUIMessagePresenting> *cell in [self.collectionView visibleCells]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        LYRMessage *message = [self messageAtCollectionViewIndexPath:indexPath];
        [self configureCell:cell forMessage:message indexPath:indexPath];
    }
    for (LYRUIConversationCollectionViewFooter *footer in self.sectionFooters) {
        NSIndexPath *queryControllerIndexPath = [self.queryController indexPathForObject:footer.message];
        if (!queryControllerIndexPath) continue;
        NSIndexPath *collectionViewIndexPath = [self collectionViewIndexPathForQueryControllerIndexPath:queryControllerIndexPath];
        [self configureFooter:footer atIndexPath:collectionViewIndexPath];
    }
}

#pragma mark - LYRUIAddressBarViewControllerDelegate

- (void)addressBarViewControllerDidBeginSearching:(LYRUIAddressBarViewController *)addressBarViewController
{
    self.messageInputToolbar.hidden = YES;
}

- (void)addressBarViewControllerDidEndSearching:(LYRUIAddressBarViewController *)addressBarViewController
{
    self.messageInputToolbar.hidden = NO;
}

- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController didSelectParticipant:(id<LYRUIParticipant>)participant
{
    [self configureConversationWithAddressBar:addressBarViewController];
}

- (void)addressBarViewController:(LYRUIAddressBarViewController *)addressBarViewController didRemoveParticipant:(id<LYRUIParticipant>)participant
{
    [self configureConversationWithAddressBar:addressBarViewController];
}

#pragma mark - Send Button Enablement

- (void)configureSendButtonEnablement
{
    self.messageInputToolbar.canEnableSendButton = [self shouldAllowSendButtonEnablement];
}

- (BOOL)shouldAllowSendButtonEnablement
{
    if (!self.conversation) return NO;
    return YES;
}

#pragma mark - Auto Layout Configuration

- (void)updateAutoLayoutConstraints
{
    //********** Collection View Constraints **********//
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
    
    //********** Typing Indicator View Constraints **********//
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.typingIndicatorView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.typingIndicatorView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.typingIndicatorView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:LYRUITypingIndicatorHeight]];
   
    self.typingIndicatorViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.typingIndicatorView
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.view
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1.0
                                                                             constant:0];
    [self.view addConstraint:self.typingIndicatorViewBottomConstraint];
}

#pragma mark - Pagination

- (void)configurePaginationWindow
{
    if (!self.queryController) return;
    if (CGRectEqualToRect(self.collectionView.frame, CGRectZero)) return;
    if (self.collectionView.isDragging) return;
    if (self.collectionView.isDecelerating) return;

    CGFloat topOffset = -self.collectionView.contentInset.top;
    CGFloat distanceFromTop = self.collectionView.contentOffset.y - topOffset;
    CGFloat minimumDistanceFromTopToTriggerLoadingMore = 200;
    BOOL nearTop = distanceFromTop <= minimumDistanceFromTopToTriggerLoadingMore;
    if (!nearTop) return;

    BOOL moreMessagesAvailable = self.queryController.totalNumberOfObjects > ABS(self.queryController.paginationWindow);
    if (!moreMessagesAvailable) return;

    self.expandingPaginationWindow = YES;
    NSUInteger numberOfMessagesToDisplay = MIN(-self.queryController.paginationWindow + 30, self.queryController.totalNumberOfObjects);
    self.queryController.paginationWindow = -numberOfMessagesToDisplay;
    self.expandingPaginationWindow = NO;
}

- (void)configureMoreMessagesIndicatorVisibility
{
    if (self.collectionView.isDragging) return;
    if (self.collectionView.isDecelerating) return;
    BOOL moreMessagesAvailable = [self moreMessagesAvailable];
    if (moreMessagesAvailable == self.showingMoreMessagesIndicator) return;
    self.showingMoreMessagesIndicator = [self moreMessagesAvailable];
    [self reloadCollectionViewAdjustingForContentHeightChange];
}

- (BOOL)moreMessagesAvailable
{
    return self.queryController.totalNumberOfObjects > ABS(self.queryController.count);
}

- (void)reloadCollectionViewAdjustingForContentHeightChange
{
    CGFloat priorContentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height;
    [self.collectionView reloadData];
    CGFloat contentHeightDifference = self.collectionView.collectionViewLayout.collectionViewContentSize.height - priorContentHeight;
    CGFloat adjustment = contentHeightDifference;
    self.collectionView.contentOffset = CGPointMake(0, self.collectionView.contentOffset.y + adjustment);
    [self.collectionView flashScrollIndicators];
}

#pragma mark - Helpers

- (void)scrollToBottomOfCollectionViewAnimated:(BOOL)animated
{
    [self.collectionView setContentOffset:[self bottomOffset] animated:animated];
}

- (id<LYRUIParticipant>)participantForIdentifier:(NSString *)identifier
{
    if ([self.dataSource respondsToSelector:@selector(conversationViewController:participantForIdentifier:)]) {
        return [self.dataSource conversationViewController:self participantForIdentifier:identifier];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"LYRUIConversationViewControllerDelegate must return a participant for an identifier" userInfo:nil];
    }
}

- (void)configureConversationWithAddressBar:(LYRUIAddressBarViewController *)addressBarViewController
{
    NSSet *participants = addressBarViewController.selectedParticipants;
    LYRConversation *conversation = [self conversationWithParticipants:participants];
    if (conversation == self.conversation) return;
    self.conversation = conversation;
    [self setConversationViewTitle];
    [self configureAvatarImageDisplay];
    [self scrollToBottomOfCollectionViewAnimated:NO];
}

- (LYRConversation *)conversationWithParticipants:(NSSet *)participants
{
    if (participants.count == 0) return nil;

    LYRConversation *conversation;
    if ([self.dataSource respondsToSelector:@selector(conversationViewController:conversationWithParticipants:)]) {
        conversation = [self.dataSource conversationViewController:self conversationWithParticipants:participants];
        if (conversation) return conversation;
    }

    NSSet *participantIdentifiers = [participants valueForKey:@"participantIdentifier"];
    conversation = [self existingConversationWithParticipantIdentifiers:participantIdentifiers];
    if (conversation) return conversation;

    BOOL deliveryReceiptsEnabled = participants.count <= 5;
    NSDictionary *options = @{LYRConversationOptionsDeliveryReceiptsEnabledKey: @(deliveryReceiptsEnabled)};
    conversation = [self.layerClient newConversationWithParticipants:participantIdentifiers options:options error:nil];
    return conversation;
}

- (LYRConversation *)existingConversationWithParticipantIdentifiers:(NSSet *)participantIdentifiers
{
    NSMutableSet *set = [participantIdentifiers mutableCopy];
    [set addObject:self.layerClient.authenticatedUserID];
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" operator:LYRPredicateOperatorIsEqualTo value:set];
    query.limit = 1;
    return [self.layerClient executeQuery:query error:nil].lastObject;
}

- (void)configureHeader:(LYRUIConversationCollectionViewHeader *)header atIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self messageAtCollectionViewIndexPath:indexPath];
    
    if ([self shouldDisplayDateLabelForSection:indexPath.section]) {
        NSAttributedString *dateString = [self attributedStringForMessageDate:message];
        [header updateWithAttributedStringForDate:dateString];
    }
    if ([self shouldDisplaySenderLabelForSection:indexPath.section]) {
        NSAttributedString *participantString = [self attributedStringForMessageSender:message];
        [header updateWithAttributedStringForParticipantName:participantString];
    }
}

- (void)configureFooter:(LYRUIConversationCollectionViewFooter *)footer atIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self messageAtCollectionViewIndexPath:indexPath];
    footer.message = message;
    if ([self shouldDisplayReadReceiptForSection:indexPath.section]) {
        if ([self.dataSource respondsToSelector:@selector(conversationViewController:attributedStringForDisplayOfRecipientStatus:)]) {
            NSAttributedString *recipientStatusString = [self.dataSource conversationViewController:self attributedStringForDisplayOfRecipientStatus:message.recipientStatusByUserID];
            NSAssert([recipientStatusString isKindOfClass:[NSAttributedString class]], @"Recipient String must be an attributed string");
            [footer updateWithAttributedStringForRecipientStatus:recipientStatusString];
        } else {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"LYRUIConversationViewControllerDataSource must return an attributed string for recipient status" userInfo:nil];
        }
    } else {
        [footer updateWithAttributedStringForRecipientStatus:nil];
    }
}

- (NSAttributedString *)attributedStringForMessageDate:(LYRMessage *)message
{
    NSAttributedString *dateString;
    if ([self.dataSource respondsToSelector:@selector(conversationViewController:attributedStringForDisplayOfDate:)]) {
        NSDate *date = message.sentAt ?: [NSDate date];
        dateString = [self.dataSource conversationViewController:self attributedStringForDisplayOfDate:date];
        NSAssert([dateString isKindOfClass:[NSAttributedString class]], @"Date string must be an attributed string");
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"LYRUIConversationViewControllerDataSource must return an attributed string for Date" userInfo:nil];
    }
    return dateString;
}

- (NSAttributedString *)attributedStringForMessageSender:(LYRMessage *)message
{
    NSAttributedString *participantString;
    id<LYRUIParticipant> participant = [self participantForIdentifier:message.sentByUserID];
    NSString *participantName = participant.fullName ?: @"Unknown User";
    participantString = [[NSAttributedString alloc] initWithString:participantName];
    return participantString;
}

#pragma mark - Query Controller

- (NSIndexPath *)queryControllerIndexPathForCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath
{
    return [self queryControllerIndexPathForCollectionViewSection:collectionViewIndexPath.section];
}

- (NSIndexPath *)queryControllerIndexPathForCollectionViewSection:(NSInteger)collectionViewSection
{
    NSInteger queryControllerRow = [self queryControllerRowForCollectionViewSection:collectionViewSection];
    NSIndexPath *queryControllerIndexPath = [NSIndexPath indexPathForRow:queryControllerRow inSection:0];
    return queryControllerIndexPath;
}

- (NSInteger)queryControllerRowForCollectionViewSection:(NSInteger)collectionViewSection
{
    return collectionViewSection - LYRUINumberOfSectionsBeforeFirstMessageSection;
}

- (NSIndexPath *)collectionViewIndexPathForQueryControllerIndexPath:(NSIndexPath *)queryControllerIndexPath
{
    return [self collectionViewIndexPathForQueryControllerRow:queryControllerIndexPath.row];
}

- (NSIndexPath *)collectionViewIndexPathForQueryControllerRow:(NSInteger)queryControllerRow
{
    NSInteger collectionViewSection = [self collectionViewSectionForQueryControllerRow:queryControllerRow];
    NSIndexPath *collectionViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:collectionViewSection];
    return collectionViewIndexPath;
}

- (NSInteger)collectionViewSectionForQueryControllerRow:(NSInteger)queryControllerRow
{
    return queryControllerRow + LYRUINumberOfSectionsBeforeFirstMessageSection;
}

- (LYRMessage *)messageAtCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath
{
    NSIndexPath *queryControllerIndexPath = [self queryControllerIndexPathForCollectionViewIndexPath:collectionViewIndexPath];
    LYRMessage *message = [self.queryController objectAtIndexPath:queryControllerIndexPath];
    return message;
}

- (LYRMessage *)messageAtCollectionViewSection:(NSInteger)collectionViewSection
{
    NSIndexPath *queryControllerIndexPath = [self queryControllerIndexPathForCollectionViewSection:collectionViewSection];
    LYRMessage *message = [self.queryController objectAtIndexPath:queryControllerIndexPath];
    return message;
}

@end
