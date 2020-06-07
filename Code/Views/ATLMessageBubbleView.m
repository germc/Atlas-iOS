//
//  ATLUIMessageBubbleView.m
//  Atlas
//
//  Created by Kevin Coleman on 9/8/14.
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

#import "ATLMessageBubbleView.h"
#import "ATLMessagingUtilities.h"
#import "ATLPlayView.h"

CGFloat const ATLMessageBubbleLabelVerticalPadding = 8.0f;
CGFloat const ATLMessageBubbleLabelHorizontalPadding = 13.0f;

CGFloat const ATLMessageBubbleMapWidth = 200.0f;
CGFloat const ATLMessageBubbleMapHeight = 200.0f;
CGFloat const ATLMessageBubbleDefaultHeight = 40.0f;

NSString *const ATLUserDidTapLinkNotification = @"ATLUserDidTapLinkNotification";
NSString *const ATLUserDidTapPhoneNumberNotification = @"ATLUserDidTapPhoneNumberNotification";

typedef NS_ENUM(NSInteger, ATLBubbleViewContentType) {
    ATLBubbleViewContentTypeText,
    ATLBubbleViewContentTypeImage,
    ATLBubbleViewContentTypeVideo,
    ATLBubbleViewContentTypeLocation,
};

@interface ATLMessageBubbleView () <UIGestureRecognizerDelegate>

@property (nonatomic) ATLBubbleViewContentType contentType;
@property (nonatomic) UIView *longPressMask;
@property (nonatomic) NSString *tappedPhoneNumber;
@property (nonatomic) CLLocationCoordinate2D locationShown;
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic) NSURL *tappedURL;
@property (nonatomic) NSLayoutConstraint *imageWidthConstraint;
@property (nonatomic) MKMapSnapshotter *snapshotter;
@property (nonatomic) ATLProgressView *progressView;
@property (nonatomic) ATLPlayView *playView;

@end

@implementation ATLMessageBubbleView

+ (NSCache *)sharedCache
{
    static NSCache *_sharedCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCache = [NSCache new];
    });
    return _sharedCache;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _locationShown = kCLLocationCoordinate2DInvalid;
        self.clipsToBounds = YES;
        
        _bubbleViewLabel = [[UILabel alloc] init];
        _bubbleViewLabel.numberOfLines = 0;
        _bubbleViewLabel.userInteractionEnabled = YES;
        _bubbleViewLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_bubbleViewLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_bubbleViewLabel];
        
        _textCheckingTypes = NSTextCheckingTypeLink;
        
        _bubbleImageView = [[UIImageView alloc] init];
        _bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_bubbleImageView];
        
        _playView = [[ATLPlayView alloc]initWithFrame:CGRectMake(0,0, 128.0f, 128.0f)];
        _playView.translatesAutoresizingMaskIntoConstraints = NO;
        _playView.backgroundColor = [UIColor clearColor];
        _playView.hidden = YES;
        [self addSubview:_playView];
        
        _progressView = [[ATLProgressView alloc] initWithFrame:CGRectMake(0, 0, 128.0f, 128.0f)];
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
        _progressView.alpha = 1.0f;
        [self addSubview:_progressView];
        
        [self configureBubbleViewLabelConstraints];
        [self configureBubbleImageViewConstraints];
        [self configureProgressViewConstraints];
        [self configurePlayViewConstraints];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLabelTap:)];
        _tapGestureRecognizer.delegate = self;
        [self.bubbleViewLabel addGestureRecognizer:_tapGestureRecognizer];
        
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_panGestureRecognizer];
        
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        _longPressGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_longPressGestureRecognizer];
        
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyItem)];
        _menuControllerActions = @[resetMenuItem];
        
        [self prepareForReuse];
    }
    return self;
}

- (void)updateProgressIndicatorWithProgress:(float)progress visible:(BOOL)visible animated:(BOOL)animated
{
    [self.progressView setProgress:progress animated:animated];
    [UIView animateWithDuration:animated ? 0.25f : 0.0f animations:^{
        self.progressView.alpha = visible ? 1.0f : 0.0f;
    }];
}

