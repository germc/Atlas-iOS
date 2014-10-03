//
//  LYRUIConversationCollectionViewHeader.m
//  Pods
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import "LYRUIConversationCollectionViewHeader.h"
#import "LYRUIConstants.h"

@interface LYRUIConversationCollectionViewHeader ()

@property (nonatomic) NSLayoutConstraint *dateLabelHeightConstraint;
@property (nonatomic) NSLayoutConstraint *dateLabelWidthConstraint;
@property (nonatomic) NSLayoutConstraint *participantLabelHeightConstraint;
@property (nonatomic) NSLayoutConstraint *participantLabelWidthConstraint;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *participantLabel;

@end

@implementation LYRUIConversationCollectionViewHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont systemFontOfSize:12];
        self.dateLabel.textColor = [UIColor grayColor];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.dateLabel];
        
        self.participantLabel = [[UILabel alloc] init];
        self.participantLabel.font = [UIFont systemFontOfSize:12];
        self.participantLabel.textColor = [UIColor grayColor];
        self.participantLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.participantLabel];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.dateLabel.text = nil;
    self.participantLabel.text = nil;
}

- (void)updateWithAttributedStringForDate:(NSString *)date
{
    if (!date) return;
    NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:date];
    NSRange range = [date rangeOfString:@","];
    NSRange boldedRange = NSMakeRange(0, range.location);
    [dateString beginEditing];
    
    [dateString addAttribute:NSFontAttributeName
                       value:[UIFont boldSystemFontOfSize:12]
                       range:boldedRange];
    
    [dateString endEditing];
    
    self.dateLabel.attributedText = dateString;
    [self.dateLabel sizeToFit];
    
    if ([self.constraints containsObject:self.dateLabelWidthConstraint]) {
        [self removeConstraint:self.dateLabelWidthConstraint];
    }
    if ([self.constraints containsObject:self.dateLabelHeightConstraint]) {
        [self removeConstraint:self.dateLabelHeightConstraint];
    }
    self.dateLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.dateLabel.frame.size.width];
    self.dateLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.dateLabel.frame.size.height];
    [self addConstraint:self.dateLabelWidthConstraint];
    [self addConstraint:self.dateLabelHeightConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:12]];
}

- (void)updateWithAttributedStringForParticipantName:(NSString *)participantName
{
    if (participantName.length) {
        self.participantLabel.text = participantName;
    } else {
        self.participantLabel.text = @"Unknown User";
    }
    
    [self.participantLabel sizeToFit];
    if ([self.constraints containsObject:self.participantLabelWidthConstraint]) {
        [self removeConstraint:self.participantLabelWidthConstraint];
    }
    if ([self.constraints containsObject:self.participantLabelHeightConstraint]) {
        [self removeConstraint:self.participantLabelHeightConstraint];
    }
    self.participantLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:self.participantLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.participantLabel.frame.size.width];
    self.participantLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.participantLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.participantLabel.frame.size.height];
    [self addConstraint:self.participantLabelWidthConstraint];
    [self addConstraint:self.participantLabelHeightConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.participantLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:44]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.participantLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-4]];
}

@end
