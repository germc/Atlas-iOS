//
//  ATLUIAddressBarController.m
//  Atlas
//
//  Created by Kevin Coleman on 10/27/14.
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

#import "ATLAddressBarViewController.h"
#import "ATLConstants.h"
#import "ATLAddressBarContainerView.h"

@interface ATLAddressBarViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *participants;
@property (nonatomic, getter=isDisabled) BOOL disabled;

@end

@implementation ATLAddressBarViewController

CGFloat const ATLDisabledStringPadding = 20;
NSString *const ATLAddressBarViewAccessibilityLabel = @"Address Bar View";
NSString *const ATLAddressBarAccessibilityLabel = @"Address Bar";
static NSString *const ATLMParticpantCellIdentifier = @"participantCellIdentifier";
static NSString *const ATLAddressBarParticipantAttributeName = @"ATLAddressBarParticipant";

- (void)loadView
{
    self.view = [ATLAddressBarContainerView new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.accessibilityLabel = ATLAddressBarAccessibilityLabel;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.addressBarView = [[ATLAddressBarView alloc] init];
    self.addressBarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.addressBarView.accessibilityLabel = ATLAddressBarViewAccessibilityLabel;
    self.addressBarView.backgroundColor = ATLAddressBarGray();
    self.addressBarView.addressBarTextView.delegate = self;
    [self.addressBarView.addContactsButton addTarget:self action:@selector(contactButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addressBarView];
   
    self.tableView = [[UITableView alloc] init];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 56;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ATLMParticpantCellIdentifier];
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.hidden = YES;
    [self.view addSubview:self.tableView];
    
    [self configureLayoutConstraintsForAddressBarView];
    [self configureLayoutConstraintsForTableView];
}

#pragma mark - Public Method Implementation

- (void)disable
{
    if (self.isDisabled) return;
    self.disabled = YES;

    self.addressBarView.addressBarTextView.text = [self disabledStringForParticipants:self.selectedParticipants];
    self.addressBarView.addressBarTextView.textColor = ATLGrayColor();
    self.addressBarView.addressBarTextView.editable = NO;
    self.addressBarView.addressBarTextView.userInteractionEnabled = NO;
    self.addressBarView.addContactsButton.hidden = YES;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressBarTappedWhileDisabled:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [self sizeAddressBarView];
}

- (void)selectParticipant:(id<ATLParticipant>)participant
{
    if (!participant) return;

    NSMutableOrderedSet *participants = [NSMutableOrderedSet orderedSetWithOrderedSet:self.selectedParticipants];
    [participants addObject:participant];
    self.selectedParticipants = participants;
}

- (void)setSelectedParticipants:(NSOrderedSet *)selectedParticipants
{
    if (!selectedParticipants && !_selectedParticipants) return;
    if ([selectedParticipants isEqual:_selectedParticipants]) return;

    if (self.isDisabled) {
        NSString *text = [self disabledStringForParticipants:selectedParticipants];
        self.addressBarView.addressBarTextView.text = text;
    } else {
        NSAttributedString *attributedText = [self attributedStringForParticipants:selectedParticipants];
        self.addressBarView.addressBarTextView.attributedText = attributedText;
    }
    [self sizeAddressBarView];
    
    NSOrderedSet *existingParticipants = _selectedParticipants;
    _selectedParticipants = selectedParticipants;
    
    if (self.isDisabled) return;
    
    NSMutableOrderedSet *removedParticipants = [NSMutableOrderedSet orderedSetWithOrderedSet:existingParticipants];
    if (selectedParticipants) [removedParticipants minusOrderedSet:selectedParticipants];
    [self notifyDelegateOfRemovedParticipants:removedParticipants];
    
    NSMutableOrderedSet *addedParticipants = [NSMutableOrderedSet orderedSetWithOrderedSet:selectedParticipants];
    if (existingParticipants) [addedParticipants minusOrderedSet:existingParticipants];
    [self notifyDelegateOfSelectedParticipants:addedParticipants];
    
    [self searchEnded];
}

- (void)reloadView
{
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.participants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ATLMParticpantCellIdentifier];
    id<ATLParticipant> participant = self.participants[indexPath.row];
    cell.textLabel.text = participant.fullName;
    cell.textLabel.font = ATLMediumFont(16);
    cell.textLabel.textColor = ATLBlueColor();
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<ATLParticipant> participant = self.participants[indexPath.row];
    [self selectParticipant:participant];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.addressBarView.addressBarTextView) return;
    if (CGSizeEqualToSize(scrollView.frame.size, scrollView.contentSize)) {
        scrollView.contentOffset = CGPointZero;
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.addressBarView.addContactsButton.hidden = NO;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.addressBarView.addContactsButton.hidden = YES;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.typingAttributes[NSForegroundColorAttributeName]) {
        NSMutableDictionary *attributes = [textView.typingAttributes mutableCopy];
        attributes[NSForegroundColorAttributeName] = self.addressBarView.addressBarTextView.addressBarTextColor;
        textView.typingAttributes = attributes;
    }

    // If user is deleting...
    if ([text isEqualToString:@""]) {
        NSAttributedString *attributedString = textView.attributedText;
        // If range.length is 1, we need to select the participant
        if (range.length == 1) {
            NSRange effectiveRange;
            id<ATLParticipant> participant = [attributedString attribute:ATLAddressBarParticipantAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, attributedString.length)];
            if (participant && effectiveRange.location + effectiveRange.length == range.location + range.length) {
                textView.selectedRange = effectiveRange;
                return NO;
            }
        }
    } else if ([text rangeOfString:@"\n"].location != NSNotFound) {
        return NO;
    }
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    NSRange selectedRange = textView.selectedRange;
    NSRange acceptableRange = [self acceptableSelectedRange];
    if (!NSEqualRanges(acceptableRange, selectedRange)) {
        textView.selectedRange = acceptableRange;
    }
    // Workaround for automatic scrolling not occurring in some cases after text entry.
    [textView scrollRangeToVisible:textView.selectedRange];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSAttributedString *attributedString = textView.attributedText;
    NSOrderedSet *participants = [self participantsInAttributedString:attributedString];
    NSMutableOrderedSet *removedParticipants = [NSMutableOrderedSet orderedSetWithOrderedSet:self.selectedParticipants];
    [removedParticipants minusOrderedSet:participants];
    _selectedParticipants = participants;
    if ([self.delegate respondsToSelector:@selector(addressBarViewController:didRemoveParticipant:)]) {
        for (id<ATLParticipant> participant in removedParticipants) {
            [self.delegate addressBarViewController:self didRemoveParticipant:participant];
        }
    }

    [self sizeAddressBarView];
    NSString *enteredText = textView.text;
    NSString *searchText = [self textForSearchFromTextView:textView];
    // If no text, reset search bar
    if (searchText.length == 0) {
        [self searchEnded];
    } else {
        if (self.tableView.isHidden) {
            self.tableView.hidden = NO;
            if ([self.delegate respondsToSelector:@selector(addressBarViewControllerDidBeginSearching:)]) {
                [self.delegate addressBarViewControllerDidBeginSearching:self];
            }
        }
        if ([self.delegate respondsToSelector:@selector(addressBarViewController:searchForParticipantsMatchingText:completion:)]) {
            [self.delegate addressBarViewController:self searchForParticipantsMatchingText:searchText completion:^(NSArray *participants) {
                if (![enteredText isEqualToString:textView.text]) return;
                self.tableView.hidden = NO;
                self.participants = [self filteredParticipants:participants];
                [self.tableView reloadData];
                [self.tableView setContentOffset:CGPointZero animated:NO];
            }];
        }
    }
}

