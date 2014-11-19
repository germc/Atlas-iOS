//
//  LYRUIAddressBarController.m
//  
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import "LYRUIAddressBarViewController.h"
#import "LYRUIConstants.h"

@interface LYRUIAddressBarViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *participants;
@property (nonatomic) NSSet *selectedParticipants;

@property (nonatomic) NSLayoutConstraint *addressBarViewWidthConstraint;
@property (nonatomic) NSLayoutConstraint *addressBarViewHeightConstraint;
@property (nonatomic) NSLayoutConstraint *addressBarViewTopConstraint;

@property (nonatomic) NSUInteger addressBarViewDefaultHeight;
@property (nonatomic) NSUInteger addressBarViewOffset;
@property (nonatomic) NSUInteger controllerYOffset;

@end

@implementation LYRUIAddressBarViewController

static NSString *const LSParticpantCellIdentifier = @"participantCellIdentifier";
static NSString *const LYRUIAddressBarParticipantAttributeName = @"LYRUIAddressBarParticipant";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    self.addressBarView = [[LYRUIAddressBarView alloc] init];
    self.addressBarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.addressBarView.backgroundColor = LSAddressBarGray();
    self.addressBarView.addressBarTextView.delegate = self;
    [self.addressBarView.addContactsButton addTarget:self action:@selector(contactButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addressBarView];
   
    self.tableView = [[UITableView alloc] init];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LSParticpantCellIdentifier];
    [self.view addSubview:self.tableView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressBarTextViewTapped:)];
    [self.addressBarView.addressBarTextView addGestureRecognizer:gestureRecognizer];
    
    self.addressBarViewDefaultHeight = 38;

}

- (void)updateControllerOffset:(CGPoint)offset
{
    self.controllerYOffset = -offset.y;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -self.controllerYOffset, 0);

    UIView *presentingView = [[self parentViewController] view];
    self.addressBarViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:presentingView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    self.addressBarViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.addressBarViewDefaultHeight];
    self.addressBarViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:presentingView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.controllerYOffset];
    
    [presentingView addConstraint:self.addressBarViewWidthConstraint];
    [presentingView addConstraint:self.addressBarViewHeightConstraint];
    [presentingView addConstraint:self.addressBarViewTopConstraint];
    
    [self updateConstraints];
}

- (void)updateControllerHeight
{
    UIView *presentingView = [[self parentViewController] view];
    self.addressBarViewHeightConstraint.constant = presentingView.frame.size.height - self.controllerYOffset;
    [presentingView setNeedsUpdateConstraints];
}

- (void)resetControllerHeight
{
    UIView *presentingView = [[self parentViewController] view];
    self.addressBarViewHeightConstraint.constant = self.addressBarViewDefaultHeight;
    [presentingView setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.addressBarView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    [super updateViewConstraints];
}

#pragma mark - Table view data source

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
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:LSParticpantCellIdentifier];
    cell.textLabel.text = [[self.participants objectAtIndex:indexPath.row] fullName];
    cell.textLabel.font = LSMediumFont(14);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<LYRUIParticipant>participant = [self.participants objectAtIndex:indexPath.row];
    [self selectParticipant:participant];
}

#pragma mark - Public Method Implementation

- (void)setPermanent
{
    NSAttributedString *attributedString = self.addressBarView.addressBarTextView.attributedText;
    NSMutableString *permanentText = [NSMutableString new];
    [attributedString enumerateAttribute:LYRUIAddressBarParticipantAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id<LYRUIParticipant> participant, NSRange range, BOOL *stop) {
        if (!participant) return;
        if (permanentText.length > 0) {
            [permanentText appendString:@", "];
        }
        [permanentText appendString:participant.fullName];
    }];
    self.addressBarView.addressBarTextView.text = permanentText;
    self.addressBarView.addressBarTextView.textColor = LSGrayColor();
    self.addressBarView.addressBarTextView.userInteractionEnabled = NO;
    [self sizeAddressBarView];
}

