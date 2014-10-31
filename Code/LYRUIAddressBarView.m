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

@end

@implementation LYRUIAddressBarView

- (id)init
{
    self = [super init];
    if (self) {
        
        self.addressBarTextView = [[LYRUIAddressBarTextView alloc] init];
        self.addressBarTextView.translatesAutoresizingMaskIntoConstraints = NO;
        self.addressBarTextView.contentInset = UIEdgeInsetsMake(2, 0, -4, 0);
        self.addressBarTextView.autocorrectionType = UITextAutocorrectionTypeNo;
        [self addSubview:self.addressBarTextView];
        
        self.addContactsButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        self.addContactsButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.addContactsButton];
        
        self.bottomBar = [[UIView alloc] init];
        self.bottomBar.translatesAutoresizingMaskIntoConstraints = NO;
        self.bottomBar.backgroundColor = LSGrayColor();
        [self addSubview:self.bottomBar];
        
        [self updateConstraints];
    }
    
    return self;
}

- (void)updateConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarTextView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:-40]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarTextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addContactsButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.addressBarTextView attribute:NSLayoutAttributeRight multiplier:1.0 constant:8]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.addContactsButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-2]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-0.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.5]];
    
    [super updateConstraints];
}
@end
