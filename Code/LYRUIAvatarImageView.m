//
//  LYRUIAvatarImageView.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 10/22/14.
//
//

#import "LYRUIAvatarImageView.h"
#import "LYRUIConstants.h"

@interface LYRUIAvatarImageView ()

@property (nonatomic) UILabel *initialsLabel;

@end

@implementation LYRUIAvatarImageView

NSString *const LYRUIAvatarImageViewAccessibilityLabel = @"LYRUIAvatarImageViewAccessibilityLabel";

- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
        
        _initialsFont = [UIFont systemFontOfSize:14];
        _initialsColor = [UIColor blackColor];
        _avatarImageViewDiameter = 30;
        self.layer.cornerRadius = _avatarImageViewDiameter / 2;
        self.accessibilityLabel = LYRUIAvatarImageViewAccessibilityLabel;
        
        _initialsLabel = [[UILabel alloc] init];
        _initialsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _initialsLabel.textAlignment = NSTextAlignmentCenter;
        _initialsLabel.adjustsFontSizeToFitWidth = YES;
        _initialsLabel.minimumScaleFactor = 0.75;
        _initialsLabel.textColor = _initialsColor;
        _initialsLabel.font = _initialsFont;
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
    return CGSizeMake(self.avatarImageViewDiameter, self.avatarImageViewDiameter);
}

- (void)setInitialsForFullName:(NSString *)fullName
{
    if (fullName) {
        NSMutableString *initials = [NSMutableString new];
        NSArray *names = [fullName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        for (NSString *name in names) {
            if (fullName.length > 0) {
                [initials appendString:[fullName substringToIndex:1]];
            }
        }
        self.initialsLabel.text = initials;
    }
}

- (void)setInitialsColor:(UIColor *)initialsColor
{
    self.initialsLabel.textColor = initialsColor;
    _initialsColor = initialsColor;
}

- (void)setInitialsFont:(UIFont *)initialsFont
{
    self.initialsLabel.font = initialsFont;
    _initialsFont = initialsFont;
}

- (void)setAvatarImageViewDiameter:(CGFloat)avatarImageViewDiameter
{
    self.layer.cornerRadius = avatarImageViewDiameter / 2;
    _avatarImageViewDiameter = avatarImageViewDiameter;
    [self invalidateIntrinsicContentSize];
    [self updateConstraintsIfNeeded];
}

@end
