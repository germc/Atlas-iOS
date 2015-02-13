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

+ (void)initialize
{
    LYRUIAvatarImageView *proxy = [self appearance];
    proxy.backgroundColor = LYRUILightGrayColor();
}

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
    // Default UI Appearance
    _initialsFont = [UIFont systemFontOfSize:14];
    _initialsColor = [UIColor blackColor];
    _avatarImageViewDiameter = 30;
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = _avatarImageViewDiameter / 2;
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    _initialsLabel = [[UILabel alloc] init];
    _initialsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _initialsLabel.textAlignment = NSTextAlignmentCenter;
    _initialsLabel.adjustsFontSizeToFitWidth = YES;
    _initialsLabel.minimumScaleFactor = 0.75;
    _initialsLabel.textColor = _initialsColor;
    _initialsLabel.font = _initialsFont;
    [self addSubview:_initialsLabel];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(self.avatarImageViewDiameter, self.avatarImageViewDiameter);
}

- (void)setInitialsForFullName:(NSString *)fullName
{
    if (fullName) {
        NSMutableString *initials = [NSMutableString new];
        fullName = [fullName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *names = [fullName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (names.count > 2) {
            NSString *firstName = names.firstObject;
            NSString *lastName = names.lastObject;
            names = @[firstName, lastName];
        }
        for (NSString *name in names) {
            NSString *initial = [name substringToIndex:1].uppercaseString;
            [initials appendString:initial];
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
}

- (void)setImageViewBackgroundColor:(UIColor *)imageViewBackgroundColor
{
    self.backgroundColor = imageViewBackgroundColor;
    _imageViewBackgroundColor = imageViewBackgroundColor;
}

- (void)configureInitialsLabelConstraint
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:3]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-3]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:3]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.initialsLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3]];
}
    
@end
