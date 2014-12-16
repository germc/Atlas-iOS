//
//  LYRUIConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "LYRUIConversationViewController.h"
#import "LYRUIOutgoingMessageCollectionViewCell.h"
#import "LYRUIIncomingMessageCollectionViewCell.h"
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

@property (nonatomic) LYRUIConversationView *view;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) UILabel *typingIndicatorLabel;
@property (nonatomic) LYRUITypingIndicatorView *typingIndicatorView;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) BOOL shouldDisplayAvatarImage;
@property (nonatomic) NSLayoutConstraint *typingIndicatorViewBottomConstraint;
@property (nonatomic) NSMutableArray *typingParticipantIDs;
@property (nonatomic) LYRQueryController *queryController;
@property (nonatomic) NSMutableArray *objectChanges;
@property (nonatomic) NSHashTable *sectionFooters;
@property (nonatomic, getter=isFirstAppearance) BOOL firstAppearance;

@end

@implementation LYRUIConversationViewController

static NSString *const LYRUIIncomingMessageCellIdentifier = @"LYRUIIncomingMessageCellIdentifier";
static NSString *const LYRUIOutgoingMessageCellIdentifier = @"LYRUIOutgoingMessageCellIdentifier";
static NSString *const LYRUIMessageCellHeaderIdentifier = @"LYRUIMessageCellHeaderIdentifier";
static NSString *const LYRUIMessageCellFooterIdentifier = @"LYUIMessageCellFooterIdentifier";

static CGFloat const LYRUITypingIndicatorHeight = 20;

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

#pragma mark - VC Lifecycle Methods

- (void)loadView
{
    self.view = [LYRUIConversationView new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.accessibilityLabel = @"Conversation";
    
    // Collection View Setup
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.bounces = YES;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.collectionView.accessibilityLabel = @"Conversation Collection View";

    [self.collectionView registerClass:[LYRUIIncomingMessageCollectionViewCell class]
            forCellWithReuseIdentifier:LYRUIIncomingMessageCellIdentifier];

    [self.collectionView registerClass:[LYRUIOutgoingMessageCollectionViewCell class]
            forCellWithReuseIdentifier:LYRUIOutgoingMessageCellIdentifier];

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTypingIndicator:) name:LYRConversationDidReceiveTypingIndicatorNotification object:self.conversation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.conversation) {
        [self fetchLayerMessages];
    }

    [self setConversationViewTitle];
    [self configureAvatarImageDisplay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.addressBarController.addressBarView.addressBarTextView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.queryController = nil;
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

#pragma mark - Conversation Setup Methods

- (void)fetchLayerMessages
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"conversation" operator:LYRPredicateOperatorIsEqualTo value:self.conversation];
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
    
    self.queryController = [self.layerClient queryControllerWithQuery:query];
    self.queryController.delegate = self;
    NSError *error = nil;
    BOOL success = [self.queryController execute:&error];
    if (!success) NSLog(@"LayerKit failed to execute query with error: %@", error);
    [self.collectionView reloadData];
}

- (void)setConversation:(LYRConversation *)conversation
{
    _conversation = conversation;
    [self configureSendButtonEnablement];
    if (conversation) {
        [self fetchLayerMessages];
    } else {
        self.queryController = nil;
        [self.collectionView reloadData];
    }
}

