//
//  LYRUIConversationTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationTableViewCell.h"
#import "LYRUIConstants.h"

static NSDateFormatter *LYRUIHourDateFormatter()
{
    static NSDateFormatter *hourDateFormatter;
    if (!hourDateFormatter) {
        hourDateFormatter = [[NSDateFormatter alloc] init];
        hourDateFormatter.dateFormat = @"hh:mm a";
    }
    return hourDateFormatter;
}

static NSDateFormatter *LYRUIDayDateFormatter()
{
    static NSDateFormatter *dayDateFormatter;
    if (!dayDateFormatter) {
        dayDateFormatter = [[NSDateFormatter alloc] init];
        dayDateFormatter.dateFormat = @"EEEE";
    }
    return dayDateFormatter;
}

static NSDateFormatter *LYRUIMonthDateFormatter()
{
    static NSDateFormatter *dayDateFormatter;
    if (!dayDateFormatter) {
        dayDateFormatter = [[NSDateFormatter alloc] init];
        dayDateFormatter.dateFormat = @"MMM dd";
    }
    return dayDateFormatter;
}


@interface LYRUIConversationTableViewCell ()

@property (nonatomic) NSLayoutConstraint *imageViewWidthConstraint;
@property (nonatomic) NSLayoutConstraint *imageViewHeighConstraint;
@property (nonatomic) NSLayoutConstraint *imageViewLeftConstraint;
@property (nonatomic) NSLayoutConstraint *imageViewCenterYConstraint;

@property (nonatomic) NSLayoutConstraint *conversationLabelLeftConstraint;
@property (nonatomic) NSLayoutConstraint *conversationLabelRightConstraint;
@property (nonatomic) NSLayoutConstraint *conversationLabelTopConstraint;
@property (nonatomic) NSLayoutConstraint *conversationLabelHeightConstraint;

@property (nonatomic) NSLayoutConstraint *dateLabelRightConstraint;
@property (nonatomic) NSLayoutConstraint *dateLabelTopConstraint;
@property (nonatomic) NSLayoutConstraint *dateLabelWidthConstraint;

@property (nonatomic) NSLayoutConstraint *lastMessageTextLeftConstraint;
@property (nonatomic) NSLayoutConstraint *lastMessageTextRightConstraint;
@property (nonatomic) NSLayoutConstraint *lastMessageTextTopConstraint;
@property (nonatomic) NSLayoutConstraint *lastMessageTextHeightConstraint;

@property (nonatomic) NSLayoutConstraint *unreadMessageIndicatorWidth;
@property (nonatomic) NSLayoutConstraint *unreadMessageIndicatorHeight;
@property (nonatomic) NSLayoutConstraint *unreadMessageIndicatorRight;
@property (nonatomic) NSLayoutConstraint *unreadMessageIndicatorTop;

@property (nonatomic) UIImageView *conversationImageView;
@property (nonatomic) UILabel *conversationLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UITextView *lastMessageTextView;
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
static CGFloat const LSCellVerticalMargin = 12.0f;
static CGFloat const LSConversationLabelRightPadding = -6.0f;
static CGFloat const LSUnreadMessageCountLabelSize = 14.0f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialize Avatar Image
        self.conversationImageView = [[UIImageView alloc] init];
        self.conversationImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.conversationImageView.backgroundColor = LSGrayColor();
        [self.contentView addSubview:self.conversationImageView];
        
        // Initialiaze Sender Image
        self.conversationLabel = [[UILabel alloc] init];
        self.conversationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.conversationLabel];
        
        // Initialize Message Text
        self.lastMessageTextView = [[UITextView alloc] init];
        self.lastMessageTextView.translatesAutoresizingMaskIntoConstraints = NO;
        self.lastMessageTextView.contentInset = UIEdgeInsetsMake(-10,-4,0,0);
        self.lastMessageTextView.userInteractionEnabled = NO;
        [self.contentView addSubview:self.lastMessageTextView];
        
        // Initialize Date Label
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.dateLabel.textAlignment= NSTextAlignmentRight;
        [self.contentView addSubview:self.dateLabel];
        
        self.unreadMessageIndicator = [[UIView alloc] init];
        self.unreadMessageIndicator.layer.cornerRadius = LSUnreadMessageCountLabelSize / 2;
        self.unreadMessageIndicator.clipsToBounds = YES;
        self.unreadMessageIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.unreadMessageIndicator];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.cellHorizontalMargin = 15.0f;
        self.imageSizeRatio = 0.0f;
        self.displaysImage = FALSE;
        
        [self updateConstraints];
    }
    return self;
}

