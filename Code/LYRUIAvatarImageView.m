//
//  LYRUIAvatarImageView.m
//  Pods
//
//  Created by Kevin Coleman on 10/22/14.
//
//

#import "LYRUIAvatarImageView.h"

@interface LYRUIAvatarImageView ()

@property (nonatomic) UILabel *initialsLabel;

@end

@implementation LYRUIAvatarImageView

- (id)init
{
    self = [super init];
    if (self) {
        _initialsLabel = [[UILabel alloc] init];
        _initialsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _initialsLabel.textAlignment = NSTextAlignmentCenter;
        _initialsLabel.adjustsFontSizeToFitWidth = YES;
        _initialsLabel.minimumScaleFactor = 0.75;
        [self addSubview:_initialsLabel];
    
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:3]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-3]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:3]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3]];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(30, 30);
}

- (void)setInitialsForName:(NSString *)name
{
    if (name) {
        NSMutableString *initials = [NSMutableString new];
        NSArray *names = [name componentsSeparatedByString:@" "];
        for (NSString *name in names) {
            if (name.length > 0) {
                [initials appendString:[name substringToIndex:1]];
            }
        }
        self.initialsLabel.text = initials;
    }
}

- (void)setInitialColor:(UIColor *)initialColor
{
    self.initialsLabel.textColor = initialColor;
    _initialColor = initialColor;
}

- (void)setInitialFont:(UIFont *)initialFont
{
    self.initialsLabel.font = initialFont;
    _initialFont = initialFont;
}

@end
