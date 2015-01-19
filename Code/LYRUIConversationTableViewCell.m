//
//  LYRUIConversationTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationTableViewCell.h"
#import "LYRUIConstants.h"
#import "LYRUIMessagingUtilities.h"

static BOOL LYRUIIsDateInToday(NSDate *date)
{
    NSCalendarUnit dateUnits = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:dateUnits fromDate:date];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:dateUnits fromDate:[NSDate date]];
    return ([dateComponents day] == [todayComponents day] &&
            [dateComponents month] == [todayComponents month] &&
            [dateComponents year] == [todayComponents year] &&
            [dateComponents era] == [todayComponents era]);
}

static NSDateFormatter *LYRUIRelativeDateFormatter()
{
    static NSDateFormatter *relativeDateFormatter;
    if (!relativeDateFormatter) {
        relativeDateFormatter = [[NSDateFormatter alloc] init];
        relativeDateFormatter.dateStyle = NSDateFormatterShortStyle;
        relativeDateFormatter.doesRelativeDateFormatting = YES;
    }
    return relativeDateFormatter;
}

static NSDateFormatter *LYRUIShortTimeFormatter()
{
    static NSDateFormatter *shortTimeFormatter;
    if (!shortTimeFormatter) {
        shortTimeFormatter = [[NSDateFormatter alloc] init];
        shortTimeFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return shortTimeFormatter;
}

static CGFloat const LYRUICellVerticalMargin = 12.0f;
static CGFloat const LYRUIConversationLabelRightPadding = -6.0f;
static CGFloat const LYRUIUnreadMessageCountLabelSize = 14.0f;

@interface LYRUIConversationTableViewCell ()

@property (nonatomic) NSLayoutConstraint *conversationLabelWithImageLeftConstraint;
@property (nonatomic) NSLayoutConstraint *conversationLabelWithoutImageLeftConstraint;

@property (nonatomic) UIImageView *conversationImageView;
@property (nonatomic) UILabel *conversationLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *lastMessageLabel;
@property (nonatomic) UIView *unreadMessageIndicator;

@end

@implementation LYRUIConversationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // UIAppearance Proxy Defaults
        _conversationLabelFont = LYRUIBoldFont(14);
        _conversationLabelColor = [UIColor blackColor];
        _lastMessageLabelFont = LYRUILightFont(14);
        _lastMessageLabelColor = [UIColor grayColor];
        _dateLabelFont = LYRUIMediumFont(14);
        _dateLabelColor = [UIColor grayColor];
        _unreadMessageIndicatorBackgroundColor = LYRUIBlueColor();
        _cellBackgroundColor = [UIColor whiteColor];
        
        // Initialize Avatar Image
        self.conversationImageView = [[UIImageView alloc] init];
        self.conversationImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.conversationImageView.backgroundColor = LYRUIGrayColor();
        self.conversationImageView.layer.masksToBounds = YES;
        self.conversationImageView.hidden = YES;
        [self.contentView addSubview:self.conversationImageView];
        
        // Initialize Sender Image
        self.conversationLabel = [[UILabel alloc] init];
        self.conversationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.conversationLabel.font = _conversationLabelFont;
        self.conversationLabel.textColor = _conversationLabelColor;
        [self.contentView addSubview:self.conversationLabel];
        
        // Initialize Message Label
        self.lastMessageLabel = [[UILabel alloc] init];
        self.lastMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.lastMessageLabel.font = _lastMessageLabelFont;
        self.lastMessageLabel.textColor = _lastMessageLabelColor;
        self.lastMessageLabel.numberOfLines = 2;
        [self.contentView addSubview:self.lastMessageLabel];
        
        // Initialize Date Label
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.font = _dateLabelFont;
        self.dateLabel.textColor = _dateLabelColor;
        [self.contentView addSubview:self.dateLabel];
        
        self.unreadMessageIndicator = [[UIView alloc] init];
        self.unreadMessageIndicator.layer.cornerRadius = LYRUIUnreadMessageCountLabelSize / 2;
        self.unreadMessageIndicator.clipsToBounds = YES;
        self.unreadMessageIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        self.unreadMessageIndicator.backgroundColor = _unreadMessageIndicatorBackgroundColor;
        [self.contentView addSubview:self.unreadMessageIndicator];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = _cellBackgroundColor;
        
        [self setUpConversationImageViewLayoutContraints];
        [self setUpConversationLabelLayoutContraints];
        [self setUpDateLabelLayoutContstraints];
        [self setUpLastMessageLayoutConstraints];
        [self setUpUnreadMessageIndicatorLayoutConstraints];
    }
    return self;
}

- (void)updateConstraints
{
    if (self.conversationImageView.isHidden) {
        [self.contentView removeConstraint:self.conversationLabelWithImageLeftConstraint];
        [self.contentView addConstraint:self.conversationLabelWithoutImageLeftConstraint];
    } else {
        [self.contentView removeConstraint:self.conversationLabelWithoutImageLeftConstraint];
        [self.contentView addConstraint:self.conversationLabelWithImageLeftConstraint];
    }

    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetMinX(self.conversationLabel.frame), 0, 0);
    self.conversationImageView.layer.cornerRadius = CGRectGetHeight(self.conversationImageView.frame) / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.unreadMessageIndicator.hidden = YES;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.conversationImageView.hidden = YES;
    [self setNeedsUpdateConstraints];
}