- (void)prepareForReuse
{
    self.bubbleImageView.image = nil;
    [self applyImageWidthConstraint:NO];
    self.playView.hidden = YES;
    [self setBubbleViewContentType:ATLBubbleViewContentTypeText];
}

- (void)updateWithAttributedText:(NSAttributedString *)text
{
    self.bubbleViewLabel.attributedText = text;
    [self applyImageWidthConstraint:NO];
    [self setBubbleViewContentType:ATLBubbleViewContentTypeText];
}

- (void)updateWithImage:(UIImage *)image width:(CGFloat)width
{
    self.bubbleImageView.image = image;
    self.imageWidthConstraint.constant = width;
    [self applyImageWidthConstraint:YES];
    [self setBubbleViewContentType:ATLBubbleViewContentTypeImage];
}

- (void)updateWithVideoThumbnail:(UIImage *)image width:(CGFloat)width
{
    self.bubbleImageView.image = image;
    self.imageWidthConstraint.constant = width;
    self.playView.hidden = NO;
    [self applyImageWidthConstraint:YES];
    [self setBubbleViewContentType:ATLBubbleViewContentTypeVideo];
}

- (void)updateWithLocation:(CLLocationCoordinate2D)location
{
    self.imageWidthConstraint.constant = ATLMaxCellWidth();
    [self applyImageWidthConstraint:YES];
    [self setBubbleViewContentType:ATLBubbleViewContentTypeLocation];
    [self setNeedsUpdateConstraints];
    
    NSString *cachedImageIdentifier = [NSString stringWithFormat:@"%f,%f", location.latitude, location.longitude];
    UIImage *cachedImage = [[[self class] sharedCache] objectForKey:cachedImageIdentifier];
    if (cachedImage) {
        self.locationShown = location;
        self.bubbleImageView.image = cachedImage;
        self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.bubbleImageView.hidden = NO;
        return;
    }
    
    self.snapshotter = [self snapshotterForLocation:location];
    [self.snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        self.bubbleImageView.hidden = NO;
        if (error) {
            self.bubbleImageView.image = [UIImage imageNamed:@"LayerUIKitResource.bundle/warning-black"];
            self.bubbleImageView.contentMode = UIViewContentModeCenter;
            return;
        }
        self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.bubbleImageView.image = ATLPinPhotoForSnapshot(snapshot, location);
        self.locationShown = location;
        [[[self class] sharedCache] setObject:self.bubbleImageView.image forKey:cachedImageIdentifier];
        
        // Animate into view.
        self.bubbleImageView.alpha = 0.0;
        [UIView animateWithDuration:0.2 animations:^{
            self.bubbleImageView.alpha = 1.0;
        }];
    }];
}

- (MKMapSnapshotter *)snapshotterForLocation:(CLLocationCoordinate2D)location
{
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    options.region = MKCoordinateRegionMake(location, span);
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(200, 200);
    return  [[MKMapSnapshotter alloc] initWithOptions:options];
}

- (void)setBubbleViewContentType:(ATLBubbleViewContentType)contentType
{
    _contentType = contentType;
    switch (contentType) {
        case ATLBubbleViewContentTypeText:
            self.bubbleImageView.hidden = YES;
            self.bubbleViewLabel.hidden = NO;
            self.bubbleImageView.image = nil;
            self.locationShown = kCLLocationCoordinate2DInvalid;
            break;
            
        case ATLBubbleViewContentTypeImage:
            self.bubbleViewLabel.hidden = YES;
            self.bubbleImageView.hidden = NO;
            self.locationShown = kCLLocationCoordinate2DInvalid;
            self.bubbleViewLabel.text = nil;
            break;
            
        case ATLBubbleViewContentTypeVideo:
            self.bubbleViewLabel.hidden = YES;
            self.bubbleImageView.hidden = NO;
            self.locationShown = kCLLocationCoordinate2DInvalid;
            self.bubbleViewLabel.text = nil;
            break;
            
        case ATLBubbleViewContentTypeLocation:
            self.locationShown = kCLLocationCoordinate2DInvalid;
            self.bubbleImageView.hidden = YES;
            self.bubbleImageView.image = nil;
            self.bubbleViewLabel.hidden = YES;
            self.bubbleViewLabel.text = nil;
            break;
            
        default:
            break;
    }
    [self.snapshotter cancel];
    [self setNeedsUpdateConstraints];
}