#pragma mark - Actions

- (void)addressBarTextViewTapped:(UITapGestureRecognizer *)recognizer
{
    if (self.disabled) return;
    
    // Make sure the addressTextView is first responder
    if (!self.addressBarView.addressBarTextView.isFirstResponder) {
        [self.addressBarView.addressBarTextView becomeFirstResponder];
    }
    
    // Calculate the tap index
    UITextView *textView = (UITextView *)recognizer.view;
    CGPoint tapPoint = [recognizer locationInView:textView];
    UITextPosition *tapTextPosition = [textView closestPositionToPoint:tapPoint];
    NSInteger tapIndex = [self.addressBarView.addressBarTextView offsetFromPosition:self.addressBarView.addressBarTextView.beginningOfDocument toPosition:tapTextPosition];
    NSAttributedString *attributedString = self.addressBarView.addressBarTextView.attributedText;
    if (tapIndex == 0) {
        textView.selectedRange = NSMakeRange(0, 0);
        return;
    }
    if (tapIndex == attributedString.length) {
        textView.selectedRange = NSMakeRange(attributedString.length, 0);
        return;
    }
    NSRange participantRange;
    id<ATLParticipant> participant = [attributedString attribute:ATLAddressBarParticipantAttributeName atIndex:tapIndex - 1 longestEffectiveRange:&participantRange inRange:NSMakeRange(0, attributedString.length)];
    if (participant) {
        textView.selectedRange = participantRange;
    } else {
        textView.selectedRange = NSMakeRange(tapIndex, 0);
    }
}

