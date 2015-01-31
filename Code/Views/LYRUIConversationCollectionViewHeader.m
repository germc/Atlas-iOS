//
//  LYRUIConversationCollectionViewHeader.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import "LYRUIConversationCollectionViewHeader.h"
#import "LYRUIConstants.h"

@interface LYRUIConversationCollectionViewHeader ()

@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *participantLabel;

@end

@implementation LYRUIConversationCollectionViewHeader

NSString *const LYRUIMessageCellHeaderIdentifier = @"LYRUIMessageCellHeaderIdentifier";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont systemFontOfSize:12];
        self.dateLabel.textColor = [UIColor grayColor];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.dateLabel];
        
        self.participantLabel = [[UILabel alloc] init];
        self.participantLabel.font = [UIFont systemFontOfSize:12];
        self.participantLabel.textColor = [UIColor grayColor];
        self.participantLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.participantLabel];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:12]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];

        // To work around an apparent system bug that initially requires the view to have zero width, instead of a required priority, we use a priority one higher than the content compression resistance.
        NSLayoutConstraint *dateLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10];
        dateLabelLeftConstraint.priority = UILayoutPriorityDefaultHigh + 1;
        [self addConstraint:dateLabelLeftConstraint];

        NSLayoutConstraint *dateLabelRightConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10];
        dateLabelRightConstraint.priority = UILayoutPriorityDefaultHigh + 1;
        [self addConstraint:dateLabelRightConstraint];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.participantLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-4]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.participantLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:50]];

        NSLayoutConstraint *participantLabelRightConstraint = [NSLayoutConstraint constraintWithItem:self.participantLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10];
        participantLabelRightConstraint.priority = UILayoutPriorityDefaultHigh + 1;
        [self addConstraint:participantLabelRightConstraint];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.dateLabel.text = nil;
    self.participantLabel.text = nil;
}

- (void)updateWithAttributedStringForDate:(NSAttributedString *)date
{
    if (!date) return;
    self.dateLabel.attributedText = date;
}

- (void)updateWithAttributedStringForParticipantName:(NSAttributedString *)participantName
{
    if (participantName.length) {
        self.participantLabel.attributedText = participantName;
    } else {
        self.participantLabel.text = @"Unknown User";
    }
}

@end
