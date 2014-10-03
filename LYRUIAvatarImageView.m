//
//  LSAvatarImageView.m
//  LayerSample
//
//  Created by Kevin Coleman on 6/10/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIAvatarImageView.h"
#import "LYRUIConstants.h"

@interface LYRUIAvatarImageView ()

@property (nonatomic) UILabel *initialsLabel;

@end

@implementation LYRUIAvatarImageView

- (id)init
{
    self = [super init];
    if (self) {
        self.clipsToBounds = TRUE;
        self.backgroundColor = LSGrayColor();
    }
    return self;
}

- (void)setSenderFirstName:(NSString *)firstName lastName:(NSString *)lastName
{
    NSString *firstInitial = [[firstName substringToIndex:1] uppercaseString];
    NSString *lastInitial = [[lastName substringToIndex:1] uppercaseString];
    
    self.initialsLabel = [UILabel new];
    self.initialsLabel.font = LSMediumFont(24);
    self.initialsLabel.textColor = [UIColor whiteColor];
    self.initialsLabel.text = [NSString stringWithFormat:@"%@%@", firstInitial, lastInitial];
    [self.initialsLabel sizeToFit];
    [self addSubview:self.initialsLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.layer.cornerRadius = self.frame.size.height / 2;
}

@end
