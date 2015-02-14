//
//  ATLUIConversationTableViewCell.m
//  Atlas
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ATLConversationTableViewCell.h"
#import "ATLConstants.h"
#import "ATLMessagingUtilities.h"
#import "ATLAvatarImageView.h"

static BOOL ATLIsDateInToday(NSDate *date)
{
    NSCalendarUnit dateUnits = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:dateUnits fromDate:date];
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:dateUnits fromDate:[NSDate date]];
    return ([dateComponents day] == [todayComponents day] &&
            [dateComponents month] == [todayComponents month] &&
            [dateComponents year] == [todayComponents year] &&
            [dateComponents era] == [todayComponents era]);
}

static NSDateFormatter *ATLRelativeDateFormatter()
{
    static NSDateFormatter *relativeDateFormatter;
    if (!relativeDateFormatter) {
        relativeDateFormatter = [[NSDateFormatter alloc] init];
        relativeDateFormatter.dateStyle = NSDateFormatterShortStyle;
        relativeDateFormatter.doesRelativeDateFormatting = YES;
    }
    return relativeDateFormatter;
}

static NSDateFormatter *ATLShortTimeFormatter()
{
    static NSDateFormatter *shortTimeFormatter;
    if (!shortTimeFormatter) {
        shortTimeFormatter = [[NSDateFormatter alloc] init];
        shortTimeFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    return shortTimeFormatter;
}

@interface ATLConversationTableViewCell ()

@property (nonatomic) NSLayoutConstraint *conversationTitleLabelWithImageLeftConstraint;
@property (nonatomic) NSLayoutConstraint *conversationTitleLabelWithoutImageLeftConstraint;

@property (nonatomic) ATLAvatarImageView *conversationImageView;
@property (nonatomic) UILabel *conversationTitleLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *lastMessageLabel;
@property (nonatomic) UIView *unreadMessageIndicator;

@end

@implementation ATLConversationTableViewCell

static CGFloat const ATLCellVerticalMargin = 10.0f;
static CGFloat const ATLConversationTitleLabelRightPadding = -6.0f;
static CGFloat const ATLUnreadMessageCountLabelSize = 14.0f;

NSString *const ATLImageMIMETypePlaceholderText = @"Attachment: Image";
NSString *const ATLLocationMIMETypePlaceholderText = @"Attachment: Location";

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    ATLConversationTableViewCell *proxy = [self appearance];
    proxy.conversationTitleLabelFont = [UIFont boldSystemFontOfSize:17];
    proxy.conversationTitleLabelColor = [UIColor blackColor];
    proxy.lastMessageLabelFont = [UIFont systemFontOfSize:15];
    proxy.lastMessageLabelColor = [UIColor grayColor];
    proxy.dateLabelFont = [UIFont systemFontOfSize:15];
    proxy.dateLabelColor = [UIColor grayColor];
    proxy.unreadMessageIndicatorBackgroundColor = ATLBlueColor();
    proxy.cellBackgroundColor = [UIColor whiteColor];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
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
    // Initialize Avatar Image
    self.conversationImageView = [[ATLAvatarImageView alloc] init];
    self.conversationImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.conversationImageView.layer.masksToBounds = YES;
    self.conversationImageView.hidden = YES;
    [self.contentView addSubview:self.conversationImageView];
    
    // Initialize Sender Image
    self.conversationTitleLabel = [[UILabel alloc] init];
    self.conversationTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.conversationTitleLabel.font = _conversationTitleLabelFont;
    self.conversationTitleLabel.textColor = _conversationTitleLabelColor;
    [self.contentView addSubview:self.conversationTitleLabel];
    
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
    self.unreadMessageIndicator.layer.cornerRadius = ATLUnreadMessageCountLabelSize / 2;
    self.unreadMessageIndicator.clipsToBounds = YES;
    self.unreadMessageIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.unreadMessageIndicator.backgroundColor = _unreadMessageIndicatorBackgroundColor;
    [self.contentView addSubview:self.unreadMessageIndicator];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.backgroundColor = _cellBackgroundColor;
    
    [self configureConversationImageViewLayoutContraints];
    [self configureconversationTitleLabelLayoutContraints];
    [self configureDateLabelLayoutContstraints];
    [self configureLastMessageLayoutConstraints];
    [self configureUnreadMessageIndicatorLayoutConstraints];
}

