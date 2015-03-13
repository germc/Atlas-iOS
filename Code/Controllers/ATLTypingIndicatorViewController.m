//
//  ATLUITypingIndicatorViewController.m
//  Atlas
//
//  Created by Kevin Coleman on 11/11/14.
//  Copyright (c) 2015 Layer. All rights reserved.
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
#import "ATLTypingIndicatorViewController.h"
#import "ATLConstants.h"
#import "ATLMessagingUtilities.h"

@interface ATLTypingIndicatorViewController ()

@property (nonatomic) UILabel *label;
@property (nonatomic) CAGradientLayer *backgroundGradientLayer;

@end

@implementation ATLTypingIndicatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    _label.font = ATLMediumFont(12);
    _label.textColor = [UIColor grayColor];
    _label.numberOfLines = 1;
    _label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_label];
    
    [self configureToLabelConstraints];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.backgroundGradientLayer.frame = self.view.bounds;
}

- (void)updateWithParticipants:(NSOrderedSet *)participants animated:(BOOL)animated
{
    NSString *text = [self textWithParticipants:participants];
    if (text.length > 0) {
        self.label.text = text;
    }
    [self configureVisibility:text.length > 0 animated:animated];
}

- (NSString *)textWithParticipants:(NSOrderedSet *)participants
{
    NSUInteger participantsCount = participants.count;
    if (!participantsCount) {
        return nil;
    }
    
    NSMutableArray *fullNameComponents = [[[participants valueForKey:@"fullName"] allObjects] mutableCopy];
    NSString *fullNamesText = [self typingIndicatorTextWithParticipantStrings:fullNameComponents participantsCount:participantsCount];
    if ([self typingIndicatorLabelHasSpaceForText:fullNamesText]) {
        return fullNamesText;
    }
    
    NSArray *firstNames = [[participants valueForKey:@"firstName"] allObjects];
    NSMutableArray *firstNameComponents = [firstNames mutableCopy];
    NSString *firstNamesText = [self typingIndicatorTextWithParticipantStrings:firstNameComponents participantsCount:participantsCount];
    if ([self typingIndicatorLabelHasSpaceForText:firstNamesText]) {
        return firstNamesText;
    }
    
    NSMutableArray *strings = [NSMutableArray new];
    for (NSInteger displayedFirstNamesCount = participants.count; displayedFirstNamesCount >= 0; displayedFirstNamesCount--) {
        NSRange displayedRange = NSMakeRange(0, displayedFirstNamesCount);
        NSArray *displayedFirstNames = [firstNames subarrayWithRange:displayedRange];
        [strings addObjectsFromArray:displayedFirstNames];
        
        NSUInteger undisplayedCount = participantsCount - displayedRange.length;
        NSMutableString *textForUndisplayedParticipants = [NSMutableString new];
        [textForUndisplayedParticipants appendFormat:@"%ld", (unsigned long)undisplayedCount];
        if (displayedFirstNamesCount > 0 && undisplayedCount == 1) {
            [textForUndisplayedParticipants appendString:@" other"];
        } else if (displayedFirstNamesCount > 0) {
            [textForUndisplayedParticipants appendString:@" others"];
        }
        [strings addObject:textForUndisplayedParticipants];
        
        NSString *proposedSummary = [self typingIndicatorTextWithParticipantStrings:strings participantsCount:participantsCount];
        if ([self typingIndicatorLabelHasSpaceForText:proposedSummary]) {
            return proposedSummary;
        }
    }
    return nil;
}

- (void)configureVisibility:(BOOL)visible animated:(BOOL)animated
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

- (void)configureToLabelConstraints
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:8]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-8]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
}

@end
