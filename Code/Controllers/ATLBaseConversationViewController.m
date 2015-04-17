//
//  ATLBaseConversationViewController.m
//  Atlas
//
//  Created by Kevin Coleman on 10/27/14.
//  Copyright (c) 2015 Layer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ATLBaseConversationViewController.h"
#import "ATLConversationView.h"

@interface ATLBaseConversationViewController ()

@property (nonatomic) ATLConversationView *view;
@property (nonatomic) NSMutableArray *typingParticipantIDs;
@property (nonatomic) NSLayoutConstraint *typingIndicatorViewBottomConstraint;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic, getter=isFirstAppearance) BOOL firstAppearance;

@end

@implementation ATLBaseConversationViewController

@dynamic view;

static CGFloat const ATLTypingIndicatorHeight = 20;
static CGFloat const ATLMaxScrollDistanceFromBottom = 150;

- (id)init
{
    self = [super init];
    if (self) {
        [self baseCommonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self baseCommonInit];
    }
    return self;
}

- (void)baseCommonInit
{
    _displaysAddressBar = NO;
    _typingParticipantIDs = [NSMutableArray new];
    _firstAppearance = YES;
}

- (void)loadView
{
    self.view = [ATLConversationView new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add message input tool bar
    self.messageInputToolbar = [ATLMessageInputToolbar new];
    // An apparent system bug causes a view controller to not be deallocated
    // if the view controller's own inputAccessoryView property is used.
    self.view.inputAccessoryView = self.messageInputToolbar;
    
    // Add typing indicator
    self.typingIndicatorController = [[ATLTypingIndicatorViewController alloc] init];
    [self addChildViewController:self.typingIndicatorController];
    [self.view addSubview:self.typingIndicatorController.view];
    [self.typingIndicatorController didMoveToParentViewController:self];
    [self configureTypingIndicatorLayoutConstraints];
    
    // Add address bar if needed
    if (self.displaysAddressBar) {
        self.addressBarController = [[ATLAddressBarViewController alloc] init];
        [self addChildViewController:self.addressBarController];
        [self.view addSubview:self.addressBarController.view];
        [self.addressBarController didMoveToParentViewController:self];
        [self configureAddressbarLayoutConstraints];
    }
    [self atl_baseRegisterForNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Workaround for a modal dismissal causing the message toolbar to remain offscreen on iOS 8.
    if (self.presentedViewController) {
        [self.view becomeFirstResponder];
    }
    if (self.addressBarController && self.firstAppearance) {
        [self updateTopCollectionViewInset];
    }
    [self updateBottomCollectionViewInset];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // To get the toolbar to slide onscreen with the view controller's content, we have to make the view the
    // first responder here. Even so, it will not animate on iOS 8 the first time.
    if (!self.presentedViewController && self.navigationController && !self.view.inputAccessoryView.superview) {
        [self.view becomeFirstResponder];
    }
    
    if (self.isFirstAppearance) {
        self.firstAppearance = NO;
        // We use the content size of the actual collection view when calculating the ammount to scroll. Hence, we layout the collection view before scrolling to the bottom.
        [self.view layoutIfNeeded];
        [self scrollToBottomAnimated:NO];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Setters 

- (void)setCollectionView:(UICollectionView *)collectionView
{
    _collectionView = collectionView;
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.collectionView];
    [self configureCollectionViewLayoutConstraints];
}

- (void)setTypingIndicatorInset:(CGFloat)typingIndicatorInset
{
    _typingIndicatorInset = typingIndicatorInset;
    [UIView animateWithDuration:0.1 animations:^{
        [self updateBottomCollectionViewInset];
    }];
}

#pragma mark - Public Methods

- (BOOL)shouldScrollToBottom
{
    CGPoint bottomOffset = [self bottomOffsetForContentSize:self.collectionView.contentSize];
    CGFloat distanceToBottom = bottomOffset.y - self.collectionView.contentOffset.y;
    BOOL shouldScrollToBottom = distanceToBottom <= ATLMaxScrollDistanceFromBottom && !self.collectionView.isTracking && !self.collectionView.isDragging && !self.collectionView.isDecelerating;
    return shouldScrollToBottom;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    CGSize contentSize = self.collectionView.contentSize;
    [self.collectionView setContentOffset:[self bottomOffsetForContentSize:contentSize] animated:animated];
}

#pragma mark - Content Inset Management  

- (void)updateTopCollectionViewInset
{
    [self.addressBarController.view layoutIfNeeded];
    
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.collectionView.scrollIndicatorInsets;
    CGRect frame = [self.view convertRect:self.addressBarController.addressBarView.frame fromView:self.addressBarController.addressBarView.superview];
    
    contentInset.top = CGRectGetMaxY(frame);
    scrollIndicatorInsets.top = contentInset.top;
    self.collectionView.contentInset = contentInset;
    self.collectionView.scrollIndicatorInsets = scrollIndicatorInsets;
}

- (void)updateBottomCollectionViewInset
{
    [self.messageInputToolbar layoutIfNeeded];
    
    UIEdgeInsets insets = self.collectionView.contentInset;
    CGFloat keyboardHeight = MAX(self.keyboardHeight, CGRectGetHeight(self.messageInputToolbar.frame));
    
    insets.bottom = keyboardHeight + self.typingIndicatorInset;
    self.collectionView.scrollIndicatorInsets = insets;
    self.collectionView.contentInset = insets;
    self.typingIndicatorViewBottomConstraint.constant = -keyboardHeight;
}

#pragma mark - Notification Handlers

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self configureWithKeyboardNotification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (![self.navigationController.viewControllers containsObject:self]) {
        return;
    }
    [self configureWithKeyboardNotification:notification];
}

- (void)messageInputToolbarDidChangeHeight:(NSNotification *)notification
{
    if (!self.messageInputToolbar.superview) {
       return;
    }
    
    CGRect toolbarFrame = [self.view convertRect:self.messageInputToolbar.frame fromView:self.messageInputToolbar.superview];
    CGFloat keyboardOnscreenHeight = CGRectGetHeight(self.view.frame) - CGRectGetMinY(toolbarFrame);
    if (keyboardOnscreenHeight == self.keyboardHeight) return;
    
    BOOL messagebarDidGrow = keyboardOnscreenHeight > self.keyboardHeight;
    self.keyboardHeight = keyboardOnscreenHeight;
     self.typingIndicatorViewBottomConstraint.constant = -self.collectionView.scrollIndicatorInsets.bottom;
    [self updateBottomCollectionViewInset];
    
    if ([self shouldScrollToBottom] && messagebarDidGrow) {
        [self scrollToBottomAnimated:YES];
    }
}

- (void)textViewTextDidBeginEditing:(NSNotification *)notification
{
    [self scrollToBottomAnimated:YES];
}

#pragma mark - Keyboard Management 

- (void)configureWithKeyboardNotification:(NSNotification *)notification
{
    CGRect keyboardBeginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardBeginFrameInView = [self.view convertRect:keyboardBeginFrame fromView:nil];
    CGRect keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardEndFrameInView = [self.view convertRect:keyboardEndFrame fromView:nil];
    CGRect keyboardEndFrameIntersectingView = CGRectIntersection(self.view.bounds, keyboardEndFrameInView);
    
    CGFloat keyboardHeight = CGRectGetHeight(keyboardEndFrameIntersectingView);
    // Workaround for keyboard height inaccuracy on iOS 8.
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        keyboardHeight -= CGRectGetMinY(self.messageInputToolbar.frame);
    }
    self.keyboardHeight = keyboardHeight;
    
    // Workaround for collection view cell sizes changing/animating when view is first pushed onscreen on iOS 8.
    if (CGRectEqualToRect(keyboardBeginFrameInView, keyboardEndFrameInView)) {
        [UIView performWithoutAnimation:^{
            [self updateBottomCollectionViewInset];
        }];
        return;
    }
    
    [self.view layoutIfNeeded];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [self updateBottomCollectionViewInset];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

#pragma mark - Helpers

- (CGPoint)bottomOffsetForContentSize:(CGSize)contentSize
{
    CGFloat contentSizeHeight = contentSize.height;
    CGFloat collectionViewFrameHeight = self.collectionView.frame.size.height;
    CGFloat collectionViewBottomInset = self.collectionView.contentInset.bottom;
    CGFloat collectionViewTopInset = self.collectionView.contentInset.top;
    CGPoint offset = CGPointMake(0, MAX(-collectionViewTopInset, contentSizeHeight - (collectionViewFrameHeight - collectionViewBottomInset)));
    return offset;
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

#pragma mark - Auto Layout

- (void)configureCollectionViewLayoutConstraints
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}

- (void)configureTypingIndicatorLayoutConstraints
{
    // Typing Indicatr
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.typingIndicatorController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.typingIndicatorController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.typingIndicatorController.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLTypingIndicatorHeight]];
    self.typingIndicatorViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.typingIndicatorController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.view addConstraint:self.typingIndicatorViewBottomConstraint];
}

- (void)configureAddressbarLayoutConstraints
{
    // Address Bar
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
}

#pragma mark - Notification Registration 

- (void)atl_baseRegisterForNotifications
{
    // Keyboard Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // ATLMessageInputToolbar Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:self.messageInputToolbar.textInputView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageInputToolbarDidChangeHeight:) name:ATLMessageInputToolbarDidChangeHeightNotification object:self.messageInputToolbar];
}

@end