#pragma mark - Appearance Setters

- (void)setConversationLabelFont:(UIFont *)conversationLabelFont
{
    _conversationLabelFont = conversationLabelFont;
    self.conversationLabel.font = conversationLabelFont;
}

- (void)setConversationLabelColor:(UIColor *)conversationLabelColor
{
    _conversationLabelColor = conversationLabelColor;
    self.conversationLabel.textColor = conversationLabelColor;
}

- (void)setLastMessageLabelFont:(UIFont *)lastMessageLabelFont
{
    _lastMessageLabelFont = lastMessageLabelFont;
    self.lastMessageLabel.font = lastMessageLabelFont;
}

- (void)setLastMessageLabelColor:(UIColor *)lastMessageLabelColor
{
    _lastMessageLabelColor = lastMessageLabelColor;
    self.lastMessageLabel.textColor = lastMessageLabelColor;
}

- (void)setDateLabelFont:(UIFont *)dateLabelFont
{
    _dateLabelFont = dateLabelFont;
    self.dateLabel.font = dateLabelFont;
}

- (void)setDateLabelColor:(UIColor *)dateLabelColor
{
    _dateLabelColor = dateLabelColor;
    self.dateLabel.textColor = dateLabelColor;
}

- (void)setUnreadMessageIndicatorBackgroundColor:(UIColor *)unreadMessageIndicatorBackgroundColor
{
    _unreadMessageIndicatorBackgroundColor = unreadMessageIndicatorBackgroundColor;
    self.unreadMessageIndicator.backgroundColor = unreadMessageIndicatorBackgroundColor;
}

- (void)setCellBackgroundColor:(UIColor *)cellBackgroundColor
{
    _cellBackgroundColor = cellBackgroundColor;
    self.backgroundColor = cellBackgroundColor;
}

#pragma mark - LYRUIConversationPresenting

- (void)presentConversation:(LYRConversation *)conversation
{
    self.dateLabel.text = [self dateLabelForLastMessage:conversation.lastMessage];
    
    LYRMessage *message = conversation.lastMessage;
    LYRMessagePart *messagePart = message.parts.firstObject;
    if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeTextPlain]) {
        self.lastMessageLabel.text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImageJPEG]) {
        self.lastMessageLabel.text = @"Attachment: Image";
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeImagePNG]) {
        self.lastMessageLabel.text = @"Attachment: Image";
    } else if ([messagePart.MIMEType isEqualToString:LYRUIMIMETypeLocation]) {
        self.lastMessageLabel.text = @"Attachment: Location";
    } else {
        self.lastMessageLabel.text = @"Attachment: Image";
    }
    [self updateUnreadMessageIndicatorWithMessage:conversation.lastMessage];
}

- (void)updateWithConversationImage:(UIImage *)image
{
    self.conversationImageView.image = image;
    self.conversationImageView.hidden = NO;
    [self setNeedsUpdateConstraints];
}

- (void)updateUnreadMessageIndicatorWithMessage:(LYRMessage *)message
{
    if (message.isUnread) {
        self.unreadMessageIndicator.hidden = NO;
    } else {
        self.unreadMessageIndicator.hidden = YES;
    }
}

- (void)updateWithConversationLabel:(NSString *)conversationLabel
{
    self.accessibilityLabel = conversationLabel;
    self.conversationLabel.text = conversationLabel;
}

#pragma mark - Helpers

- (NSString *)dateLabelForLastMessage:(LYRMessage *)lastMessage
{
    if (!lastMessage) return @"";
    if (!lastMessage.receivedAt) return @"";
    
    if (LYRUIIsDateInToday(lastMessage.receivedAt)) {
        return [LYRUIShortTimeFormatter() stringFromDate:lastMessage.receivedAt];
    } else {
        return [LYRUIRelativeDateFormatter() stringFromDate:lastMessage.receivedAt];
    }
}

- (void)setUpConversationImageViewLayoutContraints
{
    // Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0.6
                                                                  constant:0]];

    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1
                                                                  constant:0]];
    
    // Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:10]];

    // Center Y
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
}

- (void)setUpConversationLabelLayoutContraints
{
    // Left Margin
    self.conversationLabelWithImageLeftConstraint = [NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:10];
    self.conversationLabelWithoutImageLeftConstraint = [NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:30];

    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:LYRUIConversationLabelRightPadding]];
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:LYRUICellVerticalMargin]];
}

- (void)setUpDateLabelLayoutContstraints
{
    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:0]];

    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                 constant:LYRUICellVerticalMargin]];
}

- (void)setUpLastMessageLayoutConstraints
{
    // Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:0]];

    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:0]];
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:2]];
    // Bottom
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:-4]];
}

- (void)setUpUnreadMessageIndicatorLayoutConstraints
{
    // Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LYRUIUnreadMessageCountLabelSize]];
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:LYRUIUnreadMessageCountLabelSize]];
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:-6]];
    // Right
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
}

@end