- (void)setConversationLabelFont:(UIFont *)conversationLabelFont
{
    _conversationLabelFont = conversationLabelFont;
}

- (void)presentConversation:(LYRConversation *)conversation
{
    self.dateLabel.text = [self dateLabelForLastMessage:conversation.lastMessage];
    
    LYRMessage *message = conversation.lastMessage;
    LYRMessagePart *messagePart = [message.parts firstObject];
    if ([messagePart.MIMEType isEqualToString:@"text/plain"]) {
        self.lastMessageTextView.text = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
    } else if (messagePart.MIMEType == LYRUIMIMETypeImageJPEG) {
        self.lastMessageTextView.text = @"Attachement: Image";
    } else if (messagePart.MIMEType == LYRUIMIMETypeImagePNG) {
        self.lastMessageTextView.text = @"Attachement: Image";
    } else if (messagePart.MIMEType == LYRUIMIMETypeLocation) {
        self.lastMessageTextView.text = @"Attachement: Location";
    } else {
        self.lastMessageTextView.text = @"Attachement: Image";
    }
}

- (void)updateWithConversationImage:(UIImage *)image
{
    self.cellHorizontalMargin = 10.0f;
    self.imageSizeRatio = 0.60f;
    self.conversationImageView.image = image;
    self.displaysImage = TRUE;
}

- (void)updateWithLastMessageRecipientStatus:(LYRRecipientStatus)recipientStatus
{
    self.unreadMessageIndicator.backgroundColor = self.unreadMessageIndicatorBackgroundColor;
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
    [self configureLayoutConstraintsForLabels];
}

- (NSString *)dateLabelForLastMessage:(LYRMessage *)lastMessage
{
    if (!lastMessage) return @"";
    if (!lastMessage.sentAt) return @"";
    
    NSString *dateLabel;
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:lastMessage.sentAt];
    if (60*60*24 > seconds) {
        dateLabel = [LYRUIHourDateFormatter() stringFromDate:lastMessage.sentAt];
    } else if (60*60*24*2 > seconds) {
        dateLabel = @"Yesterday";
    } else if (60*60*24*7 > seconds && seconds > 60*60*24*2) {
        dateLabel = [LYRUIDayDateFormatter() stringFromDate:lastMessage.sentAt];
    } else {
        dateLabel = [LYRUIMonthDateFormatter() stringFromDate:lastMessage.sentAt];
    }
    return dateLabel;
}

- (void)configureLayoutConstraintsForLabels
{
    // Configure per UI Appearance Proxy
    self.conversationLabel.font = self.conversationLabelFont;
    self.conversationLabel.textColor = self.conversationLableColor;
    
    self.lastMessageTextView.font = self.lastMessageTextFont;
    self.lastMessageTextView.textColor = self.lastMessageTextColor;
    
    self.dateLabel.font = self.dateLabelFont;
    self.dateLabel.textColor = self.dateLabelColor;
    
    self.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *conversationLabelAttributes = @{NSFontAttributeName:self.conversationLabel.font};
    CGSize conversationLabelSize = [self.conversationLabel.text sizeWithAttributes:conversationLabelAttributes];
    self.conversationLabelHeight = conversationLabelSize.height;
    
    NSDictionary *dateLabelAttributes = @{NSFontAttributeName:self.dateLabel.font};
    CGSize dateLabelSize = [self.dateLabel.text sizeWithAttributes:dateLabelAttributes];
    self.dateLabelHeight = dateLabelSize.height;
    self.dateLabelWidth = dateLabelSize.width + 4;
    [self updateConstraintConstants];
}

