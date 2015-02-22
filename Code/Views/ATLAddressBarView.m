//
//  ATLUIAddressBarView.m
//  Atlas
//
//  Created by Kevin Coleman on 10/30/14.
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
#import "ATLAddressBarView.h"
#import "ATLConstants.h"

@interface ATLAddressBarView ()

@property (nonatomic) UIView *bottomBorder;
@property (nonatomic) NSLayoutConstraint *textViewRightConstraint;
@property (nonatomic) NSLayoutConstraint *addContactsButtonTopConstraint;
@property (nonatomic) CGFloat addContactsButtonTopConstant;

@end

@implementation ATLAddressBarView

CGFloat const ATLAddressBarTextViewPadding = 4;
CGFloat const ATLAddContactButtonRightPadding = -8;
NSString *const ATLAddContactsButtonAccessibilityLabel = @"Add Contacts Button";

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
    _addressBarTextView = [[ATLAddressBarTextView alloc] init];
    _addressBarTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _addressBarTextView.translatesAutoresizingMaskIntoConstraints = NO;
    _addressBarTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    [_addressBarTextView sizeToFit];
    [self addSubview:_addressBarTextView];
    
    _addContactsButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    _addContactsButton.translatesAutoresizingMaskIntoConstraints = NO;
    _addContactsButton.accessibilityLabel = ATLAddContactsButtonAccessibilityLabel;
    _addContactsButton.tintColor = ATLBlueColor();
    [self addSubview:_addContactsButton];
    
    _bottomBorder = [[UIView alloc] init];
    _bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomBorder.backgroundColor = ATLGrayColor();
    [self addSubview:_bottomBorder];
    
    [self configureAddressBarTextViewConstrants];
    [self configureAddContactsButtonConstraints];
    [self configureBottomBorderConstraints];
}

- (void)configureAddressBarTextViewConstrants
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_addressBarTextView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_addressBarTextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:ATLAddressBarTextViewPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_addressBarTextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ATLAddressBarTextViewPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_addressBarTextView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_addContactsButton attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
}

- (void)configureAddContactsButtonConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_addContactsButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:ATLAddContactButtonRightPadding]];
    self.addContactsButtonTopConstraint = [NSLayoutConstraint constraintWithItem:_addContactsButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    self.addContactsButtonTopConstraint.priority = UILayoutPriorityRequired;
    [self addConstraint:self.addContactsButtonTopConstraint];
}

- (void)configureBottomBorderConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBorder attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBorder attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-0.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBorder attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.5]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_bottomBorder attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
}

- (void)layoutSubviews
{
    if (!self.addContactsButtonTopConstant && self.frame.size.height) {
        // We calculate top constant here to accomodate for variable font support.
        self.addContactsButtonTopConstant = (self.frame.size.height / 2) - (self.addContactsButton.frame.size.height / 2);
        self.addContactsButtonTopConstraint.constant = self.addContactsButtonTopConstant;
    }
    [super layoutSubviews];
}

@end
