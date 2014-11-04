//
//  LYRUIAddressBarView.m
//  Pods
//
//  Created by Kevin Coleman on 10/30/14.
//
//

#import "LYRUIAddressBarView.h"
#import "LYRUIConstants.h"

@interface LYRUIAddressBarView ()

@property (nonatomic) UIView *bottomBar;
@property (nonatomic) NSLayoutConstraint *contactButtonTopOffsetConstraint;

@end

@implementation LYRUIAddressBarView

- (id)init
{
    self = [super init];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        self.addressBarTextView = [[LYRUIAddressBarTextView alloc] init];
        self.addressBarTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.addressBarTextView.translatesAutoresizingMaskIntoConstraints = NO;
        self.addressBarTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        [self.addressBarTextView sizeToFit];
        [self addSubview:self.addressBarTextView];
        
        self.addContactsButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        self.addContactsButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.addContactsButton.tintColor = LSBlueColor();
        [self addSubview:self.addContactsButton];
        
        self.bottomBar = [[UIView alloc] init];
        self.bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
        self.bottomBar.backgroundColor = LSGrayColor();
        [self addSubview:self.bottomBar];
        
        [self updateConstraints];
    }
    
    return self;
}

- (CGSize)intrinsicContentSize
{
    CGFloat currentWidth = self.addressBarTextView.intrinsicContentSize.height;
    CGFloat currentHeight = self.addressBarTextView.intrinsicContentSize.height;
    return CGSizeMake(currentWidth, currentHeight + 20);
}

- (void)updateConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarTextView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-40]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarTextView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addContactsButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.addressBarTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:8]];
    self.contactButtonTopOffsetConstraint = [NSLayoutConstraint constraintWithItem:self.addContactsButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:6];
    [self addConstraint:self.contactButtonTopOffsetConstraint];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-0.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.5]];
    
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}
@end
