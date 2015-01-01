//
//  LYRUIConversationTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationTableViewCell.h"
#import "LYRUIConstants.h"

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

@interface LYRUIConversationTableViewCell ()

@property (nonatomic) NSLayoutConstraint *imageViewWidthConstraint;
@property (nonatomic) NSLayoutConstraint *imageViewHeighConstraint;
@property (nonatomic) NSLayoutConstraint *imageViewLeftConstraint;
@property (nonatomic) NSLayoutConstraint *imageViewCenterYConstraint;

@property (nonatomic) NSLayoutConstraint *conversationLabelLeftConstraint;
@property (nonatomic) NSLayoutConstraint *conversationLabelRightConstraint;
@property (nonatomic) NSLayoutConstraint *conversationLabelTopConstraint;

@property (nonatomic) NSLayoutConstraint *dateLabelRightConstraint;
@property (nonatomic) NSLayoutConstraint *dateLabelTopConstraint;

@property (nonatomic) NSLayoutConstraint *lastMessageLabelLeftConstraint;
@property (nonatomic) NSLayoutConstraint *lastMessageLabelRightConstraint;
@property (nonatomic) NSLayoutConstraint *lastMessageLabelTopConstraint;
@property (nonatomic) NSLayoutConstraint *lastMessageLabelBottomConstraint;

@property (nonatomic) NSLayoutConstraint *unreadMessageIndicatorWidth;
@property (nonatomic) NSLayoutConstraint *unreadMessageIndicatorHeight;
@property (nonatomic) NSLayoutConstraint *unreadMessageIndicatorRight;
@property (nonatomic) NSLayoutConstraint *unreadMessageIndicatorTop;

@property (nonatomic) UIImageView *conversationImageView;
@property (nonatomic) UILabel *conversationLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *lastMessageLabel;
@property (nonatomic) UIView *unreadMessageIndicator;

@property (nonatomic, assign) BOOL displaysImage;
@property (nonatomic, assign) CGFloat conversationLabelHeight;
@property (nonatomic, assign) CGFloat dateLabelHeight;
@property (nonatomic, assign) CGFloat dateLabelWidth;
@property (nonatomic, assign) CGFloat cellHorizontalMargin;
@property (nonatomic, assign) CGFloat imageSizeRatio;

@end

@implementation LYRUIConversationTableViewCell

// Cell Constants
static CGFloat const LYRUICellVerticalMargin = 12.0f;
static CGFloat const LYRUIConversationLabelRightPadding = -6.0f;
static CGFloat const LYRUIUnreadMessageCountLabelSize = 14.0f;

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
        self.cellHorizontalMargin = 15.0f;
        self.imageSizeRatio = 0.0f;
        self.displaysImage = NO;
        
        [self setupLayoutConstraints];
    }
    return self;
}

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
}

- (void)updateWithConversationImage:(UIImage *)image
{
    self.cellHorizontalMargin = 10.0f;
    self.imageSizeRatio = 0.60f;
    self.conversationImageView.image = image;
    self.displaysImage = YES;
    [self setNeedsUpdateConstraints];
}

- (void)updateWithLastMessageRecipientStatus:(LYRRecipientStatus)recipientStatus
{
    switch (recipientStatus) {
        case LYRRecipientStatusDelivered:
            self.unreadMessageIndicator.alpha = 1.0;
            break;
            
        default:
            self.unreadMessageIndicator.alpha = 0.0;
            break;
    }
}

- (void)updateWithConversationLabel:(NSString *)conversationLabel
{
    self.accessibilityLabel = conversationLabel;
    self.conversationLabel.text = conversationLabel;
}

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

- (void)updateConstraints
{
    self.imageViewLeftConstraint.constant = self.cellHorizontalMargin;
    
    self.conversationLabelLeftConstraint.constant = self.cellHorizontalMargin;
    
    self.lastMessageLabelLeftConstraint.constant = self.cellHorizontalMargin;

    [self configureImageViewWidthConstraint];

    [super updateConstraints];
}

