//
//  LYRUIConversationCollectionViewHeader.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 9/10/14.
//
//

#import "LYRUIConversationCollectionViewHeader.h"
#import "LYRUIConstants.h"
#import "LYRUIMessagingUtilities.h"

@interface LYRUIConversationCollectionViewHeader ()

@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *participantLabel;

@end

@implementation LYRUIConversationCollectionViewHeader

NSString *const LYRUIConversationViewHeaderIdentifier = @"LYRUIConversationViewHeaderIdentifier";
CGFloat const LYRUIConversationViewHeaderVericalPadding = 6;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        _participantLabelFont = [UIFont systemFontOfSize:12];
        _participantLabelTextColor = [UIColor grayColor];
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont systemFontOfSize:12];
        self.dateLabel.textColor = [UIColor grayColor];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.dateLabel];
        
        self.participantLabel = [[UILabel alloc] init];
        self.participantLabel.font = _participantLabelFont;
        self.participantLabel.textColor = _participantLabelTextColor;
        self.participantLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.participantLabel];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:LYRUIConversationViewHeaderVericalPadding]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];

        // To work around an apparent system bug that initially requires the view to have zero width, instead of a required priority, we use a priority one higher than the content compression resistance.
        NSLayoutConstraint *dateLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10];
        dateLabelLeftConstraint.priority = UILayoutPriorityDefaultHigh + 1;
        [self addConstraint:dateLabelLeftConstraint];

        NSLayoutConstraint *dateLabelRightConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-10];
        dateLabelRightConstraint.priority = UILayoutPriorityDefaultHigh + 1;
        [self addConstraint:dateLabelRightConstraint];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.participantLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-LYRUIConversationViewHeaderVericalPadding]];
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

- (void)updateWithParticipantName:(NSString *)participantName
{
    if (participantName.length) {
        self.participantLabel.text = participantName;
    } else {
        self.participantLabel.text = @"Unknown User";
    }
}

- (void)setParticipantLabelFont:(UIFont *)participantLabelFont
{
    _participantLabelFont = participantLabelFont;
    self.participantLabel.font = participantLabelFont;
}

- (void)setParticipantLabelTextColor:(UIColor *)participantLabelTextColor
{
    _participantLabelTextColor = participantLabelTextColor;
    self.participantLabel.textColor = participantLabelTextColor;
}

+ (CGFloat)headerHeightWithDateString:(NSAttributedString *)dateString participantName:(NSString *)participantName
{
    LYRUIConversationCollectionViewHeader *header = [[self alloc] init];
    CGFloat height = 0.0;
    if (participantName) height += LYRUIConversationViewHeaderVericalPadding;
    if (dateString) height += LYRUIConversationViewHeaderVericalPadding;
    
    CGSize participantNameSize = LYRUITextPlainSize(participantName, header.participantLabelFont);
    CGFloat dateHeight = [self heightForAttributedString:dateString];
    
    return (dateHeight + participantNameSize.height + LYRUIConversationViewHeaderVericalPadding + height);
}

+ (CGFloat)heightForAttributedString:(NSAttributedString *)attributedString
{
    CGRect rect = [attributedString.string boundingRectWithSize:CGSizeMake(LYRUIMaxCellWidth(), CGFLOAT_MAX)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:[attributedString attributesAtIndex:0 effectiveRange:nil]
                                                        context:nil];
    return rect.size.height;
}

@end
