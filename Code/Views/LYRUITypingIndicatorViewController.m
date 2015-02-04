//
//  LYRTypingIndicatorView.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 11/11/14.
//
//

#import "LYRUITypingIndicatorViewController.h"
#import "LYRUIConstants.h"
#import "LYRUIMessagingUtilities.h"

@interface LYRUITypingIndicatorViewController ()

@property (nonatomic) CAGradientLayer *backgroundGradientLayer;

@end

@implementation LYRUITypingIndicatorViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Make dragging on the typing indicator scroll the scroll view / keyboard.
        self.view.userInteractionEnabled = NO;
        self.view.translatesAutoresizingMaskIntoConstraints = NO;
        self.view.alpha = 0.0;
        
        _backgroundGradientLayer = [CAGradientLayer layer];
        _backgroundGradientLayer.frame = self.view.bounds;
        _backgroundGradientLayer.startPoint = CGPointZero;
        _backgroundGradientLayer.endPoint = CGPointMake(0, 1);
        _backgroundGradientLayer.colors = @[
            (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
            (id)[UIColor colorWithWhite:1.0 alpha:0.75].CGColor,
            (id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor
        ];
        [self.view.layer addSublayer:_backgroundGradientLayer];

        _label = [[UILabel alloc] init];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.font = LYRUIMediumFont(12);
        _label.textColor = [UIColor grayColor];
        _label.numberOfLines = 1;
        _label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_label];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:8]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-8]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    }
    return self;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.backgroundGradientLayer.frame = self.view.bounds;
}

- (void)updateWithParticipants:(NSMutableArray *)participants animated:(BOOL)animated
{
    NSUInteger participantsCount = participants.count;
    if (!participantsCount) {
        [self configureVisibility:NO withAnimation:animated];
        return;
    }
    
    NSMutableArray *fullNameComponents = [[participants valueForKey:@"fullName"] mutableCopy];
    NSString *fullNamesText = [self typingIndicatorTextWithParticipantStrings:fullNameComponents participantsCount:participantsCount];
    if ([self typingIndicatorLabelHasSpaceForText:fullNamesText]) {
        self.label.text = fullNamesText;
        [self configureVisibility:YES withAnimation:animated];
        return;
    }
    
    NSArray *firstNames = [participants valueForKey:@"firstName"];
    NSMutableArray *firstNameComponents = [firstNames mutableCopy];
    NSString *firstNamesText = [self typingIndicatorTextWithParticipantStrings:firstNameComponents participantsCount:participantsCount];
    if ([self typingIndicatorLabelHasSpaceForText:firstNamesText]) {
        self.label.text = firstNamesText;
        [self configureVisibility:YES withAnimation:animated];
        return;
    }
    
    NSMutableArray *strings = [NSMutableArray new];
    for (NSInteger displayedFirstNamesCount = participants.count; displayedFirstNamesCount >= 0; displayedFirstNamesCount--) {
        
        NSRange displayedRange = NSMakeRange(0, displayedFirstNamesCount);
        NSArray *displayedFirstNames = [firstNames subarrayWithRange:displayedRange];
        [strings addObjectsFromArray:displayedFirstNames];
        
        NSUInteger undisplayedCount = participantsCount - displayedRange.length;
        NSMutableString *textForUndisplayedParticipants = [NSMutableString new];;
        [textForUndisplayedParticipants appendFormat:@"%ld", (unsigned long)undisplayedCount];
        if (displayedFirstNamesCount > 0 && undisplayedCount == 1) {
            [textForUndisplayedParticipants appendString:@" other"];
        } else if (displayedFirstNamesCount > 0) {
            [textForUndisplayedParticipants appendString:@" others"];
        }
        [strings addObject:textForUndisplayedParticipants];
        
        NSString *proposedSummary = [self typingIndicatorTextWithParticipantStrings:strings participantsCount:participantsCount];
        if ([self typingIndicatorLabelHasSpaceForText:proposedSummary]) {
            self.label.text =  proposedSummary;
            [self configureVisibility:YES withAnimation:animated];
        }
    }
    
}

- (void)configureVisibility:(BOOL)visible withAnimation:(BOOL)animated
{
    NSTimeInterval duration;
    if (!animated) {
        duration = 0;
    } else if (visible) {
        duration = 0.3;
    } else {
        duration = 0.1;
    }

    [UIView animateWithDuration:duration animations:^{
        self.view.alpha = visible ? 1.0 : 0.0;
    }];
}

- (NSString *)typingIndicatorTextWithParticipantStrings:(NSArray *)participantStrings participantsCount:(NSUInteger)participantsCount
{
    NSMutableString *text = [NSMutableString new];
    NSUInteger lastIndex = participantStrings.count - 1;
    [participantStrings enumerateObjectsUsingBlock:^(NSString *participantString, NSUInteger index, BOOL *stop) {
        if (index == lastIndex && participantStrings.count == 2) {
            [text appendString:@" and "];
        } else if (index == lastIndex && participantStrings.count > 2) {
            [text appendString:@", and "];
        } else if (index > 0) {
            [text appendString:@", "];
        }
        [text appendString:participantString];
    }];
    if (participantsCount == 1) {
        [text appendString:@" is typing…"];
    } else {
        [text appendString:@" are typing…"];
    }
    return text;
}

- (BOOL)typingIndicatorLabelHasSpaceForText:(NSString *)text
{
    UILabel *label = self.label;
    CGSize fittedSize = [text sizeWithAttributes:@{NSFontAttributeName: label.font}];
    return fittedSize.width <= CGRectGetWidth(label.frame);
}

@end
