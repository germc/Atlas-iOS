//
//  LYRUIParticipantSectionHeaderView.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 8/31/14.
//
//

#import "LYRUIParticipantSectionHeaderView.h"
#import "LYRUIConstants.h"

@implementation LYRUIParticipantSectionHeaderView

NSString *const LYRUIParticipantSectionHeaderViewAccessibilityLabel = @"Section Header View";

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        _sectionHeaderTextColor = [UIColor blackColor];
        _sectionHeaderFont =  [UIFont boldSystemFontOfSize:14];
        _sectionHeaderBackgroundColor = LYRUILightGrayColor();
        
        self.contentView.backgroundColor = _sectionHeaderBackgroundColor;
        self.sectionHeaderLabel = [[UILabel alloc] init];
        self.sectionHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.sectionHeaderLabel.font = _sectionHeaderFont;
        self.sectionHeaderLabel.textColor = _sectionHeaderTextColor;
        [self.contentView addSubview:self.sectionHeaderLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sectionHeaderLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sectionHeaderLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20]];
        NSLayoutConstraint *labelRightConstraint = [NSLayoutConstraint constraintWithItem:self.sectionHeaderLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];
        // To work around an apparent system bug that initially requires the content view to have zero width, instead of a required priority, we use a priority one higher than the label's content compression resistance.
        labelRightConstraint.priority = UILayoutPriorityDefaultHigh + 1;
        [self addConstraint:labelRightConstraint];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.accessibilityLabel = [NSString stringWithFormat:@"%@ - %@", LYRUIParticipantSectionHeaderViewAccessibilityLabel, self.sectionHeaderLabel.text];
}

- (void)setSectionHeaderTextColor:(UIColor *)sectionLabelColor
{
    _sectionHeaderTextColor = sectionLabelColor;
    self.sectionHeaderLabel.textColor = sectionLabelColor;
}

- (void)setSectionHeaderFont:(UIFont *)sectionLabelFont
{
    _sectionHeaderFont = sectionLabelFont;
    self.sectionHeaderLabel.font = sectionLabelFont;
}

- (void)setSectionHeaderBackgroundColor:(UIColor *)sectionHeaderBackgroundColor
{
    _sectionHeaderBackgroundColor = sectionHeaderBackgroundColor;
    self.contentView.backgroundColor = sectionHeaderBackgroundColor;
}

@end
