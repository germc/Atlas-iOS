//
//  LYRUIConversationViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationViewController.h"
#import "LYRUIConversationCollectionViewFlowLayout.h"
#import "LYRUIOutgoingMessageCollectionViewCell.h"
#import "LYRUIIncomingMessageCollectionViewCell.h"
#import "LYRUIConversationCollectionViewHeader.h"
#import "LYRUIConversationCollectionViewFooter.h"
#import "LYRUIConstants.h"
#import "LYRUIUtilities.h"
#import "LYRUIMessageBubbleView.h"
#import "LYRUIMessageInputToolbar.h"
#import "LYRUIDataSourceChange.h"
#import "LYRUIMessageDataSource.h"
#import "LYRUIParticipantTableViewController.h"

@interface LYRUIConversationViewController () <UICollectionViewDataSource, UICollectionViewDelegate, LYRUIMessageInputToolbarDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LYRUIMessageDataSourceDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) NSOrderedSet *messages;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) LYRUIMessageDataSource *conversationDataSource;
@property (nonatomic) BOOL keyboardIsOnScreen;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) UIView *inputAccessoryView;
@property (nonatomic) BOOL shouldScrollToBottom;

@end

@implementation LYRUIConversationViewController

static NSString *const LYRUIIncomingMessageCellIdentifier = @"incomingMessageCellIdentifier";
static NSString *const LYRUIOutgoingMessageCellIdentifier = @"outgoingMessageCellIdentifier";
static NSString *const LYRUIMessageCellHeaderIdentifier = @"messageCellHeaderIdentifier";
static NSString *const LYRUIMessageCellFooterIdentifier = @"messageCellFooterIdentifier";
static CGFloat const LYRUIMessageInputToolbarHeight = 40;

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Failed to call designated initializer." userInfo:nil];
}

+ (instancetype)conversationViewControllerWithConversation:(LYRConversation *)conversation layerClient:(LYRClient *)layerClient;
{
    NSAssert(layerClient, @"`Layer Client` cannot be nil");
    NSAssert(conversation, @"`Conversation` cannont be nil");
    return [[self alloc] initWithConversation:conversation layerClient:layerClient];
}