- (void)addressBarTappedWhileDisabled:(id)sender
{
    [self notifyDelegateOfDisableTap];
}

- (void)contactButtonTapped:(UIButton *)sender
{
    [self notifyDelegateOfContactButtonTap:sender];
}

#pragma mark - Delegate Implementation

- (void)notifyDelegateOfSelectedParticipants:(NSMutableOrderedSet *)selectedParticipants
{
    if ([self.delegate respondsToSelector:@selector(addressBarViewController:didSelectParticipant:)]) {
        for (id<ATLParticipant> addedParticipant in selectedParticipants) {
            [self.delegate addressBarViewController:self didSelectParticipant:addedParticipant];
        }
    }
}

- (void)notifyDelegateOfRemovedParticipants:(NSMutableOrderedSet *)removedParticipants
{
    if ([self.delegate respondsToSelector:@selector(addressBarViewController:didRemoveParticipant:)]) {
        for (id<ATLParticipant> removedParticipant in removedParticipants) {
            [self.delegate addressBarViewController:self didRemoveParticipant:removedParticipant];
        }
    }
}

- (void)notifyDelegateOfSearchEnd
{
    if ([self.delegate respondsToSelector:@selector(addressBarViewControllerDidEndSearching:)]) {
        [self.delegate addressBarViewControllerDidEndSearching:self];
    }
}

- (void)notifyDelegateOfDisableTap
{
    if ([self.delegate respondsToSelector:@selector(addressBarViewControllerDidSelectWhileDisabled:)]) {
        [self.delegate addressBarViewControllerDidSelectWhileDisabled:self];
    }
}

- (void)notifyDelegateOfContactButtonTap:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(addressBarViewController:didTapAddContactsButton:)]) {
        [self.delegate addressBarViewController:self didTapAddContactsButton:sender];
    }
}

#pragma mark - Helpers

- (void)sizeAddressBarView
{
    // We layout addressBarTextView as it drives the address bar size.
    [self.addressBarView.addressBarTextView setNeedsLayout];
}

- (NSString *)textForSearchFromTextView:(UITextView *)textView
{
    NSAttributedString *attributedString = textView.attributedText;
    __block NSRange searchRange = NSMakeRange(NSNotFound, 0);
    [attributedString enumerateAttribute:ATLAddressBarParticipantAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id<ATLParticipant> participant, NSRange range, BOOL *stop) {
        if (participant) return;
        searchRange = range;
    }];
    if (searchRange.location == NSNotFound) return nil;
    NSAttributedString *attributedSearchString = [attributedString attributedSubstringFromRange:searchRange];
    NSString *searchString = attributedSearchString.string;
    NSString *trimmedSearchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return trimmedSearchString;
}

- (NSArray *)filteredParticipants:(NSArray *)participants
{
    NSMutableArray *prospectiveParticipants = [participants mutableCopy];
    [prospectiveParticipants removeObjectsInArray:self.selectedParticipants.array];
    return prospectiveParticipants;
}

- (void)searchEnded
{
    if (self.tableView.isHidden) return;
    [self notifyDelegateOfSearchEnd];
    self.participants = nil;
    self.tableView.hidden = YES;
    [self.tableView reloadData];
}

- (NSOrderedSet *)participantsInAttributedString:(NSAttributedString *)attributedString
{
    NSMutableOrderedSet *participants = [NSMutableOrderedSet new];
    [attributedString enumerateAttribute:ATLAddressBarParticipantAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id<ATLParticipant> participant, NSRange range, BOOL *stop) {
        if (!participant) return;
        [participants addObject:participant];
    }];
    return participants;
}

- (NSAttributedString *)attributedStringForParticipants:(NSOrderedSet *)participants
{
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    for (id<ATLParticipant> participant in participants) {
        NSAttributedString *attributedParticipant = [self attributedStringForParticipant:participant];
        [attributedString appendAttributedString:attributedParticipant];
    }
    return attributedString;
}

- (NSAttributedString *)attributedStringForParticipant:(id<ATLParticipant>)participant
{
    ATLAddressBarTextView *textView = self.addressBarView.addressBarTextView;
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];

    NSAttributedString *attributedName = [[NSAttributedString alloc] initWithString:participant.fullName attributes:@{ATLAddressBarPartAttributeName: ATLAddressBarNamePart, ATLAddressBarPartAttributeName: ATLAddressBarNamePart, NSForegroundColorAttributeName: textView.addressBarHighlightColor}];
    [attributedString appendAttributedString:attributedName];

    NSAttributedString *attributedDelimiter = [[NSAttributedString alloc] initWithString:@", " attributes:@{ATLAddressBarPartAttributeName: ATLAddressBarDelimiterPart, NSForegroundColorAttributeName: [UIColor grayColor]}];
    [attributedString appendAttributedString:attributedDelimiter];

    [attributedString addAttributes:@{ATLAddressBarParticipantAttributeName: participant, NSFontAttributeName: textView.font, NSParagraphStyleAttributeName: textView.typingAttributes[NSParagraphStyleAttributeName]} range:NSMakeRange(0, attributedString.length)];

    return attributedString;
}

