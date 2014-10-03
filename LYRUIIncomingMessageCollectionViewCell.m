//
//  LYRUIIncomingMessageCollectionViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/31/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIIncomingMessageCollectionViewCell.h"

@interface LYRUIIncomingMessageCollectionViewCell ()

@property (nonatomic) UIFont *font;
@property (nonatomic) UIColor *color;

@end

@implementation LYRUIIncomingMessageCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
       
        
    }
    return self;
}

- (void)updateConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImage
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:10]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImage
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:10]];
    [super updateConstraints];
}

@end
