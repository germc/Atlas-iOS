//
//  LYRUIMessageInputToolbar.m
//  Pods
//
//  Created by Kevin Coleman on 9/18/14.
//
//

#import "LYRUIMessageInputToolbar.h"
#import "LYRUIConstants.h"
#import "LYRUIMediaAttachment.h"
#import "LYRUIUtilities.h"
#import <CoreLocation/CoreLocation.h>

@interface LYRUIMessageInputToolbar () <UITextViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSLayoutConstraint *textViewHeightConstraint;

@end

@implementation LYRUIMessageInputToolbar

// Compose View Margin Constants
static CGFloat const LSComposeviewHorizontalMargin = 6;
static CGFloat const LSComposeviewVerticalMargin = 6;

// Compose View Button Constants
static CGFloat const LSLeftAccessoryButtonWidth = 40;
static CGFloat const LSRightAccessoryButtonWidth = 46;
static CGFloat const LSButtonHeight = 28;

+ (instancetype)inputToolBarWithViewController:(UIViewController<LYRUIMessageInputToolbarDelegate> *)viewController
{
    return [[self alloc] initWithViewController:viewController];
}

- (id)initWithViewController:(UIViewController<LYRUIMessageInputToolbarDelegate>*)viewController
{
    self = [super init];
    if (self) {
        self.inputToolBarDelegate = viewController;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        // Setup
        self.backgroundColor =  LSLighGrayColor();
        self.messageParts = [[NSMutableArray alloc] init];

        // Initialize the Camera Button
        self.leftAccessoryButton = [[UIButton alloc] init];
        self.leftAccessoryButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.leftAccessoryButton.accessibilityLabel = @"Camera Button";
        self.leftAccessoryButton.layer.cornerRadius = 2;
        [self.leftAccessoryButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [self.leftAccessoryButton addTarget:self action:@selector(leftAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftAccessoryButton];
        
        // Initialize the Text Input View
        self.textInputView = [[LYRUIMessageComposeTextView alloc] init];
        self.textInputView.delegate = self;
        self.textInputView.translatesAutoresizingMaskIntoConstraints = NO;
        self.textInputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.textInputView.layer.borderWidth = 1;
        self.textInputView.layer.cornerRadius = 4.0f;
        self.textInputView.accessibilityLabel = @"Text Input View";
        [self addSubview:self.textInputView];
        
        // Initialize the Send Button
        self.rightAccessoryButton = [[UIButton alloc] init];
        self.rightAccessoryButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.rightAccessoryButton.accessibilityLabel = @"Send Button";
        self.rightAccessoryButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.rightAccessoryButton setTitle:@"SEND" forState:UIControlStateNormal];
        [self.rightAccessoryButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.rightAccessoryButton setTitleColor:LSBlueColor() forState:UIControlStateHighlighted];
        [self.rightAccessoryButton addTarget:self action:@selector(rightAccessoryButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rightAccessoryButton];
        NSLog(@"Right accessory button state %lu", self.rightAccessoryButton.state);
        [self setupLayoutConstraints];
    }
    
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(0, self.textInputView.intrinsicContentSize.height + LSComposeviewVerticalMargin * 2);
}

#pragma mark Public Content Insertion Methods

- (void)insertImage:(UIImage *)image
{
    [self.rightAccessoryButton setHighlighted:TRUE];
    [self.textInputView insertImage:image];
    [self adjustFrame];
}

- (void)insertVideoAtPath:(NSString *)videoPath
{
     @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Method not implemented." userInfo:nil];
}

- (void)insertAudioAtPath:(NSString *)path
{
     @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Method not implemented." userInfo:nil];
}

- (void)insertLocation:(CLLocation *)location
{
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    options.region = MKCoordinateRegionMake(location.coordinate, span);
    options.scale = [UIScreen mainScreen].scale;
    options.size = CGSizeMake(200, 200);
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
        UIImage *image = snapshot.image;
        MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:@""];
        UIImage *pinImage = pin.image;
        CGPoint pinPoint = CGPointMake(image.size.width/2, image.size.height/2);
        UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
        [image drawAtPoint:CGPointMake(0, 0)];
        [pinImage drawAtPoint:pinPoint];
        UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self insertImage:finalImage];
    }];
}

#pragma mark Compose View Delegate Methods

- (void)leftAccessoryButtonTapped
{
    [self.inputToolBarDelegate messageInputToolbar:self didTapLeftAccessoryButton:self.leftAccessoryButton];
}

- (void)rightAccessoryButtonTapped
{
    [self filterMessageParts];
    if (self.textInputView.text.length > 0 || self.messageParts) {
        [self.inputToolBarDelegate messageInputToolbar:self didTapRightAccessoryButton:self.rightAccessoryButton];
        [self.rightAccessoryButton setHighlighted:FALSE];
        [self.textInputView removeAttachements];
        [self.textInputView setText:@""];
        [self.textInputView layoutSubviews];
        [self.messageParts removeAllObjects];
    }
    [self adjustFrame];
}

- (NSArray *)filterMessageParts
{
    NSMutableArray *attachments = [[NSMutableArray alloc] init];
    [self.textInputView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                                   inRange:NSMakeRange(0, self.textInputView.attributedText.length)
                                                   options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                                                usingBlock:^(id value, NSRange range, BOOL *stop) {
                                                    if ([value isKindOfClass:[LYRUIMediaAttachment class]]) {
                                                        [attachments addObject:[(LYRUIMediaAttachment *)value image]];
                                                    }
    }];
     
    NSArray *contentParts = [[self.textInputView.attributedText string] componentsSeparatedByString:@"\n"];
    for (NSString *part in contentParts) {
         NSString *trimmedString = [part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([trimmedString isEqualToString:@"\U0000fffc"]) {
            [self.messageParts addObject:[attachments firstObject]];
            [attachments removeObjectAtIndex:0];
        } else {
            if (trimmedString.length > 0) {
                [self.messageParts addObject:trimmedString];
            }
        }
    }
    return self.messageParts;
}


#pragma mark TextViewDelegate Methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.rightAccessoryButton setHighlighted:FALSE];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self adjustFrame];
    if (textView.text.length > 0) {
        [self.rightAccessoryButton setHighlighted:TRUE];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    return YES;
}

- (void)adjustFrame
{
    [self invalidateIntrinsicContentSize];
    CGSize size = [self systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    self.frame = CGRectMake(0, 0, size.width, size.height);
}

- (void)setupLayoutConstraints
{
    //**********Camera Button Constraints**********//
    // Left Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:LSComposeviewHorizontalMargin]];
    // Width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:LSLeftAccessoryButtonWidth]];

    // Height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:LSButtonHeight]];
    // Bottom Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-LSComposeviewVerticalMargin]];
    
    //**********Text Input View Constraints**********//
    // Left Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.leftAccessoryButton
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:LSComposeviewHorizontalMargin]];
    
    // Right Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.rightAccessoryButton
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:-LSComposeviewHorizontalMargin]];
    // Bottom Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textInputView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:-LSComposeviewVerticalMargin]];
    
    //**********Send Button Constraints**********//
    // Width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSRightAccessoryButtonWidth]];
    
    // Right Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0
                                                      constant:-LSComposeviewVerticalMargin]];
    // Height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0
                                                      constant:LSButtonHeight]];
    // Bottom Margin
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.rightAccessoryButton
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-LSComposeviewVerticalMargin]];
}

- (void)fireUpLoacation
{
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    CLLocation *loaction = [locations lastObject];
    [self insertLocation:loaction];
}

@end