- (void)selectParticipant:(id<LYRUIParticipant>)participant
{
    NSSet *existingParticipants = [NSSet setWithSet:self.selectedParticipants];
    self.selectedParticipants = [existingParticipants setByAddingObject:participant];

    NSAttributedString *attributedString = self.addressBarView.addressBarTextView.attributedText;
    NSMutableAttributedString *adjustedAttributedString = [NSMutableAttributedString new];
    [attributedString enumerateAttribute:LYRUIAddressBarParticipantAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id<LYRUIParticipant> participant, NSRange range, BOOL *stop) {
        if (!participant) return;
        NSAttributedString *attributedParticipant = [self attributedStringForParticipant:participant];
        [adjustedAttributedString appendAttributedString:attributedParticipant];
    }];

    NSAttributedString *attributedParticipant = [self attributedStringForParticipant:participant];
    [adjustedAttributedString appendAttributedString:attributedParticipant];

    self.addressBarView.addressBarTextView.attributedText = adjustedAttributedString;
    [self sizeAddressBarView];

    // Inform delegate of selection
    if ([self.delegate respondsToSelector:@selector(addressBarViewController:didSelectParticipant:)]) {
        [self.delegate addressBarViewController:self didSelectParticipant:participant];
    }
    [self searchEnded];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.addressBarView.addressBarTextView) return;
    if (CGSizeEqualToSize(scrollView.frame.size, scrollView.contentSize)) {
        scrollView.contentOffset = CGPointZero;
    }
}

#pragma mark - Address Bar Text View Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self sizeAddressBarView];
    self.addressBarView.addContactsButton.alpha = 1.0f;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    self.addressBarView.addContactsButton.alpha = 0.0f;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.typingAttributes[NSForegroundColorAttributeName]) {
        NSMutableDictionary *attributes = [textView.typingAttributes mutableCopy];
        [attributes removeObjectForKey:NSForegroundColorAttributeName];
        textView.typingAttributes = attributes;
    }

    // If user is deleting...
    if ([text isEqualToString:@""]) {
        NSAttributedString *attributedString = textView.attributedText;
        // If range.length is 1, we need to select the participant
        if (range.length == 1) {
            NSRange effectiveRange;
            id<LYRUIParticipant> participant = [attributedString attribute:LYRUIAddressBarParticipantAttributeName atIndex:range.location longestEffectiveRange:&effectiveRange inRange:NSMakeRange(0, attributedString.length)];
            if (participant && effectiveRange.location + effectiveRange.length == range.location + range.length) {
                textView.selectedRange = effectiveRange;
                return NO;
            }
        }
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
}

- (void)sizeAddressBarView
{
    [self.addressBarView.addressBarTextView invalidateIntrinsicContentSize];
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSAttributedString *attributedString = textView.attributedText;
    NSMutableSet *participants = [NSMutableSet new];
    [attributedString enumerateAttribute:LYRUIAddressBarParticipantAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id<LYRUIParticipant> participant, NSRange range, BOOL *stop) {
        if (!participant) return;
        [participants addObject:participant];
    }];
    NSMutableSet *removedParticipants = [NSMutableSet setWithSet:self.selectedParticipants];
    [removedParticipants minusSet:participants];
    self.selectedParticipants = participants;
    if ([self.delegate respondsToSelector:@selector(addressBarViewController:didRemoveParticipant:)]) {
        for (id<LYRUIParticipant> participant in removedParticipants) {
            [self.delegate addressBarViewController:self didRemoveParticipant:participant];
        }
    }

    [self sizeAddressBarView];
    // If no text, reset search bar
    if (!textView.text.length) {
        [self searchEnded];
    } else {
        NSString *searchText = [self filterTextViewText:textView];
        if (searchText) {
            self.tableView.alpha = 1.0f;
            [self.dataSource searchForParticipantsMatchingText:searchText completion:^(NSSet *participants) {
                self.tableView.alpha = 1.0;
                self.participants = [self filteredParticipants:participants];
                [self.tableView reloadData];
                if ([self.delegate respondsToSelector:@selector(addressBarViewControllerDidBeginSearching:)]) {
                    [self.delegate addressBarViewControllerDidBeginSearching:self];
                }
                [self updateControllerHeight];
            }];
        }
    }
}

