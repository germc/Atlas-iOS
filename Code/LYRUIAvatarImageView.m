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
        [self addSubview:_initialsLabel];
    }
    return self;
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
        [self.initialsLabel sizeToFit];
    }
}

- (void)updateConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [super updateConstraints];
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

- (void)setInitialViewBackgroundColor:(UIColor *)initialViewBackgroundColor
{
    self.backgroundColor = initialViewBackgroundColor;
    _initialViewBackgroundColor = initialViewBackgroundColor;
}

@end