- (void)configureAvatarImageDisplay
{
    NSMutableSet *otherParticipantIDs = [self.conversation.participants mutableCopy];
    [otherParticipantIDs removeObject:self.layerClient.authenticatedUserID];
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
    [otherParticipantIDs removeObject:self.layerClient.authenticatedUserID];

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

#pragma mark - Conversation title

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

# pragma mark - Collection View Data Source

/**
 
 LAYER - The `LYRUIConversationViewController` component uses one `LYRMessage` to represent each row.
 
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
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
    } else if ([self.layerClient.authenticatedUserID isEqualToString:message.sentByUserID]) {
        // If the message was sent by the currently authenticated user, it is outgoing
        reuseIdentifier = LYRUIOutgoingMessageCellIdentifier;
    } else {
        // If the message was sent by someone other than the currently authenticated user, it is incoming
        reuseIdentifier = LYRUIIncomingMessageCellIdentifier;
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
    [cell updateWithMessageSentState:message.isSent];
    if ([cell isKindOfClass:[LYRUIMessageCollectionViewCell class]]) {
        CGSize size = [self sizeForItemAtIndexPath:indexPath];
        [(LYRUIMessageCollectionViewCell *)cell updateWithBubbleViewWidth:size.width];
    }
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

#pragma mark - UICollectionViewDelegateFlowLayout Methods

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
    CGFloat height;
    if ([self.delegate respondsToSelector:@selector(conversationViewController:heightForMessage:withCellWidth:)]) {
        LYRMessage *message = [self messageAtCollectionViewIndexPath:indexPath];
        height = [self.delegate conversationViewController:self heightForMessage:message withCellWidth:width];
    } else {
        height = [self sizeForItemAtIndexPath:indexPath].height;
    }
    return CGSizeMake(width, height);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self messageAtCollectionViewIndexPath:indexPath];
    if (kind == UICollectionElementKindSectionHeader) {
        LYRUIConversationCollectionViewHeader *header = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:LYRUIMessageCellHeaderIdentifier forIndexPath:indexPath];
        // Should we display a sender label?
        if ([self shouldDisplaySenderLabelForSection:indexPath.section]) {
            id<LYRUIParticipant> participant = [self participantForIdentifier:message.sentByUserID];
            if (participant) {
                [header updateWithAttributedStringForParticipantName:[[NSAttributedString alloc] initWithString:participant.fullName]];
            } else {
                [header updateWithAttributedStringForParticipantName:[[NSAttributedString alloc] initWithString:@"No Matching Participant"]];
            }
        }
        // Should we display a date label?
        if ([self shouldDisplayDateLabelForSection:indexPath.section]) {
            if ([self.dataSource respondsToSelector:@selector(conversationViewController:attributedStringForDisplayOfDate:)]) {
                NSAttributedString *dateString;
                if (message.sentAt) {
                    dateString = [self.dataSource conversationViewController:self attributedStringForDisplayOfDate:message.sentAt];
                } else {
                    dateString = [self.dataSource conversationViewController:self attributedStringForDisplayOfDate:[NSDate date]];
                }
                NSAssert([dateString isKindOfClass:[NSAttributedString class]], @"`Date String must be an attributed string");
                [header updateWithAttributedStringForDate:dateString];
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"LYRUIConversationViewControllerDataSource must return an attributed string for Date" userInfo:nil];
            }
        }
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
    CGFloat height = 0;
    LYRMessage *message = [self messageAtCollectionViewSection:section];
    if (section > 0) {
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
    // If we display a read receipt...
    if ([self shouldDisplayReadReceiptForSection:section]) {
        return CGSizeMake(CGRectGetWidth(collectionView.frame), 28);
    }
    return CGSizeMake(CGRectGetWidth(collectionView.frame), 6);
}

#pragma mark - Recipient Status Methods

- (void)updateRecipientStatusForMessage:(LYRMessage *)message
{
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

#pragma mark - UI Configuration Methods

- (BOOL)shouldDisplayDateLabelForSection:(NSUInteger)section
{
    // Always show date label for the first section
    if (section == 0) return YES;
    LYRMessage *message = [self messageAtCollectionViewSection:section];
    if (section > 0) {
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
    // 1. If conversation only has 2 participnat, don't show sender label
    if (!(self.conversation.participants.count > 2)) {
        return NO;
    }
    
    // 2. If the message if from current user, don't show sender label
    LYRMessage *message = [self messageAtCollectionViewSection:section];
    if ([message.sentByUserID isEqualToString:self.layerClient.authenticatedUserID]) {
        return NO;
    }

    // 3. If the previous message was send by the same user, don't show label
    if (section > 0) {
        LYRMessage *previousMessage = [self messageAtCollectionViewSection:section - 1];
        if ([previousMessage.sentByUserID isEqualToString:message.sentByUserID]) {
            return NO;
        }
    }

    return YES;
}

- (BOOL)shouldDisplayReadReceiptForSection:(NSUInteger)section
{
    // Only show read receipt if last message was send by currently authenticated user
    LYRMessage *message = [self messageAtCollectionViewSection:section];
    if ((section == ([self.queryController numberOfObjectsInSection:0] - 1)) && [message.sentByUserID isEqualToString:self.layerClient.authenticatedUserID]) {
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
    if (indexPath.section < self.collectionView.numberOfSections - 1) {
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

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self messageAtCollectionViewIndexPath:indexPath];
    LYRMessagePart *part = message.parts.firstObject;
    CGSize size;
    if ([part.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
        NSString *text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        size = LYRUITextPlainSize(text, [UIFont systemFontOfSize:14]);
        size.height = size.height + 16; // Adding 16 to account for default vertical padding for text in bubble view
    } else if ([part.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [part.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
        UIImage *image = [UIImage imageWithData:part.data];
        size = LYRUIImageSize(image);
    } else if ([part.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
        size = CGSizeMake(200, 200);
    } else {
        size = CGSizeMake(320, 10);
    }
    size.height = ceil(size.height);
    return size;
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
    NSMutableArray *participantsTyping = [NSMutableArray array];
    [self.typingParticipantIDs enumerateObjectsUsingBlock:^(NSString *participantID, NSUInteger idx, BOOL *stop) {
        id<LYRUIParticipant> participant = [self participantForIdentifier:participantID];
        [participantsTyping addObject:participant];
    }];

    BOOL visible = participantsTyping.count > 0;
    if (visible) {
        NSString *text = [self typingIndicatorTextWithParticipantsTyping:participantsTyping];
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

- (NSString *)typingIndicatorTextWithParticipantsTyping:(NSArray *)participantsTyping
{
    if (participantsTyping.count == 0) return nil;

    NSArray *fullNames = [participantsTyping valueForKey:@"fullName"];
    NSString *fullNamesText = [self typingIndicatorTextWithParticipantStrings:fullNames participantsCount:participantsTyping.count];
    if ([self typingIndicatorLabelHasSpaceForText:fullNamesText]) return fullNamesText;

    NSArray *firstNames = [participantsTyping valueForKey:@"firstName"];
    NSString *firstNamesText = [self typingIndicatorTextWithParticipantStrings:firstNames participantsCount:participantsTyping.count];
    if ([self typingIndicatorLabelHasSpaceForText:firstNamesText]) return firstNamesText;

    NSMutableArray *strings = [NSMutableArray new];
    for (NSInteger displayedFirstNamesCount = participantsTyping.count - 1; displayedFirstNamesCount >= 0; displayedFirstNamesCount--) {
        [strings removeAllObjects];

        NSRange displayedRange = NSMakeRange(0, displayedFirstNamesCount);
        NSArray *displayedFirstNames = [firstNames subarrayWithRange:displayedRange];
        [strings addObjectsFromArray:displayedFirstNames];

        NSUInteger undisplayedCount = participantsTyping.count - displayedRange.length;
        NSMutableString *textForUndisplayedParticipants = [NSMutableString new];;
        [textForUndisplayedParticipants appendFormat:@"%ld", (unsigned long)undisplayedCount];
        if (undisplayedCount != participantsTyping.count && undisplayedCount == 1) {
            [textForUndisplayedParticipants appendString:@" other"];
        } else if (undisplayedCount != participantsTyping.count) {
            [textForUndisplayedParticipants appendString:@" others"];
        }
        [strings addObject:textForUndisplayedParticipants];

        NSString *proposedSummary = [self typingIndicatorTextWithParticipantStrings:strings participantsCount:participantsTyping.count];
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

#pragma mark - LYRUIMessageInputToolbar Delegate Methods

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

/**
 
 LAYER - Sending a message through Layer. The `LYRUIMessageInputToolbar` informs the controller that the `rightAccessoryButton` 
 property (representing the `SEND` button) was tapped.
 
 */
- (void)messageInputToolbar:(LYRUIMessageInputToolbar *)messageInputToolbar didTapRightAccessoryButton:(UIButton *)rightAccessoryButton
{
    if (!self.conversation) return;
    if (messageInputToolbar.messageParts.count > 0) {
        id<LYRUIParticipant> sender = [self participantForIdentifier:self.layerClient.authenticatedUserID];
        for (id part in messageInputToolbar.messageParts){
            LYRMessagePart *messagePart;
            if ([part isKindOfClass:[NSString class]]) {
                messagePart = LYRUIMessagePartWithText(part);
            } else if ([part isKindOfClass:[UIImage class]]) {
                messagePart = LYRUIMessagePartWithJPEGImage(part);
            } else if ([part isKindOfClass:[CLLocation class]]) {
                messagePart = LYRUIMessagePartWithLocation(part);
            } else {
                continue;
            }
            NSString *pushText = [self pushNotificationStringForMessagePart:messagePart];
            NSString *text = [NSString stringWithFormat:@"%@: %@", [sender fullName], pushText];
            NSDictionary *pushOptions;
            if (pushText) {
                pushOptions = @{LYRMessageOptionsPushNotificationAlertKey: text,
                               LYRMessageOptionsPushNotificationSoundNameKey: @"default"};
            }
            LYRMessage *message = [self.layerClient newMessageWithParts:@[messagePart]
                                                                options:pushOptions
                                                                  error:nil];
            [self sendMessage:message];
        }
        if (self.addressBarController) [self.addressBarController setPermanent];
    }
}

/**
 
 LAYER - Input tool bar began typing, so we can send a typing indicator.
 
 */
- (void)messageInputToolbarDidType:(LYRUIMessageInputToolbar *)messageInputToolbar
{
    if (!self.conversation) return;
    [self.conversation sendTypingIndicator:LYRTypingDidBegin];
}

/**
 
 LAYER - Input tool bar ended typing, so we can terminate the typing indicator.
 
 */
- (void)messageInputToolbarDidEndTyping:(LYRUIMessageInputToolbar *)messageInputToolbar
{
    if (!self.conversation) return;
    [self.conversation sendTypingIndicator:LYRTypingDidFinish];
}

#pragma mark - Message Send Methods

- (NSString *)pushNotificationStringForMessagePart:(LYRMessagePart *)messagePart
{
    NSString *pushText;
    if ([self.dataSource respondsToSelector:@selector(conversationViewController:pushNotificationTextForMessagePart:)]) {
        pushText = [self.dataSource conversationViewController:self pushNotificationTextForMessagePart:messagePart];
    } 
    return pushText;
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

#pragma mark UIActionSheetDelegate Methods

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

#pragma mark UIImagePicker Methods

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
    // Credit goes to @iBrad Apps on Stack Overflow
    // http://stackoverflow.com/questions/8867496/get-last-image-from-photos-app
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                
                // Stop the enumerations
                *stop = YES; *innerStop = YES;
                
                // Do something interesting with the AV asset.
                [self.messageInputToolbar insertImage:latestPhoto];
            }
        }];
    } failureBlock:nil];
}