- (id)initWithConversation:(LYRConversation *)conversation layerClient:(LYRClient *)layerClient
{
    self = [super init];
    if (self) {
         // Set properties from designated initializer
        _conversation = conversation;
        _layerClient = layerClient;
        
        // Set default configuration for public properties
        _dateDisplayTimeInterval = 60*60;
        
        _shouldScrollToBottom = FALSE;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup Collection View
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                             collectionViewLayout:[[LYRUIConversationCollectionViewFlowLayout alloc] init]];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = TRUE;
    self.collectionView.bounces = TRUE;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    self.collectionView.accessibilityLabel = @"Conversation Collection View";
    [self.view addSubview:self.collectionView];
    
    // Register reusable collection view cells, header and footer
    [self.collectionView registerClass:[LYRUIIncomingMessageCollectionViewCell class] forCellWithReuseIdentifier:LYRUIIncomingMessageCellIdentifier];
    [self.collectionView registerClass:[LYRUIOutgoingMessageCollectionViewCell class] forCellWithReuseIdentifier:LYRUIOutgoingMessageCellIdentifier];
    [self.collectionView registerClass:[LYRUIConversationCollectionViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:LYRUIMessageCellHeaderIdentifier];
    [self.collectionView registerClass:[LYRUIConversationCollectionViewFooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:LYRUIMessageCellFooterIdentifier];
    
    // Set the accessoryView to be a Message Input Toolbar
    LYRUIMessageInputToolbar *messageInputToolbar =  [LYRUIMessageInputToolbar new];
    messageInputToolbar.inputToolBarDelegate = self;
    self.inputAccessoryView = messageInputToolbar;
    
    // Configure defualt cell appearance
    [self configureMessageBubbleAppearance];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [panGestureRecognizer setMinimumNumberOfTouches:1];
    [panGestureRecognizer setMaximumNumberOfTouches:1];
    panGestureRecognizer.delegate = self;
    //[self.collectionView  addGestureRecognizer:panGestureRecognizer];
    
    self.accessibilityLabel = @"Conversation";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Collection View AutoLayout Config
    [self updateCollectionViewConstraints];
    
    // Setup Layer Change notification observer
    self.conversationDataSource = [[LYRUIMessageDataSource alloc] initWithClient:self.layerClient conversation:self.conversation];
    self.conversationDataSource.delegate = self;
    
    [self setConversationViewTitle];
    [self scrollToBottomOfCollectionViewAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Setup Layer Change notification observer
    self.conversationDataSource = [[LYRUIMessageDataSource alloc] initWithClient:self.layerClient conversation:self.conversation];
    self.conversationDataSource.delegate = self;
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.keyboardIsOnScreen = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.conversationDataSource.delegate = nil;
    self.conversationDataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                object:nil];
}

- (void)dealloc
{
    self.collectionView.delegate = nil;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void) setConversationViewTitle
{
    if (self.conversation.participants.count == 2) {
        NSMutableSet *participants = [self.conversation.participants mutableCopy];
        [participants removeObject:self.layerClient.authenticatedUserID];
        id<LYRUIParticipant> participant = [self participantForIdentifier:[[participants allObjects] lastObject]];
        if (participant) {
            self.title = participant.firstName;
        } else {
            self.title = @"Unknown";
        }
    } else {
        self.title = @"Group";
    }
}

# pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // MessageParts correspond to rows in a section
    LYRMessage *message = [self.conversationDataSource.messages objectAtIndex:section];
    return message.parts.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Messages correspond to sections
    return self.conversationDataSource.messages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.conversationDataSource.messages objectAtIndex:indexPath.section];
    LYRUIMessageCollectionViewCell <LYRUIMessagePresenting> *cell;
    if ([self.layerClient.authenticatedUserID isEqualToString:message.sentByUserID]) {
        // If the message was sent by the currently authenticated user, it is outgoing
        cell =  [self.collectionView dequeueReusableCellWithReuseIdentifier:LYRUIOutgoingMessageCellIdentifier forIndexPath:indexPath];
    } else {
        // If the message was sent by someone other than the currently authenticated user, it is incoming
        cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:LYRUIIncomingMessageCellIdentifier forIndexPath:indexPath];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(LYRUIMessageCollectionViewCell <LYRUIMessagePresenting> *)cell atIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.conversationDataSource.messages objectAtIndex:indexPath.section];
    LYRMessagePart *messagePart = [message.parts objectAtIndex:indexPath.row];
    [cell presentMessagePart:messagePart];
    [cell updateWithBubbleViewWidth:[self sizeForItemAtIndexPath:indexPath].width];
    [cell shouldDisplayAvatarImage:[self shouldDisplayAvatarImageForIndexPath:indexPath]];
    if ([self.dataSource respondsToSelector:@selector(conversationViewController:shouldUpdateRecipientStatusForMessage:)]) {
        if ([self.dataSource conversationViewController:self shouldUpdateRecipientStatusForMessage:message]) {
            [self updateRecipientStatusForMessage:message];
        }
    }
}

#pragma mark
#pragma mark Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Nothing to do for now
}

