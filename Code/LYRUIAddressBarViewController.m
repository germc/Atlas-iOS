//
//  LYRUIAddressBarController.m
//  
//
//  Created by Kevin Coleman on 10/27/14.
//
//

#import "LYRUIAddressBarViewController.h"
#import "LYRUIAddressToken.h"
#import "LYRUIConstants.h"

@interface LYRUIAddressBarViewController () <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSArray *participants;
@property (nonatomic) CGFloat searchFilterIndex;
@property (nonatomic) NSMutableArray *addressTokenIndex;
@property (nonatomic) NSMutableArray *addressTokens;

@property (nonatomic) NSLayoutConstraint *addressBarViewWidthConstraint;
@property (nonatomic) NSLayoutConstraint *addressBarViewHeightConstraint;
@property (nonatomic) NSLayoutConstraint *addressBarViewTopConstraint;

@property (nonatomic) NSUInteger addressBarViewDefaultHeight;
@property (nonatomic) NSUInteger addressBarViewOffset;
@property (nonatomic) NSUInteger controllerYOffset;

@end

@implementation LYRUIAddressBarViewController

static NSString *const LSParticpantCellIdentifier = @"participantCellIdentifier";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.addressTokenIndex = [[NSMutableArray alloc] init];
    self.addressTokens = [[NSMutableArray alloc] init];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)updateControllerOffset:(CGPoint)offset
{
    self.controllerYOffset = offset.y;
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
   // [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.addressBarViewDefaultHeight]];
    
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
    if (self.addressTokens.count) {
        LYRUIAddressToken *token = [self.addressTokens objectAtIndex:0];
        NSString *permanentText = token.participant.firstName;
        for (int i = 1; i < self.addressTokens.count; i++) {
            token = [self.addressTokens objectAtIndex:i];
            permanentText = [permanentText stringByAppendingString:[NSString stringWithFormat:@", %@", token.participant.firstName]];
        }
        self.addressBarView.addressBarTextView.text = permanentText;
        self.addressBarView.addressBarTextView.textColor = LSGrayColor();
        self.addressBarView.addressBarTextView.userInteractionEnabled = NO;
    }
}

- (void)selectParticipant:(id<LYRUIParticipant>)participant
{
    // Create a new token and add it to the token array
    LYRUIAddressToken *token = [self createTokenForParticipant:participant];
    [self addToken:token];
    
    // Inform delegate of selection
    [self.delegate addressBarViewController:self didSelectParticipant:participant];
    [self searchEnded];
    
    // Ensure Text View is always scrolled to the bottom after selection
    NSRange range = NSMakeRange(self.addressBarView.addressBarTextView.text.length - 1, 1);
    [self.addressBarView.addressBarTextView  scrollRangeToVisible:range];
}

#pragma mark - Token Configuration Methods

- (LYRUIAddressToken *)createTokenForParticipant:(id<LYRUIParticipant>)participant
{
    // Tokenize the participant and add to the token array
    NSRange range = NSMakeRange([self addressLabel].length, participant.fullName.length + 1);
    LYRUIAddressToken *token = [LYRUIAddressToken tokenWithParticipant:participant range:range];
    return token;
}

- (void)addToken:(LYRUIAddressToken *)token
{
    // Add token to the token array
    [self.addressTokens addObject:token];
    
    // Reset the text of the Address Bar text view on every selection
    [self setAddressBarText];
    
    // Tokens must be mapped against their indexes. Used to look up tokens in response to tap events
    [self mapAddressTokenIndex];
    
    self.selectedParticipants = [NSSet setWithArray:[self.addressTokens valueForKey:@"participant"]];
    
    [self sizeAddressBarView];
}

- (void)removeToken:(LYRUIAddressToken *)token
{
    // We are going to reset address bar text so clear it
    self.addressBarView.addressBarTextView.text = @"";
    self.searchFilterIndex = 0;
    
    // Remove token from the token array
    [self.addressTokens removeObject:token];
    
    // Need to re-calculate token ranges after removal
    [self mapTokenRanges];
    
    self.selectedParticipants = [NSSet setWithArray:[self.addressTokens valueForKey:@"participant"]];
    
    [self.delegate addressBarViewController:self didRemoveParticipant:token.participant];
    [self sizeAddressBarView];
}

- (void)setAddressBarText;
{
    self.addressBarView.addressBarTextView.text = [self addressLabel];
    self.searchFilterIndex = self.addressBarView.addressBarTextView.text.length;
}

- (NSString *)addressLabel
{
    NSString *addressLabel = @"";
    for (LYRUIAddressToken *token in self.addressTokens) {
        NSString *participantName = [NSString stringWithFormat:@"%@, ", token.participant.fullName];
        addressLabel = [addressLabel stringByAppendingString:participantName];
    }
    return addressLabel;
}

