//
//  LRYUIMessageBubbleVIew.m
//  Pods
//
//  Created by Kevin Coleman on 9/8/14.
//
//

#import "LYRUIMessageBubbleView.h"
#import "LYRUIIncomingMessageCollectionViewCell.h"
#import "LYRUIOutgoingMessageCollectionViewCell.h"

@interface LYRUIMessageBubbleView () <TTTAttributedLabelDelegate>

@property (nonatomic) NSLayoutConstraint *contentWidthConstraint;
@property (nonatomic) NSLayoutConstraint *contentHeightConstraint;
@property (nonatomic) NSLayoutConstraint *contentCenterXConstraint;
@property (nonatomic) NSLayoutConstraint *contentCenterYConstraint;

@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *color;

@end

@implementation LYRUIMessageBubbleView {
    BOOL _isInitializing;
}

- (id)initWithFrame:(CGRect)frame
{
    _isInitializing = YES;
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 12;
        self.clipsToBounds = TRUE;
        
        self.bubbleViewLabel = [[TTTAttributedLabel alloc] init];
        self.bubbleViewLabel.backgroundColor = [UIColor clearColor];
        self.bubbleViewLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.bubbleViewLabel.numberOfLines = 0;
        self.bubbleViewLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        self.bubbleViewLabel.delegate = self;
        self.bubbleViewLabel.userInteractionEnabled = YES;
        self.bubbleViewLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.bubbleViewLabel];
        [self updateConstraintsForTextView];
        
        self.bubbleImageView = [[UIImageView alloc] init];
        self.bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.bubbleImageView.layer.cornerRadius = 12;
        self.bubbleImageView.clipsToBounds = TRUE;
        [self addSubview:self.bubbleImageView];
        [self updateConstraintsForImageView];
    }
    _isInitializing = NO;
    return self;
}

- (void)updateWithText:(NSString *)text
{
    self.bubbleImageView.alpha = 0.0;
    self.bubbleViewLabel.alpha = 1.0;
    self.bubbleViewLabel.text = text;
}

- (void)updateWithImage:(UIImage *)image
{
    self.bubbleViewLabel.alpha = 0.0;
    self.bubbleImageView.alpha = 1.0;
    self.bubbleImageView.image = image;
}

- (void)updateWithLocation:(CLLocationCoordinate2D)location
{
    //
}

- (void)updateConstraintsForTextView
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-24]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleViewLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self updateConstraints];
}

- (void)updateConstraintsForImageView
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self updateConstraints];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    
}

@end
