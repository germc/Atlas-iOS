//
//  LYRUIConversationTableViewCell.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIConversationTableViewCell.h"
#import "LYRUIAvatarImageView.h"
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
        dayDateFormatter.dateFormat = @"MMM dd";
    }
    return dayDateFormatter;
}

@interface LYRUIConversationTableViewCell ()

@property (nonatomic) LYRUIAvatarImageView *avatarImageView;
@property (nonatomic) UILabel *senderLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UITextView *lastMessageTextView;
@property (nonatomic, assign) BOOL shouldShowAvatarImage;
@property (nonatomic, assign) CGFloat senderLabelHeight;
@property (nonatomic, assign) CGFloat dateLabelHeight;
@property (nonatomic, assign) CGFloat dateLabelWidth;
@property (nonatomic, assign) CGFloat cellHorizontalMargin;
@property (nonatomic, assign) CGFloat avatarImageSizeRatio;

@end

@implementation LYRUIConversationTableViewCell

@synthesize conversationImage = _conversationImage;

// Cell Constants
static CGFloat const LSCellVerticalMargin = 12.0f;
static CGFloat const LSConversationLabelRightPadding = -6.0f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialize Avatar Image
        self.avatarImageView = [[LYRUIAvatarImageView alloc] init];
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.avatarImageView];
        
        // Initialiaze Sender Image
        self.senderLabel = [[UILabel alloc] init];
        self.senderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.senderLabel];
        
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
        
        self.cellHorizontalMargin = 10.0f;
        self.avatarImageSizeRatio = 0.0f;
    }
    return self;
}

- (void)shouldShowConversationImage:(BOOL)shouldShowConversationImage
{
    _shouldShowAvatarImage = shouldShowConversationImage;
    
    if (shouldShowConversationImage) {
        self.avatarImageSizeRatio = 0.60f;
        self.avatarImageView.backgroundColor = LSGrayColor();
    } else {
        self.cellHorizontalMargin = 20.0f;
    }
}

- (void)presentConversation:(LYRConversation *)conversation withLabel:(NSString *)conversationLabel
{
    self.accessibilityLabel = conversationLabel;
    self.senderLabel.text = conversationLabel;
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
    [self configureLayoutConstraintsForLabels];
}

static NSDateFormatter *dateFormatter;

- (NSString *)dateLabelForLastMessage:(LYRMessage *)lastMessage
{
    if (!lastMessage) return @"";
    if (!lastMessage.sentAt) return @"";
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned int conversationDateFlags = NSCalendarCalendarUnit;
    NSDateComponents* conversationDateComponents = [calendar components:conversationDateFlags fromDate:lastMessage.sentAt];
    NSDate *conversationDate = [calendar dateFromComponents:conversationDateComponents];
    unsigned int currentDateFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents* currentDateComponents = [calendar components:currentDateFlags fromDate:[NSDate date]];
    NSDate *currentDate = [calendar dateFromComponents:currentDateComponents];
    NSString *dateLabel;
    if ([conversationDate compare:currentDate] == NSOrderedAscending) {
        dateLabel = [LYRUIDayDateFormatter() stringFromDate:lastMessage.sentAt];
    } else {
        dateLabel = [LYRUIHourDateFormatter() stringFromDate:lastMessage.sentAt];
    }
    return dateLabel;
}

- (void)configureLayoutConstraintsForLabels
{
    // Configure per UI Appearance Proxy
    self.senderLabel.font = self.conversationLabelFont;
    self.senderLabel.textColor = self.conversationLableColor;
    
    self.lastMessageTextView.font = self.lastMessageTextFont;
    self.lastMessageTextView.textColor = self.lastMessageTextColor;
    
    self.dateLabel.font = self.dateLabelFont;
    self.dateLabel.textColor = self.dateLabelColor;
    
    self.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *senderLabelAttributes = @{NSFontAttributeName:self.senderLabel.font};
    CGSize senderLabelSize = [self.senderLabel.text sizeWithAttributes:senderLabelAttributes];
    self.senderLabelHeight = senderLabelSize.height;
    
    NSDictionary *dateLabelAttributes = @{NSFontAttributeName:self.dateLabel.font};
    CGSize dateLabelSize = [self.dateLabel.text sizeWithAttributes:dateLabelAttributes];
    self.dateLabelHeight = dateLabelSize.height;
    self.dateLabelWidth = dateLabelSize.width + 4;
    [self updateConstraintsIfNeeded];
}

- (void)setConversationImage:(UIImage *)conversationImage
{
    self.avatarImageView.image = conversationImage;
}

- (void)updateConstraints
{
    //**********Avatar Constraints**********//
    // Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:self.avatarImageSizeRatio
                                                                  constant:0]];
    
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:self.avatarImageSizeRatio
                                                                  constant:0]];
    
    // Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:self.cellHorizontalMargin]];
    
    // Center Y
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    

    //**********Conversation Label Constraints**********//
    // Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:self.cellHorizontalMargin]];

    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:LSConversationLabelRightPadding]];
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:LSCellVerticalMargin]];
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.senderLabelHeight]];
    //**********Date Label Constraints**********//

    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-self.cellHorizontalMargin]];

    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:LSCellVerticalMargin]];
    
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.dateLabelWidth]];

    //**********Message Text Constraints**********//
    //Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.avatarImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:self.cellHorizontalMargin]];
    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:-self.cellHorizontalMargin]];
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.senderLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:4]];
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.lastMessageTextView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.lastMessageTextView.font.lineHeight * 2]];
    [super updateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat seperatorInset;
    if (self.shouldShowAvatarImage) {
        seperatorInset = self.frame.size.height * self.avatarImageSizeRatio + self.cellHorizontalMargin * 2;
    } else {
        seperatorInset = self.cellHorizontalMargin * 2;
    }
    self.separatorInset = UIEdgeInsetsMake(0, seperatorInset, 0, 0);
}

@end