#pragma mark – UICollectionViewDelegateFlowLayout Methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = self.collectionView.bounds.size.width;
    CGFloat height = [self sizeForItemAtIndexPath:indexPath].height;
    return CGSizeMake(width, height);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.conversationDataSource.messages objectAtIndex:indexPath.section];
    if (kind == UICollectionElementKindSectionHeader ) {
        LYRUIConversationCollectionViewHeader *header = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:LYRUIMessageCellHeaderIdentifier forIndexPath:indexPath];
        // Should we display a sender label
        if ([self shouldDisplaySenderLabelForSection:indexPath.section]) {
            id<LYRUIParticipant>participant = [self participantForIdentifier:message.sentByUserID];
            if(participant) {
                [header updateWithAttributedStringForParticipantName:[[NSAttributedString alloc] initWithString:participant.fullName]];
            } else {
                [header updateWithAttributedStringForParticipantName:[[NSAttributedString alloc] initWithString:@"No Matching Participant"]];
            }
        }
        // Should we display a date label
        if ([self shouldDisplayDateLabelForSection:indexPath.section]) {
            if ([self.dataSource respondsToSelector:@selector(conversationViewController:attributedStringForDisplayOfDate:)]) {
                NSAttributedString *dateString = [NSAttributedString new];
                if (message.sentAt) {
                    dateString = [self.dataSource conversationViewController:self attributedStringForDisplayOfDate:message.sentAt];
                } else {
                    dateString = [self.dataSource conversationViewController:self attributedStringForDisplayOfDate:[NSDate date]];
                }
                NSAssert([dateString isKindOfClass:[NSAttributedString class]], @"`Date String must be an attributed string");
                [header updateWithAttributedStringForDate:dateString];
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"LYRUIConversationViewControllerDataSource must return an attributed string for Data" userInfo:nil];
            }
        }
        return header;
    } else {
        LYRUIConversationCollectionViewFooter *footer = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:LYRUIMessageCellFooterIdentifier forIndexPath:indexPath];
        // Should we display a read receipt
        if ([self shouldDisplayReadReceiptForSection:indexPath.section]) {
            if ([self.dataSource respondsToSelector:@selector(conversationViewController:attributedStringForDisplayOfRecipientStatus:)]) {
                NSAttributedString *recipientStatusString = [self.dataSource conversationViewController:self attributedStringForDisplayOfRecipientStatus:message.recipientStatusByUserID];
                NSAssert([recipientStatusString isKindOfClass:[NSAttributedString class]], @"`Date String must be an attributed string");
                [footer updateWithAttributedStringForRecipientStatus:recipientStatusString];
            } else {
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"LYRUIConversationViewControllerDataSource must return an attributed string for recipient status" userInfo:nil];
            }
        }
        return footer;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    LYRMessage *message = [self.conversationDataSource.messages objectAtIndex:section];
    if (section > 0) {
        LYRMessage *previousMessage = [self.conversationDataSource.messages objectAtIndex:section - 1];
        if (![message.sentByUserID isEqualToString:previousMessage.sentByUserID]) {
            height += 10;
        }
    }
    if ([self shouldDisplayDateLabelForSection:section]) {
        height += 30;
    }
    if ([self shouldDisplaySenderLabelForSection:section]) {
        height += 30;
    }
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    if ([self shouldDisplayReadReceiptForSection:section]) {
        return CGSizeMake(rect.size.width, 28);
    }
    return CGSizeMake(rect.size.width, 6);
}

#pragma mark - Recipient Status Methods