- (void)mapAddressTokenIndex
{
    [self.addressTokenIndex removeAllObjects];
    for (LYRUIAddressToken *token in self.addressTokens) {
        NSString *participantName = [NSString stringWithFormat:@"%@,", token.participant.fullName];
        for (int i = 0; i < participantName.length; i++){
            [self.addressTokenIndex addObject:token];
        }
        // Add `NSNull` object to represent spaces
        [self.addressTokenIndex addObject:[NSNull null]];
    }
}

- (void)mapTokenRanges
{
    NSMutableArray *tempTokens = [NSMutableArray arrayWithArray:self.addressTokens];
    if (!tempTokens.count) {
        [self searchEnded];
    } else {
        [self.addressTokens removeAllObjects];
        for (LYRUIAddressToken *token in tempTokens) {
            [self addToken:[self createTokenForParticipant:token.participant]];
        }
        [self.delegate addressBarViewControllerDidEndSearching:self];
        [self searchEnded];
    }
}

#pragma mark - Address Bar Text View Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
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
    // If user is deleting...
    if ([text isEqualToString:@""]) {
        // If we have a token maping for the current range...
        if (self.addressTokenIndex.count > range.location) {
            // If the user is not deleting a blank space we, need to get a token
            if (![[self.addressTokenIndex objectAtIndex:range.location] isKindOfClass:[NSNull class]]) {
                LYRUIAddressToken *token = [self.addressTokenIndex objectAtIndex:range.location];
                // If range.length is 1, we need to select the token
                if (range.length == 1) {
                    [self.addressBarView.addressBarTextView setSelectedRange:token.range];
                    return NO;
                } else {
                    // If range.length is more than 1, we need to delete the token
                    [self removeToken:token];
                }
            }
        }
    }
    return YES;
}

- (void)sizeAddressBarView
{
     [self.addressBarView invalidateIntrinsicContentSize];
    NSLog(@"Content View %f", self.addressBarView.addressBarTextView.contentSize.height);
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self sizeAddressBarView];
    // If no text, reset search bar
    if (!textView.text.length) {
        [self searchEnded];
        self.searchFilterIndex = 0;
    } else {
        NSString *searchText = [self filterTextViewText:textView];
        if (searchText) {
            self.tableView.alpha = 1.0f;
            [self.dataSource searchForParticipantsMatchingText:searchText completion:^(NSSet *participants) {
                self.tableView.alpha = 1.0;
                self.participants = [self filteredParticipants:participants];
                [self.tableView reloadData];
                [self.delegate addressBarViewControllerDidBeginSearching:self];
                [self updateControllerHeight];
            }];
        }
    }
}

- (NSString *)filterTextViewText:(UITextView *)textView
{
    if (textView.text.length >= self.searchFilterIndex) {
        return [[textView.text substringFromIndex:self.searchFilterIndex] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    } else if ((textView.text.length + 1) == self.searchFilterIndex){
        return nil;
    }
    return nil;
}

- (NSArray *)filteredParticipants:(NSSet *)participants
{
    NSMutableArray *mutableParticipants = [[participants allObjects] mutableCopy];
    for (LYRUIAddressToken *token in self.addressTokens) {
        [mutableParticipants removeObject:token.participant];
    }
    return mutableParticipants;
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
    
    // Check if we have a mapping for the tap index
    if ((self.addressTokenIndex.count > tapIndex )) {
        // If the mapping is `NSNull` object, select the end last index of textView
        if ([[self.addressTokenIndex objectAtIndex:tapIndex] isKindOfClass:[NSNull class]]) {
            [self.addressBarView.addressBarTextView setSelectedRange:NSMakeRange(self.addressBarView.addressBarTextView.text.length, 0)];
        } else {
            // If the mapping is a token, select the entire token
            LYRUIAddressToken *token = [self.addressTokenIndex objectAtIndex:tapIndex];
            [self.addressBarView.addressBarTextView setSelectedRange:token.range];
        }
    } else {
        [self.addressBarView.addressBarTextView setSelectedRange:NSMakeRange(self.addressBarView.addressBarTextView.text.length, 0)];
    }
}

- (void)contactButtonTapped:(UIButton *)sender
{
    [self.delegate addressBarViewController:self didTapAddContactsButton:sender];
}

- (void)searchEnded
{
    // Search resets on selection. Inform delegate
    [self resetControllerHeight];
    [self.delegate addressBarViewControllerDidEndSearching:self];
    self.participants = nil;
    self.tableView.alpha = 0.0f;
}

@end
