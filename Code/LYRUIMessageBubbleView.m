//
//  LRYUIMessageBubbleVIew.m
//  Pods
//
//  Created by Kevin Coleman on 9/8/14.
//
//

#import "LYRUIMessageBubbleView.h"

@interface LYRUIMessageBubbleView ()

@property (nonatomic) NSLayoutConstraint *contentWidthConstraint;
@property (nonatomic) NSLayoutConstraint *contentHeightConstraint;
@property (nonatomic) NSLayoutConstraint *contentCenterXConstraint;
@property (nonatomic) NSLayoutConstraint *contentCenterYConstraint;

@property (nonatomic) UIView *longPressMask;
@property (nonatomic) MKMapSnapshotter *snapshotter;

@end

@implementation LYRUIMessageBubbleView 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 12;
        self.clipsToBounds = YES;

        self.bubbleViewLabel = [[UILabel alloc] init];
        self.bubbleViewLabel.numberOfLines = 0;
        self.bubbleViewLabel.textColor = [UIColor greenColor];
        self.bubbleViewLabel.userInteractionEnabled = YES;
        self.bubbleViewLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.bubbleViewLabel];

        self.bubbleImageView = [[UIImageView alloc] init];
        self.bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.bubbleImageView];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:12]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-12]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

        UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

- (void)updateWithText:(NSString *)text
{
    self.bubbleImageView.alpha = 0.0;
    self.bubbleViewLabel.alpha = 1.0;
    self.bubbleViewLabel.text = text;
    [self.snapshotter cancel];
}

- (void)updateWithImage:(UIImage *)image
{
    self.bubbleViewLabel.alpha = 0.0;
    self.bubbleImageView.alpha = 1.0;
    self.bubbleImageView.image = image;
    [self.snapshotter cancel];
}

- (void)updateWithLocation:(CLLocationCoordinate2D)location
{
    self.bubbleViewLabel.alpha = 0.0;
    self.bubbleImageView.alpha = 0.0;
    [self.snapshotter cancel];
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    options.region = MKCoordinateRegionMake(location, span);
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(200, 200);
    self.snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];

    __weak typeof(self) weakSelf = self;
    [self.snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        if (error) {
            NSLog(@"Error generating map snapshot: %@", error);
            return;
        }

        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        
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
        self.longPressMask.backgroundColor = [UIColor blackColor];
        self.longPressMask.alpha = 0.1;
        [self addSubview:self.longPressMask];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copyItem)];
        [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
        [menuController setTargetRect:CGRectMake(self.frame.size.width / 2, 0.0f, 0.0f, 0.0f) inView:[recognizer view]];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (void)copyItem
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.bubbleViewLabel.alpha == 1.0f) {
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



@end
