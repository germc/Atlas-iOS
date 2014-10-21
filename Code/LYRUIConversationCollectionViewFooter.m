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
@property (nonatomic) UILabel *sentAtDateLabel;
@property (nonatomic) UILabel *receivedAtDateLabel;

@property (nonatomic) NSLayoutConstraint *recipientStatusLabelWidthConstraint;
@property (nonatomic) NSLayoutConstraint *recipientStatusLabelHeightConstraint;

@property (nonatomic) NSLayoutConstraint *sentAtDateLabelWidthConstraint;
@property (nonatomic) NSLayoutConstraint *sentAtDateLabelHeightConstraint;

@property (nonatomic) NSLayoutConstraint *receivedAtDateLabelWidthConstraint;
@property (nonatomic) NSLayoutConstraint *receivedAtDateLabelHeightConstraint;

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
        
        self.sentAtDateLabel = [[UILabel alloc] init];
        self.sentAtDateLabel.font = [UIFont boldSystemFontOfSize:12];
        self.sentAtDateLabel.textColor = [UIColor grayColor];
        self.sentAtDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.sentAtDateLabel];
        
        self.receivedAtDateLabel = [[UILabel alloc] init];
        self.receivedAtDateLabel.font = [UIFont boldSystemFontOfSize:12];
        self.receivedAtDateLabel.textColor = [UIColor grayColor];
        self.receivedAtDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.receivedAtDateLabel];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.recipientStatusLabel.text = nil;
}

- (void)updateWithAttributedStringForRecipientStatus:(NSAttributedString *)recipientStatus
{
    self.recipientStatusLabel.attributedText = recipientStatus;
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

- (void)updateWithAttributedStringForSentAtDate:(NSAttributedString *)sentAtDate
{
    NSMutableAttributedString *sentAtDateLabel = [[NSMutableAttributedString alloc] initWithString:@"Message Sent At: "];
    if (!sentAtDate) {
        [sentAtDateLabel appendAttributedString:[[NSAttributedString alloc] initWithString:@"NO DATE"]];
    } else {
        [sentAtDateLabel appendAttributedString:sentAtDate];
    }
    self.sentAtDateLabel.attributedText = sentAtDateLabel;
    [self.sentAtDateLabel sizeToFit];

    if ([self.constraints containsObject:self.sentAtDateLabelWidthConstraint]) {
        [self removeConstraint:self.sentAtDateLabelWidthConstraint];
    }
    if ([self.constraints containsObject:self.sentAtDateLabelHeightConstraint]) {
        [self removeConstraint:self.sentAtDateLabelHeightConstraint];
    }
    self.sentAtDateLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:self.sentAtDateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.sentAtDateLabel.frame.size.width];
    self.sentAtDateLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.sentAtDateLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.sentAtDateLabel.frame.size.height];
    [self addConstraint:self.sentAtDateLabelWidthConstraint];
    [self addConstraint:self.sentAtDateLabelHeightConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sentAtDateLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.sentAtDateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.recipientStatusLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:4]];
}

- (void)updateWithAttributedStringForReceivedAtDate:(NSAttributedString *)receivedAtDate
{
    if (!receivedAtDate) {
        self.receivedAtDateLabel.attributedText = [[NSAttributedString alloc] initWithString:@"NO DATE"];
    } else {
        self.receivedAtDateLabel.attributedText = receivedAtDate;
        [self.receivedAtDateLabel sizeToFit];
    }

    if ([self.constraints containsObject:self.sentAtDateLabelWidthConstraint]) {
        [self removeConstraint:self.sentAtDateLabelWidthConstraint];
    }
    if ([self.constraints containsObject:self.sentAtDateLabelHeightConstraint]) {
        [self removeConstraint:self.sentAtDateLabelHeightConstraint];
    }
    self.receivedAtDateLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:self.receivedAtDateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.sentAtDateLabel.frame.size.width];
    self.receivedAtDateLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.receivedAtDateLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.sentAtDateLabel.frame.size.height];
    [self addConstraint:self.receivedAtDateLabelWidthConstraint];
    [self addConstraint:self.receivedAtDateLabelHeightConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.receivedAtDateLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.receivedAtDateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.sentAtDateLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:4]];
}
@end