- (void)updateConstraintConstants
{
    self.imageViewLeftConstraint.constant = self.cellHorizontalMargin;
    
    self.conversationLabelLeftConstraint.constant = self.cellHorizontalMargin;
    self.conversationLabelHeightConstraint.constant = self.conversationLabelHeight;
    
    self.dateLabelWidthConstraint.constant = self.dateLabelWidth;
    
    self.lastMessageTextLeftConstraint.constant = self.cellHorizontalMargin;
    self.lastMessageTextHeightConstraint.constant = self.lastMessageTextView.font.lineHeight * 2;
    
    [self.contentView layoutIfNeeded];
}

- (void)updateConstraints
{
    //**********Avatar Constraints**********//
    // Width
    self.imageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:self.imageSizeRatio
                                                                  constant:0];
    
    // Height
    self.imageViewHeighConstraint = [NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:self.imageSizeRatio
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
                                                                  constant:LSConversationLabelRightPadding];
    // Top Margin
    self.conversationLabelTopConstraint = [NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:LSCellVerticalMargin];
    // Height
    self.conversationLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.conversationLabelHeight];
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
                                                                  constant:LSCellVerticalMargin];
    
    // Width Margin
    self.dateLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.dateLabelWidth];

    //**********Message Text Constraints**********//
    //Left Margin
    self.lastMessageTextLeftConstraint = [NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:self.cellHorizontalMargin];
    // Right Margin
    self.lastMessageTextRightConstraint = [NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-6];
    // Top Margin
    self.lastMessageTextTopConstraint = [NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:4];
    // Height
    self.lastMessageTextHeightConstraint = [NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.lastMessageTextView.font.lineHeight * 2];
    
    //**********Unread Messsage Label Constraints**********//
    //Width
    self.unreadMessageIndicatorWidth = [NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0
                                                                       constant:LSUnreadMessageCountLabelSize];
    // Height
    self.unreadMessageIndicatorHeight = [NSLayoutConstraint constraintWithItem:self.unreadMessageIndicator
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:LSUnreadMessageCountLabelSize];
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
    
    [self.contentView addConstraint:self.imageViewWidthConstraint];
    [self.contentView addConstraint:self.imageViewHeighConstraint];
    [self.contentView addConstraint:self.imageViewLeftConstraint];
    [self.contentView addConstraint:self.imageViewCenterYConstraint];
   
    [self.contentView addConstraint:self.conversationLabelLeftConstraint];
    [self.contentView addConstraint:self.conversationLabelRightConstraint];
    [self.contentView addConstraint:self.conversationLabelTopConstraint];
    [self.contentView addConstraint:self.conversationLabelHeightConstraint];
    
    [self.contentView addConstraint:self.dateLabelRightConstraint];
    [self.contentView addConstraint:self.dateLabelTopConstraint];
    [self.contentView addConstraint:self.dateLabelWidthConstraint];
    
    [self.contentView addConstraint:self.lastMessageTextLeftConstraint];
    [self.contentView addConstraint:self.lastMessageTextRightConstraint];
    [self.contentView addConstraint:self.lastMessageTextTopConstraint];
    [self.contentView addConstraint:self.lastMessageTextHeightConstraint];
    
    [self.contentView addConstraint:self.unreadMessageIndicatorWidth];
    [self.contentView addConstraint:self.unreadMessageIndicatorHeight];
    [self.contentView addConstraint:self.unreadMessageIndicatorTop];
    [self.contentView addConstraint:self.unreadMessageIndicatorRight];
    
    [super updateConstraints];
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
    //NSLog(@"Conversation Label Font %@", self.conversationLabel.font);
    self.separatorInset = UIEdgeInsetsMake(0, seperatorInset, 0, 0);
    self.conversationImageView.layer.cornerRadius = self.frame.size.height * self.imageSizeRatio / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected) {
        self.unreadMessageIndicator.alpha = 0.0f;
    }
}

@end