#pragma mark UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:@"UIImagePickerControllerMediaType"];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *selectedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
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

#pragma mark CollectionView Content Inset Methods

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

#pragma mark Handle Device Rotation

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration
{
    [self.collectionView.collectionViewLayout invalidateLayout];
    
}

#pragma mark Notification Observer Delegate Methods

- (void)queryController:(LYRQueryController *)controller
        didChangeObject:(id)object
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(LYRQueryControllerChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath
{
    [self.objectChanges addObject:[LYRUIDataSourceChange changeObjectWithType:type newIndex:newIndexPath.row currentIndex:indexPath.row]];
}

- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController
{
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
                    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:change.currentIndex]];
                    break;
                    
                default:
                    break;
            }
        }
        [self.objectChanges removeAllObjects];
    } completion:nil];

    // Since each section's footer content depends on the existence of other messages, we need to update footers even when the corresponding message to a footer has not changed.
    for (LYRUIConversationCollectionViewFooter *footer in self.sectionFooters) {
        NSIndexPath *queryControllerIndexPath = [self.queryController indexPathForObject:footer.message];
        if (!queryControllerIndexPath) continue;
        NSIndexPath *collectionViewIndexPath = [self collectionViewIndexPathForQueryControllerIndexPath:queryControllerIndexPath];
        [self configureFooter:footer atIndexPath:collectionViewIndexPath];
    }

    if (shouldScrollToBottom)  {
        [self scrollToBottomOfCollectionViewAnimated:YES];
    }
}