- (void)applyImageWidthConstraint:(BOOL)applyImageWidthConstraint
{
    if (applyImageWidthConstraint) {
        if (![self.constraints containsObject:self.imageWidthConstraint]) {
            [self addConstraint:self.imageWidthConstraint];
        }
    } else {
        if ([self.constraints containsObject:self.imageWidthConstraint]) {
            [self removeConstraint:self.imageWidthConstraint];
        }
    }
}

- (void)setMenuControllerActions:(NSArray *)menuControllerActions
{
    for (id object in menuControllerActions) {
        if (![object isKindOfClass:[UIMenuItem class]]) {
            [NSException raise:NSInternalInconsistencyException format:@"Menu controller actions must be of type UIMenuItem"];
        }
    }
    _menuControllerActions = menuControllerActions;
}

#pragma mark - Copy / Paste Support

- (void)copyItem
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (!self.bubbleViewLabel.isHidden) {
        pasteboard.string = self.bubbleViewLabel.text;
    } else {
        NSData *imageData = UIImagePNGRepresentation(self.bubbleImageView.image);
        [pasteboard setData:imageData forPasteboardType:ATLPasteboardImageKey];
    }
}

- (void)menuControllerDisappeared
{
    [UIView animateWithDuration:0.1 animations:^{
        self.longPressMask.alpha = 0;
    } completion:^(BOOL finished) {
        [self.longPressMask removeFromSuperview];
        self.longPressMask = nil;
    }];
    [[UIMenuController sharedMenuController] setMenuItems:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Gesture Recognizer Handlers

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if ([recognizer state] == UIGestureRecognizerStateBegan && !self.longPressMask) {
        
        if (!self.menuControllerActions || self.menuControllerActions.count == 0) return;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(menuControllerDisappeared)
                                                     name:UIMenuControllerDidHideMenuNotification
                                                   object:nil];
        
        [self becomeFirstResponder];
        
        self.longPressMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.longPressMask.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.longPressMask.backgroundColor = [UIColor blackColor];
        self.longPressMask.alpha = 0;
        [UIView animateWithDuration:0.1 animations:^{
            self.longPressMask.alpha = 0.1;
        }];
        [self addSubview:self.longPressMask];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        [menuController setMenuItems:self.menuControllerActions];
        
        // If we're in a scroll view, we might need to position the UIMenuController differently
        UIView *superview = self.superview;
        while (superview && ![superview isKindOfClass:[UIScrollView class]]) {
            superview = superview.superview;
        }
        if ([superview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *containingScrollView = (UIScrollView *)superview;
            CGPoint contentOffset = containingScrollView.contentOffset;
            CGRect frame = containingScrollView.frame;
            CGRect messageRect = [self convertRect:self.frame toView:superview];
            
            // Top of the message bubble is not appropriate
            CGFloat standardMargin = 8.0f;
            CGFloat topVisibleY = contentOffset.y + containingScrollView.contentInset.top;
            if (messageRect.origin.y <= topVisibleY + standardMargin) {
                // Bottom of the message bubble is not appropriate either
                CGFloat bottomVisibleY = contentOffset.y + frame.size.height - containingScrollView.contentInset.bottom;
                if (messageRect.origin.y + messageRect.size.height >= bottomVisibleY - standardMargin) {
                    // Get midpoint of the visible portion of the message bubble
                    CGFloat middleVisibleY = topVisibleY + (frame.size.height - containingScrollView.contentInset.bottom) / 2 - messageRect.origin.y;
                    [menuController setTargetRect:CGRectMake(self.frame.size.width / 2, middleVisibleY, 0.0f, 0.0f) inView:self];
                    menuController.arrowDirection = UIMenuControllerArrowDefault;
                } else {
                    [menuController setTargetRect:CGRectMake(self.frame.size.width / 2, self.frame.size.height, 0.0f, 0.0f) inView:self];
                    menuController.arrowDirection = UIMenuControllerArrowUp;
                }
            } else {
                [menuController setTargetRect:CGRectMake(self.frame.size.width / 2, 0.0f, 0.0f, 0.0f) inView:self];
                menuController.arrowDirection = UIMenuControllerArrowDefault;
            }
        } else {
            [menuController setTargetRect:CGRectMake(self.frame.size.width / 2, 0.0f, 0.0f, 0.0f) inView:self];
            menuController.arrowDirection = UIMenuControllerArrowDefault;
        }
        self.panGestureRecognizer.enabled = NO;
        [menuController setMenuVisible:YES animated:YES];
    } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
        self.panGestureRecognizer.enabled = YES;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer != self.tapGestureRecognizer) return YES;
    
    //http://stackoverflow.com/questions/21349725/character-index-at-touch-point-for-uilabel/26806991#26806991
    UILabel *textLabel = self.bubbleViewLabel;
    CGPoint tapLocation = [gestureRecognizer locationInView:textLabel];
    
    // init text storage
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:textLabel.attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    
    // init text container
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:textLabel.frame.size];
    textContainer.lineFragmentPadding = 0;
    textContainer.maximumNumberOfLines = textLabel.numberOfLines;
    textContainer.lineBreakMode = textLabel.lineBreakMode;
    [layoutManager addTextContainer:textContainer];
    
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:tapLocation
                                                      inTextContainer:textContainer
                             fractionOfDistanceBetweenInsertionPoints:NULL];
    NSArray *results = ATLTextCheckingResultsForText(self.bubbleViewLabel.attributedText.string, self.textCheckingTypes);
    for (NSTextCheckingResult *result in results) {
        if (NSLocationInRange(characterIndex, result.range)) {
            if (result.resultType == NSTextCheckingTypeLink && self.textCheckingTypes & NSTextCheckingTypeLink) {
                self.tappedURL = result.URL;
                return YES;
            } else if (result.resultType == NSTextCheckingTypePhoneNumber && self.textCheckingTypes & NSTextCheckingTypePhoneNumber) {
                self.tappedPhoneNumber = result.phoneNumber;
                return YES;
            }
            self.tappedURL = result.URL;
            return YES;
        }
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer || otherGestureRecognizer == self.panGestureRecognizer) {
        return YES;
    }
    if ((gestureRecognizer == self.longPressGestureRecognizer || otherGestureRecognizer == self.longPressGestureRecognizer) && (!self.menuControllerActions || self.menuControllerActions.count == 0)) {
        return YES;
    }
    return NO;
}

#pragma mark - Actions

- (void)handleLabelTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.tappedURL) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ATLUserDidTapLinkNotification object:self.tappedURL];
        self.tappedURL = nil;
    }
    
    if (self.tappedPhoneNumber) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ATLUserDidTapPhoneNumberNotification object:self.tappedPhoneNumber];
        self.tappedURL = nil;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Autolayout

- (void)configureBubbleViewLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleViewLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:ATLMessageBubbleLabelVerticalPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleViewLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:ATLMessageBubbleLabelHorizontalPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleViewLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-ATLMessageBubbleLabelHorizontalPadding]];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:_bubbleViewLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ATLMessageBubbleLabelVerticalPadding];
    bottomConstraint.priority = 800;
    [self addConstraint:bottomConstraint];
}

- (void)configureBubbleImageViewConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bubbleImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    _imageWidthConstraint = [NSLayoutConstraint constraintWithItem:_bubbleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
}

- (void)configureProgressViewConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:64.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:64.0f]];
}

- (void)configurePlayViewConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_playView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_playView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_playView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:64.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_playView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:64.0f]];
}

@end