- (void)updateConstraints
{
    if (self.conversationImageView.isHidden) {
        [self.contentView removeConstraint:self.conversationTitleLabelWithImageLeftConstraint];
        [self.contentView addConstraint:self.conversationTitleLabelWithoutImageLeftConstraint];
    } else {
        [self.contentView removeConstraint:self.conversationTitleLabelWithoutImageLeftConstraint];
        [self.contentView addConstraint:self.conversationTitleLabelWithImageLeftConstraint];
    }

    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.separatorInset = UIEdgeInsetsMake(0, CGRectGetMinX(self.conversationTitleLabel.frame), 0, 0);
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

- (void)setConversationTitleLabelFont:(UIFont *)conversationTitleLabelFont
{
    _conversationTitleLabelFont = conversationTitleLabelFont;
    self.conversationTitleLabel.font = conversationTitleLabelFont;
}

- (void)setConversationTitleLabelColor:(UIColor *)conversationTitleLabelColor
{
    _conversationTitleLabelColor = conversationTitleLabelColor;
    self.conversationTitleLabel.textColor = conversationTitleLabelColor;
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

#pragma mark - ATLConversationPresenting

- (void)presentConversation:(LYRConversation *)conversation
{
    self.dateLabel.text = [self dateLabelForLastMessage:conversation.lastMessage];
    
    LYRMessage *message = conversation.lastMessage;
    LYRMessagePart *messagePart = message.parts.firstObject;
    if ([messagePart.MIMEType isEqualToString:ATLMIMETypeTextPlain]) {
        self.lastMessageLabel.text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImageJPEG]) {
        self.lastMessageLabel.text = ATLImageMIMETypePlaceholderText;
    } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImagePNG]) {
        self.lastMessageLabel.text = ATLImageMIMETypePlaceholderText;
    } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeLocation]) {
        self.lastMessageLabel.text = ATLLocationMIMETypePlaceholderText;
    } else {
        self.lastMessageLabel.text = ATLImageMIMETypePlaceholderText;
    }
    [self updateUnreadMessageIndicatorWithConversation:conversation];
}

- (void)updateWithAvatarItem:(id<ATLAvatarItem>)avatarItem
{
    self.conversationImageView.avatarItem = avatarItem;
    self.conversationImageView.hidden = NO;
    [self setNeedsUpdateConstraints];
}

- (void)updateUnreadMessageIndicatorWithConversation:(LYRConversation *)conversation
{
    if (conversation.hasUnreadMessages) {
        self.unreadMessageIndicator.hidden = NO;
    } else {
        self.unreadMessageIndicator.hidden = YES;
    }
}

- (void)updateWithConversationTitle:(NSString *)conversationTitle
{
    self.accessibilityLabel = conversationTitle;
    self.conversationTitleLabel.text = conversationTitle;
}

#pragma mark - Helpers

- (NSString *)dateLabelForLastMessage:(LYRMessage *)lastMessage
{
    if (!lastMessage) return @"";
    if (!lastMessage.sentAt) return @"";
    
    if (ATLIsDateInToday(lastMessage.sentAt)) {
        return [ATLShortTimeFormatter() stringFromDate:lastMessage.receivedAt];
    } else {
        return [ATLRelativeDateFormatter() stringFromDate:lastMessage.receivedAt];
    }
}

- (void)configureConversationImageViewLayoutContraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.6 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.conversationImageView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:10]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

- (void)configureconversationTitleLabelLayoutContraints
{
    self.conversationTitleLabelWithImageLeftConstraint = [NSLayoutConstraint constraintWithItem:self.conversationTitleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.conversationImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:10];
    self.conversationTitleLabelWithoutImageLeftConstraint = [NSLayoutConstraint constraintWithItem:self.conversationTitleLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:30];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationTitleLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.dateLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:ATLConversationTitleLabelRightPadding]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationTitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:ATLCellVerticalMargin]];
}

- (void)configureDateLabelLayoutContstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.conversationTitleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0f]];
    // We want the conversation label to compress if needed instead of the date label.
    [self.dateLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisHorizontal];
}

- (void)configureLastMessageLayoutConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.conversationTitleLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.conversationTitleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-8]];
}

- (void)configureUnreadMessageIndicatorLayoutConstraints
{
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLUnreadMessageCountLabelSize]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ATLUnreadMessageCountLabelSize]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.conversationTitleLabel attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-8]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.conversationTitleLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
}

@end