- (void)updateRecipientStatusForMessage:(LYRMessage *)message
{
    NSNumber *recipientStatus = [message.recipientStatusByUserID objectForKey:self.layerClient.authenticatedUserID];
    if (![recipientStatus isEqualToNumber:[NSNumber numberWithInteger:LYRRecipientStatusRead]] ) {
        NSError *error;
        BOOL success = [self.layerClient markMessageAsRead:message error:&error];
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
    // If it is the first section, show date label
    if (section == 0) return YES;
    LYRMessage *previousMessage;
    LYRMessage *message = [self.conversationDataSource.messages objectAtIndex:section];
    if (section > 0) {
        previousMessage = [self.conversationDataSource.messages objectAtIndex:section - 1];
    }
    NSTimeInterval interval = [message.receivedAt timeIntervalSinceDate:previousMessage.receivedAt];
    // If it has been 60min since last message, show date label
    if (interval > self.dateDisplayTimeInterval) {
        return YES;
    }
    // Otherwise, don't show date label
    return NO;
}

- (BOOL)shouldDisplaySenderLabelForSection:(NSUInteger)section
{
    LYRMessage *message = [self.conversationDataSource.messages objectAtIndex:section];
    if ([message.sentByUserID isEqualToString:self.layerClient.authenticatedUserID]) {
        return NO;
    }
    if (!self.conversation.participants.count > 2) {
        return NO;
    }
    if (section > 0) {
        LYRMessage *previousMessage = [self.conversationDataSource.messages objectAtIndex:section - 1];
        if ([previousMessage.sentByUserID isEqualToString:message.sentByUserID]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)shouldDisplayReadReceiptForSection:(NSUInteger)section
{
    LYRMessage *message = [self.conversationDataSource.messages objectAtIndex:section];
    if ((section == self.conversationDataSource.messages.count - 1) && [message.sentByUserID isEqualToString:self.layerClient.authenticatedUserID]) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldDisplayAvatarImageForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.collectionView.numberOfSections - 1) {
        return TRUE;
    }
    LYRMessage *message = [self.conversationDataSource.messages objectAtIndex:indexPath.section];
    if (indexPath.section < self.collectionView.numberOfSections - 1) {
        LYRMessage *nextMessage = [self.conversationDataSource.messages objectAtIndex:indexPath.section + 1];
        // If the next message is sent by the same user, no
        if ([nextMessage.sentByUserID isEqualToString:message.sentByUserID]) {
            return FALSE;
        } else {
            return TRUE;
        }
    }
    return TRUE;
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LYRMessage *message = [self.conversationDataSource.messages objectAtIndex:indexPath.section];
    LYRMessagePart *part = [message.parts objectAtIndex:indexPath.row];
    
    CGSize size;
    if ([part.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
        NSString *text = [[NSString alloc] initWithData:part.data encoding:NSUTF8StringEncoding];
        size = LYRUITextPlainSize(text, [[LYRUIOutgoingMessageCollectionViewCell appearance] messageTextFont]);
        size.height = size.height + 16; // Adding 16 to account for default vertical padding for text in bubble view
    } else if ([part.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG] || [part.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
        UIImage *image = [UIImage imageWithData:part.data];
        size = LYRUIImageSize(image);
    } else {
        size = CGSizeMake(320, 10);
    }
    return size;
}

#pragma mark
#pragma mark Keyboard Nofifications

- (void)keyboardWasShown:(NSNotification*)notification
{
    self.keyboardIsOnScreen = TRUE;
    NSDictionary* info = [notification userInfo];
    self.keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self updateCollectionViewInsets];
    [UIView commitAnimations];
    [self scrollToBottomOfCollectionViewAnimated:TRUE];
    self.keyboardIsOnScreen = TRUE;
}

- (void)keyboardWillBeHidden:(NSNotification*)notification
{
    self.keyboardHeight = 0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self updateCollectionViewInsets];
    [UIView commitAnimations];
    self.keyboardIsOnScreen = FALSE;
}

#pragma mark LYRUIMessageInputToolbar Delegate Methods

- (void)messageInputToolbar:(LYRUIMessageInputToolbar *)messageInputToolbar didTapLeftAccessoryButton:(UIButton *)leftAccessoryButton
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Select Photo", @"Take Photo", nil];
    [actionSheet showInView:self.view];
}

- (void)messageInputToolbar:(LYRUIMessageInputToolbar *)messageInputToolbar didTapRightAccessoryButton:(UIButton *)rightAccessoryButton
{
    for (id part in messageInputToolbar.messageParts){
        if ([part isKindOfClass:[NSString class]]) {
            [self sendMessageWithText:part];
        }
        if ([part isKindOfClass:[UIImage class]]) {
            [self sendMessageWithImage:part];
        }
        if ([part isKindOfClass:[CLLocation class]]) {
            [self sendMessageWithLocation:part];
        }
    }
}

#pragma mark Message Sent Methods

- (void)sendMessageWithText:(NSString *)text
{
    LYRMessagePart *part = [LYRMessagePart messagePartWithMIMEType:@"text/plain" data:[text dataUsingEncoding:NSUTF8StringEncoding]];
    LYRMessage *message = [LYRMessage messageWithConversation:self.conversation parts:@[ part ]];
    [self sendMessage:message pushText:[self pushNotificationStringForMessage:message]];
}

- (void)sendMessageWithImage:(UIImage *)image
{
    UIImage *adjustedImage = LYRUIAdjustOrientationForImage(image);
    NSData *compressedImageData =  LYRUIJPEGDataForImageWithConstraint(adjustedImage, 300);
    LYRMessagePart *part = [LYRMessagePart messagePartWithMIMEType:LYRUIMIMETypeImageJPEG data:compressedImageData];
    LYRMessage *message = [LYRMessage messageWithConversation:self.conversation parts:@[ part ]];
    [self sendMessage:message pushText:[self pushNotificationStringForMessage:message]];
}

- (void)sendMessageWithLocation:(CLLocation *)location
{
    NSNumber *lat = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber *lon = [NSNumber numberWithDouble:location.coordinate.longitude];
    LYRMessagePart *part = [LYRMessagePart messagePartWithMIMEType:LYRUIMIMETypeLocation data:[NSJSONSerialization dataWithJSONObject: @{@"lat" : lat, @"lon" : lon} options:0 error:nil]];
    LYRMessage *message = [LYRMessage messageWithConversation:self.conversation parts:@[ part ]];
    [self sendMessage:message pushText:[self pushNotificationStringForMessage:message]];
}

- (NSString *)pushNotificationStringForMessage:(LYRMessage *)message
{
    NSString *pushText;
    if ( [self.dataSource respondsToSelector:@selector(conversationViewController:pushNotificationTextForMessage:)]) {
        pushText = [self.dataSource conversationViewController:self pushNotificationTextForMessage:message];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"LYRUIConversationViewControllerDataSource must return a Push Notification string" userInfo:nil];
    }
    return pushText;
}