- (void)configureImageViewWidthConstraint
{
    if (self.imageViewWidthConstraint && self.imageViewWidthConstraint.multiplier == self.imageSizeRatio) return;
    [self.contentView removeConstraint:self.imageViewWidthConstraint];
    self.imageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:self.imageSizeRatio
                                                                  constant:0];
    [self.contentView addConstraint:self.imageViewWidthConstraint];
}

- (void)setupLayoutConstraints
{
    //**********Avatar Constraints**********//
    // Width
    [self configureImageViewWidthConstraint];

    // Height
    self.imageViewHeighConstraint = [NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1
                                                                  constant:0];
    
    // Left Margin
    self.imageViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:self.cellHorizontalMargin];
    
    // Center Y
    self.imageViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0];
    

    //**********Conversation Label Constraints**********//
    // Left Margin
    self.conversationLabelLeftConstraint =  [NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:self.cellHorizontalMargin];

    // Right Margin
    self.conversationLabelRightConstraint = [NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:LYRUIConversationLabelRightPadding];
    // Top Margin
    self.conversationLabelTopConstraint = [NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:LYRUICellVerticalMargin];

    //**********Date Label Constraints**********//
    // Right Margin
    self.dateLabelRightConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:0];

    // Top Margin
    self.dateLabelTopConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                 constant:LYRUICellVerticalMargin];

    //**********Message Label Constraints**********//
    //Left Margin
    self.lastMessageLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.lastMessageLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:self.cellHorizontalMargin];
    // Right Margin
    self.lastMessageLabelRightConstraint = [NSLayoutConstraint constraintWithItem:self.lastMessageLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-6];
    // Top Margin
    self.lastMessageLabelTopConstraint = [NSLayoutConstraint constraintWithItem:self.lastMessageLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:2];
    // Bottom
    self.lastMessageLabelBottomConstraint = [NSLayoutConstraint constraintWithItem:self.lastMessageLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationLessThanOrEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:-4];
    
    //**********Unread Messsage Label Constraints**********//
    //Width
    self.unreadMessageIndicatorWidth = [NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:LYRUIUnreadMessageCountLabelSize];
    // Height
    self.unreadMessageIndicatorHeight = [NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:LYRUIUnreadMessageCountLabelSize];
    // Top Margin
    self.unreadMessageIndicatorTop = [NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.conversationLabel
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0
                                                                    constant:-6];
    // Right
    self.unreadMessageIndicatorRight = [NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.conversationLabel
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0];
    
    [self.contentView addConstraint:self.imageViewHeighConstraint];
    [self.contentView addConstraint:self.imageViewLeftConstraint];
    [self.contentView addConstraint:self.imageViewCenterYConstraint];
   
    [self.contentView addConstraint:self.conversationLabelLeftConstraint];
    [self.contentView addConstraint:self.conversationLabelRightConstraint];
    [self.contentView addConstraint:self.conversationLabelTopConstraint];
    
    [self.contentView addConstraint:self.dateLabelRightConstraint];
    [self.contentView addConstraint:self.dateLabelTopConstraint];
    
    [self.contentView addConstraint:self.lastMessageLabelLeftConstraint];
    [self.contentView addConstraint:self.lastMessageLabelRightConstraint];
    [self.contentView addConstraint:self.lastMessageLabelTopConstraint];
    [self.contentView addConstraint:self.lastMessageLabelBottomConstraint];
    
    [self.contentView addConstraint:self.unreadMessageIndicatorWidth];
    [self.contentView addConstraint:self.unreadMessageIndicatorHeight];
    [self.contentView addConstraint:self.unreadMessageIndicatorTop];
    [self.contentView addConstraint:self.unreadMessageIndicatorRight];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat seperatorInset;
    if (self.displaysImage) {
        seperatorInset = self.frame.size.height * self.imageSizeRatio + self.cellHorizontalMargin * 2;
    } else {
        seperatorInset = self.cellHorizontalMargin * 2;
    }

    self.separatorInset = UIEdgeInsetsMake(0, seperatorInset, 0, 0);
    self.conversationImageView.layer.cornerRadius = self.frame.size.height * self.imageSizeRatio / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.unreadMessageIndicator.alpha = 0.0f;
    }
}

@end