- (void)scrollToBottomOfCollectionViewAnimated:(BOOL)animated
{
    [self.collectionView setContentOffset:[self bottomOffset] animated:animated];
}

- (id<LYRUIParticipant>)participantForIdentifier:(NSString *)identifier
{
    if ([self.dataSource respondsToSelector:@selector(conversationViewController:participantForIdentifier:)]) {
        return [self.dataSource conversationViewController:self participantForIdentifier:identifier];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"LYRUIConversationViewControllerDelegate must return a particpant for an identifier" userInfo:nil];
    }
}

#pragma mark - Address Bar View Controller Delegate Methods

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

- (void)configureConversationWithAddressBar:(LYRUIAddressBarViewController *)addressBarViewController
{
    NSSet *participants = [addressBarViewController.selectedParticipants valueForKey:@"participantIdentifier"];
    if (!participants.count) {
        self.conversation = nil;
    } else {
        LYRConversation *conversation = [self conversationWithParticipants:participants];
        if (conversation) {
            self.conversation = conversation;
        } else {
            self.conversation = [self.layerClient newConversationWithParticipants:participants options:nil error:nil];
        }
    }
    [self setConversationViewTitle];
    [self configureAvatarImageDisplay];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
    [self scrollToBottomOfCollectionViewAnimated:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.collectionView.alpha = 1.0f;
    }];
}