- (void)sendMessage:(LYRMessage *)message pushText:(NSString *)pushText
{
    self.shouldScrollToBottom = TRUE;
    id<LYRUIParticipant>sender = [self participantForIdentifier:self.layerClient.authenticatedUserID];
    NSString *text = [NSString stringWithFormat:@"%@: %@", [sender fullName], pushText];
    [self.layerClient setMetadata:@{LYRMessagePushNotificationAlertMessageKey: text,
                                    LYRMessagePushNotificationSoundNameKey : @"default"} onObject:message];
    NSError *error;
    BOOL success = [self.layerClient sendMessage:message error:&error];
    if (success) {
        if ([self.delegate respondsToSelector:@selector(conversationViewController:didSendMessage:)]) {
            [self.delegate conversationViewController:self didSendMessage:message];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(conversationViewController:didFailSendingMessageWithError:)]) {
            [self.delegate conversationViewController:self didFailSendingMessageWithError:error];
        }
    }
}

#pragma mark UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
        case 1:
            [self displayImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
            
        default:
            break;
    }
}

#pragma mark UIImagePicker Methods

- (void)displayImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType;
{
    [[(LYRUIMessageInputToolbar *)self.inputAccessoryView textInputView] resignFirstResponder];
    BOOL pickerSourceTypeAvailable = [UIImagePickerController isSourceTypeAvailable:sourceType];
    if (pickerSourceTypeAvailable) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = sourceType;
        [self.navigationController presentViewController:picker animated:YES completion:nil];
        NSLog(@"Camera is available");
    }
}

