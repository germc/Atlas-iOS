//
//  LYRUIMessageBubbleView.m
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

#import "LYRUIMessageBubbleView.h"
#import "LYRUIMessagingUtilities.h"

CGFloat const LYRUIMessageBubbleLabelHorizontalPadding = 14;
CGFloat const LYRUIMessageBubbleLabelVerticalPadding = 10;
CGFloat const LYRUIMessageBubbleMapWidth = 200;
CGFloat const LYRUIMessageBubbleMapHeight = 200;
CGFloat const LYRUIMessageBubbleDefaultHeight = 40;

NSString *const LYRUIUserDidTapLinkNotification = @"LYRUIUserDidTapLinkNotification";

typedef NS_ENUM(NSInteger, LYRUIBubbleViewContentType) {
    LYRUIBubbleViewContentTypeText,
    LYRUIBubbleViewContentTypeImage,
    LYRUIBubbleViewContentTypeLocation,
};

@interface LYRUIMessageBubbleView () <UIGestureRecognizerDelegate>

@property (nonatomic) LYRUIBubbleViewContentType contentType;
@property (nonatomic) UIView *longPressMask;
@property (nonatomic) CLLocationCoordinate2D locationShown;
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) NSURL *tappedURL;
@property (nonatomic) NSLayoutConstraint *imageWidthConstraint;
@property (nonatomic) MKMapSnapshotter *snapshotter;

@end

@implementation LYRUIMessageBubbleView 

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
        
        self.bubbleViewLabel = [[UILabel alloc] init];
        self.bubbleViewLabel.numberOfLines = 0;
        self.bubbleViewLabel.userInteractionEnabled = YES;
        self.bubbleViewLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.bubbleViewLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:self.bubbleViewLabel];

        self.bubbleImageView = [[UIImageView alloc] init];
        self.bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.bubbleImageView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:LYRUIMessageBubbleLabelVerticalPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:LYRUIMessageBubbleLabelHorizontalPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-LYRUIMessageBubbleLabelHorizontalPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-LYRUIMessageBubbleLabelVerticalPadding]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        self.imageWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0];
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLabelTap:)];
        self.tapGestureRecognizer.delegate = self;
        [self.bubbleViewLabel addGestureRecognizer:self.tapGestureRecognizer];
        
        UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

- (void)prepareForReuse
{
    self.bubbleImageView.image = nil;
    [self applyImageWidthConstraint:NO];
    [self setBubbleViewContentType:LYRUIBubbleViewContentTypeText];
}

- (void)updateWithAttributedText:(NSAttributedString *)text
{
    self.bubbleViewLabel.attributedText = text;
    [self applyImageWidthConstraint:NO];
    [self setBubbleViewContentType:LYRUIBubbleViewContentTypeText];
}

- (void)updateWithImage:(UIImage *)image width:(CGFloat)width
{
    self.bubbleImageView.image = image;
    self.imageWidthConstraint.constant = width;
    [self applyImageWidthConstraint:YES];
    [self setBubbleViewContentType:LYRUIBubbleViewContentTypeImage];
}

- (void)updateWithLocation:(CLLocationCoordinate2D)location
{
    self.imageWidthConstraint.constant = LYRUIMaxCellWidth();
    [self applyImageWidthConstraint:YES];
    [self setBubbleViewContentType:LYRUIBubbleViewContentTypeLocation];
    [self setNeedsUpdateConstraints];

    NSString *cachedImageIdentifier = [NSString stringWithFormat:@"%f,%f", location.latitude, location.longitude];
    UIImage *cachedImage = [[[self class] sharedCache] objectForKey:cachedImageIdentifier];
    if (cachedImage) {
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
        self.bubbleImageView.image = LYRUIPinPhotoForSnapshot(snapshot, location);
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

- (void)setBubbleViewContentType:(LYRUIBubbleViewContentType)contentType
{
    _contentType = contentType;
    switch (contentType) {
        case LYRUIBubbleViewContentTypeText:
            self.bubbleImageView.hidden = YES;
            self.bubbleViewLabel.hidden = NO;
            self.bubbleImageView.image = nil;
            self.locationShown = kCLLocationCoordinate2DInvalid;
            break;
            
        case LYRUIBubbleViewContentTypeImage:
            self.bubbleViewLabel.hidden = YES;
            self.bubbleImageView.hidden = NO;
            self.locationShown = kCLLocationCoordinate2DInvalid;
            self.bubbleViewLabel.text = nil;
            break;
            
        case LYRUIBubbleViewContentTypeLocation:
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

#pragma mark - Copy / Paste Support

- (void)copyItem
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (!self.bubbleViewLabel.isHidden) {
        pasteboard.string = self.bubbleViewLabel.text;
    } else {
        pasteboard.image = self.bubbleImageView.image;
    }
}

- (void)menuControllerDisappeared
{
    [self.longPressMask removeFromSuperview];
    self.longPressMask = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Gesture Recognizer Handlers

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(menuControllerDisappeared)
                                                     name:UIMenuControllerDidHideMenuNotification
                                                   object:nil];
        
        [self becomeFirstResponder];
        
        self.longPressMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.longPressMask.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.longPressMask.backgroundColor = [UIColor blackColor];
        self.longPressMask.alpha = 0.1;
        [self addSubview:self.longPressMask];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyItem)];
        [menuController setMenuItems:@[resetMenuItem]];
        [menuController setTargetRect:CGRectMake(self.frame.size.width / 2, 0.0f, 0.0f, 0.0f) inView:self];
        [menuController setMenuVisible:YES animated:YES];
    }
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
    NSArray *results = LYRUILinkResultsForText(self.bubbleViewLabel.attributedText.string);
    for (NSTextCheckingResult *result in results) {
        if (NSLocationInRange(characterIndex, result.range)) {
            self.tappedURL = result.URL;
            return YES;
        }
    }
    return NO;
}

#pragma mark - Actions

- (void)handleLabelTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LYRUIUserDidTapLinkNotification object:self.tappedURL];
    self.tappedURL = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