- (LYRConversation *)conversationWithParticipants:(NSSet *)participants
{
    NSMutableSet *set = [participants mutableCopy];
    [set addObject:self.layerClient.authenticatedUserID];
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" operator:LYRPredicateOperatorIsEqualTo value:set];
    return [[self.layerClient executeQuery:query error:nil] lastObject];
}

#pragma mark Send Button Enablement

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

#pragma mark - Helpers

- (void)configureFooter:(LYRUIConversationCollectionViewFooter *)footer atIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self messageAtCollectionViewIndexPath:indexPath];
    footer.message = message;
    if ([self shouldDisplayReadReceiptForSection:indexPath.section]) {
        if ([self.dataSource respondsToSelector:@selector(conversationViewController:attributedStringForDisplayOfRecipientStatus:)]) {
            NSAttributedString *recipientStatusString = [self.dataSource conversationViewController:self attributedStringForDisplayOfRecipientStatus:message.recipientStatusByUserID];
            NSAssert([recipientStatusString isKindOfClass:[NSAttributedString class]], @"`Date String must be an attributed string");
            [footer updateWithAttributedStringForRecipientStatus:recipientStatusString];
        } else {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"LYRUIConversationViewControllerDataSource must return an attributed string for recipient status" userInfo:nil];
        }
    } else {
        [footer updateWithAttributedStringForRecipientStatus:nil];
    }
}

#pragma mark - Query Controller

- (NSIndexPath *)queryControllerIndexPathForCollectionViewIndexPath:(NSIndexPath *)collectionViewIndexPath
{
    return [self queryControllerIndexPathForCollectionViewSection:collectionViewIndexPath.section];
}

- (NSIndexPath *)queryControllerIndexPathForCollectionViewSection:(NSInteger)collectionViewSection
{
    NSIndexPath *queryControllerIndexPath = [NSIndexPath indexPathForRow:collectionViewSection inSection:0];
    return queryControllerIndexPath;
}

- (NSIndexPath *)collectionViewIndexPathForQueryControllerIndexPath:(NSIndexPath *)queryControllerIndexPath
{
    return [self collectionViewIndexPathForQueryControllerRow:queryControllerIndexPath.row];
}

- (NSIndexPath *)collectionViewIndexPathForQueryControllerRow:(NSInteger)queryControllerRow
{
    NSIndexPath *collectionViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:queryControllerRow];
    return collectionViewIndexPath;
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