#pragma mark UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:@"UIImagePickerControllerMediaType"];
    if ([mediaType isEqualToString:@"public.image"]) {
        UIImage *selectedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        [(LYRUIMessageInputToolbar *)self.inputAccessoryView insertImage:selectedImage];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark CollectionView Content Inset Methods

- (void)updateCollectionViewInsets
{
    UIEdgeInsets existing = self.collectionView.contentInset;
    self.collectionView.contentInset = self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(existing.top, 0, self.keyboardHeight, 0);
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
}

#pragma mark Notification Observer Delegate Methods

- (void)observer:(LYRUIMessageDataSource *)observer updateWithChanges:(NSArray *)changes 
{
//    NSLog(@"Update happening with changes:%@", changes);
//    [self.collectionView performBatchUpdates:^{
//        [self.collectionView reloadData];
//        for (LYRUIDataSourceChange *change in changes) {
//            switch (change.type) {
//                case LYRUIDataSourceChangeTypeInsert:
//                    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:change.newIndex]];
//                    break;
//                    
//                case LYRUIDataSourceChangeTypeMove:
//                    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:change.oldIndex]];
//                    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:change.newIndex]];
//                    break;
//                    
//                case LYRUIDataSourceChangeTypeUpdate:
//                    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:change.newIndex]];
//                    break;
//                    
//                case LYRUIDataSourceChangeTypeDelete:
//                    [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:change.newIndex]];
//                    break;
//                    
//                default:
//                    break;
//            }
//        }
//    } completion:^(BOOL finished) {
//        if (self.shouldScrollToBottom) {
//            [self scrollToBottomOfCollectionViewAnimated:TRUE];
//            self.shouldScrollToBottom = FALSE;
//        }
//    }];
    [self.collectionView reloadData];
    if (self.shouldScrollToBottom) {
        [self scrollToBottomOfCollectionViewAnimated:TRUE];
        self.shouldScrollToBottom = FALSE;
    }
}

- (void)scrollToBottomOfCollectionViewAnimated:(BOOL)animated
{
    if (self.conversationDataSource.messages.count > 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView setContentOffset:[self bottomOffset] animated:animated];
        });
    }
}

- (void)updateCollectionViewConstraints
{
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
                                                           constant:-self.inputAccessoryView.frame.size.height]];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    CGFloat inset = [sender translationInView:self.collectionView].x * 0.5;
    LYRUIConversationCollectionViewFlowLayout *layout = (LYRUIConversationCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        [self.collectionView performBatchUpdates:^{
            layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
            [layout invalidateLayout];
        } completion:nil];
    } else {
        if (inset > -60 && inset < 0) {
            layout.sectionInset = UIEdgeInsetsMake(0, inset, 0, -inset);
            [layout invalidateLayout];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (id<LYRUIParticipant>)participantForIdentifier:(NSString *)identifier
{
    if ([self.dataSource respondsToSelector:@selector(conversationViewController:participantForIdentifier:)]) {
        return [self.dataSource conversationViewController:self participantForIdentifier:identifier];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"LYRUIConversationViewControllerDelegate must return a particpant for an identifier" userInfo:nil];
    }
    
}

#pragma mark Default Message Cell Appearance

- (void)configureMessageBubbleAppearance
{
    [[LYRUIOutgoingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor whiteColor]];
    [[LYRUIOutgoingMessageCollectionViewCell appearance] setMessageTextFont:[UIFont systemFontOfSize:14]];
    [[LYRUIOutgoingMessageCollectionViewCell appearance] setBubbleViewColor:LSBlueColor()];
    
    [[LYRUIIncomingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor blackColor]];
    [[LYRUIIncomingMessageCollectionViewCell appearance] setMessageTextFont:[UIFont systemFontOfSize:14]];
    [[LYRUIIncomingMessageCollectionViewCell appearance] setBubbleViewColor:LSLighGrayColor()];
}

@end
