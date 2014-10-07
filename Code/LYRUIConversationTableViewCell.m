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
        dayDateFormatter.dateFormat = @"MMM dd";
    }
    return dayDateFormatter;
}

@interface LYRUIConversationTableViewCell ()

@property (nonatomic) UIImageView *conversationImageView;
@property (nonatomic) UILabel *conversationLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UITextView *lastMessageTextView;
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
        
        self.cellHorizontalMargin = 15.0f;
        self.imageSizeRatio = 0.0f;
        self.displaysImage = FALSE;
    }
    return self;
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

- (void)updateWithConversationLabel:(NSString *)conversationLabel
{
    self.accessibilityLabel = conversationLabel;
    self.conversationLabel.text = conversationLabel;
    [self configureLayoutConstraintsForLabels];
}

- (void)updateWithConversationImage:(UIImage *)image
{
    self.cellHorizontalMargin = 10.0f;
    self.imageSizeRatio = 0.60f;
    self.conversationImageView.image = image;
    self.displaysImage = TRUE;
}

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
    [self updateConstraintsIfNeeded];
}

- (void)updateConstraints
{
    //**********Avatar Constraints**********//
    // Width
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:self.imageSizeRatio
                                                                  constant:0]];
    
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:self.imageSizeRatio
                                                                  constant:0]];
    
    // Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:self.cellHorizontalMargin]];
    
    // Center Y
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0]];
    

    //**********Conversation Label Constraints**********//
    // Left Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.conversationImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0
                                                                  constant:self.cellHorizontalMargin]];

    // Right Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.dateLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:LSConversationLabelRightPadding]];
    // Top Margin
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:LSCellVerticalMargin]];
    // Height
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.conversationLabel
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.conversationLabelHeight]];
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
                                                                    toItem:self.conversationImageView
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
                                                                    toItem:self.conversationLabel
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
    if (self.displaysImage) {
        seperatorInset = self.frame.size.height * self.imageSizeRatio + self.cellHorizontalMargin * 2;
    } else {
        seperatorInset = self.cellHorizontalMargin * 2;
    }
    self.separatorInset = UIEdgeInsetsMake(0, seperatorInset, 0, 0);
    self.conversationImageView.layer.cornerRadius = self.frame.size.height * self.imageSizeRatio / 2;
    
}

@end
