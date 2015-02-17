//
//  ATLUIParticipantSectionHeaderView.m
//  Atlas
//
//  Created by Kevin Coleman on 8/31/14.
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

#import "ATLParticipantSectionHeaderView.h"
#import "ATLConstants.h"

@implementation ATLParticipantSectionHeaderView

NSString *const ATLParticipantSectionHeaderViewAccessibilityLabel = @"Section Header View";

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}
         
- (void)lyr_commonInit
{
    self.contentView.backgroundColor = ATLLightGrayColor();
    
    self.sectionHeaderLabel = [[UILabel alloc] init];
    self.sectionHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.sectionHeaderLabel.font = [UIFont boldSystemFontOfSize:16];
    self.sectionHeaderLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.sectionHeaderLabel];
    [self configureHeaderLabelConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.accessibilityLabel = [NSString stringWithFormat:@"%@ - %@", ATLParticipantSectionHeaderViewAccessibilityLabel, self.sectionHeaderLabel.text];
}

- (void)setSectionHeaderTextColor:(UIColor *)sectionLabelColor
{
    self.sectionHeaderLabel.textColor = sectionLabelColor;
}

- (UIColor *)sectionHeaderTextColor
{
    return self.sectionHeaderLabel.textColor;
}

- (void)setSectionHeaderFont:(UIFont *)sectionLabelFont
{
    self.sectionHeaderLabel.font = sectionLabelFont;
}

- (UIFont *)sectionHeaderFont
{
    return self.sectionHeaderLabel.font;
}

- (void)setSectionHeaderBackgroundColor:(UIColor *)sectionHeaderBackgroundColor
{
    self.contentView.backgroundColor = sectionHeaderBackgroundColor;
}

- (UIColor *)sectionHeaderBackgroundColor
{
    return self.contentView.backgroundColor;
}

- (void)configureHeaderLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sectionHeaderLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sectionHeaderLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20]];
    NSLayoutConstraint *labelRightConstraint = [NSLayoutConstraint constraintWithItem:self.sectionHeaderLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];
    // To work around an apparent system bug that initially requires the content view to have zero width, instead of a required priority, we use a priority one higher than the label's content compression resistance.
    labelRightConstraint.priority = UILayoutPriorityDefaultHigh + 1;
    [self addConstraint:labelRightConstraint];
}
@end
