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

@interface LYRUIMessageBubbleView ()

@property (nonatomic) NSLayoutConstraint *contentWidthConstraint;
@property (nonatomic) NSLayoutConstraint *contentHeightConstraint;
@property (nonatomic) NSLayoutConstraint *contentCenterXConstraint;
@property (nonatomic) NSLayoutConstraint *contentCenterYConstraint;

@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *color;

@end

@implementation LYRUIMessageBubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 12;
        self.clipsToBounds = TRUE;
        
        self.bubbleTextView = [[UILabel alloc] init];
        self.bubbleTextView.backgroundColor = [UIColor clearColor];
        self.bubbleTextView.numberOfLines = 0;
        self.bubbleTextView.userInteractionEnabled = NO;
        self.bubbleTextView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.bubbleTextView];
        [self updateConstraintsForTextView];
        
        self.bubbleImageView = [[UIImageView alloc] init];
        self.bubbleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.bubbleImageView.layer.cornerRadius = 12;
        self.bubbleImageView.clipsToBounds = TRUE;
        [self addSubview:self.bubbleImageView];
        [self updateConstraintsForImageView];
    }
    return self;
}

- (void)updateWithText:(NSString *)text
{
    self.bubbleImageView.alpha = 0.0;
    self.bubbleTextView.alpha = 1.0;
    self.bubbleTextView.text = text;
}

- (void)updateWithImage:(UIImage *)image
{
    self.bubbleTextView.alpha = 0.0;
    self.bubbleImageView.alpha = 1.0;
    self.bubbleImageView.image = image;
}

- (void)updateWithLocation:(CLLocationCoordinate2D)location
{
    //[self removeSubviews];
}

- (void)updateConstraintsForTextView
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleTextView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-24]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleTextView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleTextView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-12]];
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


@end
