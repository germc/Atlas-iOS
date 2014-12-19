//
//  LYRUIParticipantSectionHeaderView.m
//  Pods
//
//  Created by Kevin Coleman on 8/31/14.
//
//

#import "LYRUIParticipantSectionHeaderView.h"
#import "LYRUIConstants.h"

@interface LYRUIParticipantSectionHeaderView ()

@property (nonatomic) UIView *bottomBar;

@end

@implementation LYRUIParticipantSectionHeaderView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = LYRUILightGrayColor();
        
        self.keyLabel = [[UILabel alloc] init];
        self.keyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.keyLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.contentView addSubview:self.keyLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.keyLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.keyLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20]];
        NSLayoutConstraint *labelRightConstraint = [NSLayoutConstraint constraintWithItem:self.keyLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];
        // To work around an apparent system bug that initially requires the content view to have zero width, instead of a required priority, we use a priority one higher than the label's content compression resistance.
        labelRightConstraint.priority = UILayoutPriorityDefaultHigh + 1;
        [self addConstraint:labelRightConstraint];
    }
    return self;
}

@end
