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

- (id)initWithKey:(NSString *)key
{
    self = [super init];
    if (self) {
        self.backgroundColor = LYRUILightGrayColor();
        
        self.keyLabel = [[UILabel alloc] init];
        self.keyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.keyLabel.font = [UIFont boldSystemFontOfSize:14];
        self.keyLabel.text = key;
        self.keyLabel.textColor = [UIColor blackColor];
        [self.keyLabel sizeToFit];
        [self addSubview:self.keyLabel];
        
        [self updateConstraints];
    }
    return self;
}

- (void)updateConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.keyLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.keyLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20]];
    [super updateConstraints];
}

@end
