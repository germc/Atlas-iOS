//
//  LYRUIConversationCollectionViewFooter.m
//  Pods
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import "LYRUIConversationCollectionViewFooter.h"
#import "LYRUIConstants.h"

@interface LYRUIConversationCollectionViewFooter ()

@property (nonatomic) UILabel *recipientStatusLabel;

@property (nonatomic) NSLayoutConstraint *recipientStatusLabelWidthConstraint;
@property (nonatomic) NSLayoutConstraint *recipientStatusLabelHeightConstraint;

@end

@implementation LYRUIConversationCollectionViewFooter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.recipientStatusLabel = [[UILabel alloc] init];
        self.recipientStatusLabel.font = [UIFont boldSystemFontOfSize:12];
        self.recipientStatusLabel.textColor = [UIColor grayColor];
        self.recipientStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.recipientStatusLabel];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.recipientStatusLabel.text = nil;
}

- (void)updateWithAttributedStringForRecipientStatus:(NSString *)recipientStatus
{
    self.recipientStatusLabel.text = recipientStatus;
    [self.recipientStatusLabel sizeToFit];
    if ([self.constraints containsObject:self.recipientStatusLabelWidthConstraint]) {
        [self removeConstraint:self.recipientStatusLabelWidthConstraint];
    }
    if ([self.constraints containsObject:self.recipientStatusLabelHeightConstraint]) {
        [self removeConstraint:self.recipientStatusLabelHeightConstraint];
    }
    self.recipientStatusLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.recipientStatusLabel.frame.size.width];
    self.recipientStatusLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.recipientStatusLabel.frame.size.height];
    [self addConstraint:self.recipientStatusLabelWidthConstraint];
    [self addConstraint:self.recipientStatusLabelHeightConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.recipientStatusLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:2]];
}


@end