- (NSRange)acceptableSelectedRange
{
    NSRange selectedRange = self.addressBarView.addressBarTextView.selectedRange;
    NSAttributedString *attributedString = self.addressBarView.addressBarTextView.attributedText;
    if (selectedRange.length == 0) {
        if (selectedRange.location == 0) return selectedRange;
        if (selectedRange.location == attributedString.length) return selectedRange;
        NSRange participantRange;
        id<ATLParticipant> participant = [attributedString attribute:ATLAddressBarParticipantAttributeName atIndex:selectedRange.location longestEffectiveRange:&participantRange inRange:NSMakeRange(0, attributedString.length)];
        if (!participant) return selectedRange;
        if (selectedRange.location <= participantRange.location) return selectedRange;
        NSUInteger participantStartIndex = participantRange.location;
        NSUInteger participantEndIndex = participantRange.location + participantRange.length;
        BOOL closerToParticipantStart = selectedRange.location - participantStartIndex < participantEndIndex - selectedRange.location;
        if (closerToParticipantStart) {
            return NSMakeRange(participantStartIndex, 0);
        } else {
            return NSMakeRange(participantEndIndex, 0);
        }
    }

    __block NSRange adjustedRange = selectedRange;
    [attributedString enumerateAttribute:ATLAddressBarParticipantAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id<ATLParticipant> participant, NSRange range, BOOL *stop) {
        if (!participant) return;
        if (NSIntersectionRange(selectedRange, range).length == 0) return;
        adjustedRange = NSUnionRange(adjustedRange, range);
    }];

    return adjustedRange;
}

# pragma mark - Disabled String Helpers

- (NSString *)disabledStringForParticipants:(NSOrderedSet *)participants
{
    [self.addressBarView.addressBarTextView layoutIfNeeded]; // Layout text view so we can have an accurate width.
    
    __block NSString *disabledString = [participants.firstObject firstName];
    NSMutableOrderedSet *mutableParticipants = [participants mutableCopy];
    [mutableParticipants removeObject:participants.firstObject];
    
    __block NSUInteger remainingParticipants = mutableParticipants.count;
    [mutableParticipants enumerateObjectsUsingBlock:^(id<ATLParticipant> participant, NSUInteger idx, BOOL *stop) {
        NSString *othersString = [self otherStringWithRemainingParticipants:remainingParticipants];
        NSString *truncatedString = [NSString stringWithFormat:@"%@ %@", disabledString, othersString];
        if ([self textViewHasSpaceForParticipantString:truncatedString]) {
            remainingParticipants -= 1;
            othersString = [self otherStringWithRemainingParticipants:remainingParticipants];
            NSString *expandedString = [NSString stringWithFormat:@"%@, %@ %@", disabledString, participant.firstName, othersString];
            if ([self textViewHasSpaceForParticipantString:expandedString]) {
                disabledString = [NSString stringWithFormat:@"%@, %@", disabledString, participant.firstName];
            } else {
                disabledString = truncatedString;
                *stop = YES;
            }
        } else {
            disabledString = [NSString stringWithFormat:@"%lu participants", (unsigned long)remainingParticipants];
            *stop = YES;
        }
    }];
    return disabledString;
}

- (NSString *)otherStringWithRemainingParticipants:(NSUInteger)remainingParticipants
{
    NSString *othersString = (remainingParticipants > 1) ? @"others" : @"other";
    return [NSString stringWithFormat:@"and %lu %@", (unsigned long)remainingParticipants, othersString];
}

- (BOOL)textViewHasSpaceForParticipantString:(NSString *)participantString
{
    CGSize fittedSize = [participantString sizeWithAttributes:@{NSFontAttributeName: self.addressBarView.addressBarTextView.font}];
    return fittedSize.width < (CGRectGetWidth(self.addressBarView.addressBarTextView.frame) - ATLAddressBarTextViewIndent - ATLAddressBarTextContainerInset - ATLDisabledStringPadding); // Adding extra padding to account for text container inset.
}

#pragma mark - Auto Layout

- (void)configureLayoutConstraintsForAddressBarView
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
}

- (void)configureLayoutConstraintsForTableView
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.addressBarView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
}

@end