- (NSString *)filterTextViewText:(UITextView *)textView
{
    NSAttributedString *attributedString = textView.attributedText;
    __block NSRange searchRange = NSMakeRange(NSNotFound, 0);
    [attributedString enumerateAttribute:LYRUIAddressBarParticipantAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id<LYRUIParticipant> participant, NSRange range, BOOL *stop) {
        if (participant) return;
        searchRange = range;
    }];
    if (searchRange.location == NSNotFound) return nil;
    NSAttributedString *attributedSearchString = [attributedString attributedSubstringFromRange:searchRange];
    NSString *searchString = attributedSearchString.string;
    NSString *trimmedSearchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return trimmedSearchString;
}

- (NSArray *)filteredParticipants:(NSSet *)participants
{
    NSMutableSet *prospectiveParticipants = [participants mutableCopy];
    [prospectiveParticipants minusSet:self.selectedParticipants];
    return prospectiveParticipants.allObjects;
}

- (void)addressBarTextViewTapped:(UITapGestureRecognizer *)recognizer
{
    // Make sure the addressTextView is first responder
    if (!self.addressBarView.addressBarTextView.isFirstResponder) {
        [self.addressBarView.addressBarTextView  becomeFirstResponder];
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
    id<LYRUIParticipant> participant = [attributedString attribute:LYRUIAddressBarParticipantAttributeName atIndex:tapIndex - 1 longestEffectiveRange:&participantRange inRange:NSMakeRange(0, attributedString.length)];
    if (participant) {
        textView.selectedRange = participantRange;
    } else {
        textView.selectedRange = NSMakeRange(tapIndex, 0);
    }
}

- (void)contactButtonTapped:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(addressBarViewController:didTapAddContactsButton:)]) {
        [self.delegate addressBarViewController:self didTapAddContactsButton:sender];
    }
}

- (void)searchEnded
{
    // Search resets on selection. Inform delegate
    [self resetControllerHeight];
    if ([self.delegate respondsToSelector:@selector(addressBarViewControllerDidEndSearching:)]) {
        [self.delegate addressBarViewControllerDidEndSearching:self];
    }
    self.participants = nil;
    self.tableView.alpha = 0.0f;
}

- (NSAttributedString *)attributedStringForParticipant:(id<LYRUIParticipant>)participant
{
    LYRUIAddressBarTextView *textView = self.addressBarView.addressBarTextView;
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];

    NSAttributedString *attributedName = [[NSAttributedString alloc] initWithString:participant.fullName attributes:@{NSForegroundColorAttributeName: textView.addressBarHightlightColor}];
    [attributedString appendAttributedString:attributedName];

    NSAttributedString *attributedDelimiter = [[NSAttributedString alloc] initWithString:@", " attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    [attributedString appendAttributedString:attributedDelimiter];

    [attributedString addAttributes:@{LYRUIAddressBarParticipantAttributeName: participant, NSFontAttributeName: textView.font, NSParagraphStyleAttributeName: textView.typingAttributes[NSParagraphStyleAttributeName]} range:NSMakeRange(0, attributedString.length)];

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
        id<LYRUIParticipant> participant = [attributedString attribute:LYRUIAddressBarParticipantAttributeName atIndex:selectedRange.location longestEffectiveRange:&participantRange inRange:NSMakeRange(0, attributedString.length)];
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
    [attributedString enumerateAttribute:LYRUIAddressBarParticipantAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(id<LYRUIParticipant> participant, NSRange range, BOOL *stop) {
        if (!participant) return;
        if (NSIntersectionRange(selectedRange, range).length == 0) return;
        adjustedRange = NSUnionRange(adjustedRange, range);
    }];

    return adjustedRange;
}

@end
