//
//  LYRUIAddressBarView.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 10/30/14.
//
//

#import "LYRUIAddressBarView.h"
#import "LYRUIConstants.h"

@interface LYRUIAddressBarView ()

@property (nonatomic) UIView *bottomBorder;

@end

@implementation LYRUIAddressBarView

- (id)init
{
    self = [super init];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (void)lyr_commonInit
{
    self.addressBarTextView = [[LYRUIAddressBarTextView alloc] init];
    self.addressBarTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.addressBarTextView.translatesAutoresizingMaskIntoConstraints = NO;
    self.addressBarTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.addressBarTextView sizeToFit];
    [self addSubview:self.addressBarTextView];
    
    self.addContactsButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    self.addContactsButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.addContactsButton.tintColor = LYRUIBlueColor();
    [self addSubview:self.addContactsButton];
    
    self.bottomBorder = [[UIView alloc] init];
    self.bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomBorder.backgroundColor = LYRUIGrayColor();
    [self addSubview:self.bottomBorder];
    
    [self configureAddressBarTextViewConstrants];
    [self configureAddContactsButtonConstraints];
    [self configureBottomBorderConstraints];
}

- (void)configureAddressBarTextViewConstrants
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarTextView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-40]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];

}

- (void)configureAddContactsButtonConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addContactsButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.addressBarTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:8]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addContactsButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:6]];
}

- (void)configureBottomBorderConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-0.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBorder attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
}

@end
