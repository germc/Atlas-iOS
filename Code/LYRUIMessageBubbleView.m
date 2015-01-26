//
//  LRYUIMessageBubbleView.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 9/8/14.
//
//

#import "LYRUIMessageBubbleView.h"
#import "LYRUIMessagingUtilities.h"

CGFloat const LYRUIMessageBubbleLabelHorizontalPadding = 12;
CGFloat const LYRUIMessageBubbleLabelVerticalPadding = 8;
CGFloat const LYRUIMessageBubbleMapWidth = 200;
CGFloat const LYRUIMessageBubbleMapHeight = 200;

NSString *const LYRUIUserDidTapLinkNotification = @"LYRUIUserDidTapLinkNotification";

@interface LYRUIMessageBubbleView ()

@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic) UIView *longPressMask;
@property (nonatomic) MKMapSnapshotter *snapshotter;
@property (nonatomic) CLLocationCoordinate2D locationShown;

@property (nonatomic) NSLayoutConstraint *mapWidthConstraint;
@property (nonatomic) NSLayoutConstraint *imageWidthConstraint;
@property (nonatomic) UIImageView *snapshotErrorIconView;

@end

@implementation LYRUIMessageBubbleView 

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

        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.activityIndicator.color = [UIColor grayColor];
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.activityIndicator];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:LYRUIMessageBubbleLabelVerticalPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:LYRUIMessageBubbleLabelHorizontalPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-LYRUIMessageBubbleLabelHorizontalPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-LYRUIMessageBubbleLabelVerticalPadding]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

        self.mapWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:LYRUIMessageBubbleMapWidth];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLabelTap:)];
        [self.bubbleViewLabel addGestureRecognizer:tapGestureRecognizer];
        
        UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

- (void)displayDownloadActivityIndicator
{
    self.activityIndicator.hidden = NO;
    self.bubbleImageView.hidden = YES;
    self.bubbleViewLabel.hidden = YES;
    [self.activityIndicator startAnimating];
}

- (void)updateWithAttributedText:(NSAttributedString *)text
{
    self.activityIndicator.hidden = YES;
    self.bubbleImageView.hidden = YES;
    self.bubbleViewLabel.hidden = NO;

    self.bubbleViewLabel.attributedText = text;
    self.bubbleImageView.image = nil;
    self.locationShown = kCLLocationCoordinate2DInvalid;
    [self.snapshotter cancel];

    [self removeConstraint:self.mapWidthConstraint];
    [self removeConstraint:self.imageWidthConstraint];
    [self setNeedsUpdateConstraints];
}

- (void)updateWithImage:(UIImage *)image
{
    self.activityIndicator.hidden = YES;
    self.bubbleViewLabel.hidden = YES;
    self.bubbleImageView.hidden = NO;
    self.bubbleImageView.image = image;
    self.locationShown = kCLLocationCoordinate2DInvalid;
    self.bubbleViewLabel.text = nil;
    [self.snapshotter cancel];

    [self removeConstraint:self.mapWidthConstraint];
    [self removeConstraint:self.imageWidthConstraint];

    CGFloat imageAspectRatio = image.size.width/image.size.height;
    self.imageWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.bubbleImageView attribute:NSLayoutAttributeHeight multiplier:imageAspectRatio constant:0];
    // When the cell is being reused and configured again, it might temporarily still be the size for its prior content. So we need a less than required priority.
    self.imageWidthConstraint.priority = UILayoutPriorityDefaultHigh;
    [self addConstraint:self.imageWidthConstraint];
    [self setNeedsUpdateConstraints];
}

- (void)updateWithLocation:(CLLocationCoordinate2D)location
{
    self.activityIndicator.hidden = YES;
    self.bubbleViewLabel.hidden = YES;
    self.bubbleViewLabel.text = nil;
    [self.snapshotter cancel];

    [self removeConstraint:self.imageWidthConstraint];
    [self addConstraint:self.mapWidthConstraint];
    [self setNeedsUpdateConstraints];
    
    BOOL alreadyShowingLocation = self.locationShown.latitude == location.latitude && self.locationShown.longitude == location.longitude;
    if (alreadyShowingLocation) {
        self.bubbleImageView.hidden = NO;
        return;
    }

    self.bubbleImageView.hidden = YES;
    self.bubbleImageView.image = nil;
    self.locationShown = kCLLocationCoordinate2DInvalid;

    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    options.region = MKCoordinateRegionMake(location, span);
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(200, 200);
    self.snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];

    __weak typeof(self) weakSelf = self;
    [self.snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        strongSelf.bubbleImageView.hidden = NO;
        strongSelf.bubbleImageView.alpha = 0.0;
        
        if (error) {
            NSLog(@"Error generating map snapshot: %@", error);
            self.snapshotErrorIconView.center = weakSelf.bubbleImageView.center;
            [weakSelf.bubbleImageView addSubview:self.snapshotErrorIconView];
        } else {
            if ([self.bubbleImageView.subviews containsObject:self.snapshotErrorIconView]) [self.snapshotErrorIconView removeFromSuperview];
            
            // Create a pin image.
            MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
            UIImage *pinImage = pin.image;
            
            // Draw the image.
            UIImage *image = snapshot.image;
            UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
            [image drawAtPoint:CGPointMake(0, 0)];
            
            // Draw the pin.
            CGPoint point = [snapshot pointForCoordinate:location];
            [pinImage drawAtPoint:CGPointMake(point.x, point.y - pinImage.size.height)];
            UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // Set image.
            strongSelf.bubbleImageView.image = finalImage;
            strongSelf.locationShown = location;
        }

        // Animate into view.
        [UIView animateWithDuration:0.2 animations:^{
            strongSelf.bubbleImageView.alpha = 1.0;
        }];
    }];
}

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleLabelTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    //http://stackoverflow.com/questions/21349725/character-index-at-touch-point-for-uilabel/26806991#26806991
    UILabel *textLabel = (UILabel *)tapGestureRecognizer.view;
    CGPoint tapLocation = [tapGestureRecognizer locationInView:textLabel];
    
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
            [[NSNotificationCenter defaultCenter] postNotificationName:LYRUIUserDidTapLinkNotification object:result.URL];
            break;
        }
    }
}

- (UIImageView *)snapshotErrorIconView
{
    if (!_snapshotErrorIconView) {
        _snapshotErrorIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LayerUIKitResource.bundle/warning-black"]];
    }
    return _snapshotErrorIconView;
}

@end
