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
@property (nonatomic) NSMutableArray *indexMapping;
@property (nonatomic) NSMutableArray *addressTokens;
@property (nonatomic) BOOL isSearching;


@end

@implementation LYRUIAddressBarViewController

static NSString *const LSParticpantCellIdentifier = @"participantCellIdentifier";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = LSAddressBarGray();
    
    self.isSearching = NO;
    
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
    [self.view addSubview:self.tableView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addressBarTextViewTapped:)];
    [self.addressBarView.addressBarTextView addGestureRecognizer:gestureRecognizer];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LSParticpantCellIdentifier];
    
    self.searchFilterIndex = 0;
    self.indexMapping = [[NSMutableArray alloc] init];
    self.addressTokens = [[NSMutableArray alloc] init];
    
    [self updateConstraints];
}

- (void)updateConstraints
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:4]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.addressBarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:34]];
    
    [super updateViewConstraints];
}

- (void)updateWithTableViewConstraints
{
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:-34]];
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
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Add selected participant to the text view
    id<LYRUIParticipant>participant = [self.participants objectAtIndex:indexPath.row];
    [self selectParticipant:participant];
}

#pragma mark - Public Method Implementation

- (void)setPermanent
{
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

- (void)selectParticipant:(id<LYRUIParticipant>)participant
{
    [self addTokenForParticipant:participant];
    
    // Inform conversation view of selection
    NSSet *participantIdentifiers = [NSSet setWithArray:[self.addressTokens valueForKeyPath:@"participant.userID"]];
    [self.delegate addressBarViewController:self didSelectParticipants:participantIdentifiers];
    
    // Ensure Text View is always scrolled to the bottom after selection
    NSRange range = NSMakeRange(self.addressBarView.addressBarTextView.text.length - 1, 1);
    [self.addressBarView.addressBarTextView  scrollRangeToVisible:range];
}

#pragma mark - Token Configuration Methods

- (void)addTokenForParticipant:(id<LYRUIParticipant>)participant
{
    // Tokenize the participant and add to the token array
    NSRange range = NSMakeRange([self addressLabel].length, participant.fullName.length + 1);
    LYRUIAddressToken *token = [LYRUIAddressToken tokenWithParticipant:participant range:range];
    [self addToken:token];
}

- (void)addToken:(LYRUIAddressToken *)token
{
    // Add token to the token array
    [self.addressTokens addObject:token];
    
    // Reset the text of the Address Bar text view on every selection
    [self setAddressBarText];
    
    // Tokens must be mapped against their indexes. Used to look up tokens in response to tap events
    [self mapTokenIndexes];
}

- (void)removeToken:(LYRUIAddressToken *)token
{
    // Remove token from the token array
    [self.addressTokens removeObject:token];
    
    // We dont know which token was removed, so we just re-index all ranges
    [self mapTokenRanges];
}

- (void)setAddressBarText;
{
    self.addressBarView.addressBarTextView.text = [self addressLabel];
    self.searchFilterIndex = self.addressBarView.addressBarTextView.text.length;
    self.participants = nil;
    [self.delegate addressBarViewControllerDidEndSearching:self];
    self.tableView.alpha = 0.0f;
    self.isSearching = NO;
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

- (void)mapTokenIndexes
{
    [self.indexMapping removeAllObjects];
    for (LYRUIAddressToken *token in self.addressTokens) {
        NSString *participantName = [NSString stringWithFormat:@"%@,", token.participant.fullName];
        for (int i = 0; i < participantName.length; i++){
            [self.indexMapping addObject:token];
        }
        [self.indexMapping addObject:[NSNull null]];
    }
}

- (void)mapTokenRanges
{
    self.addressBarView.addressBarTextView.text = @"";
    self.searchFilterIndex = 0;
    NSMutableArray *tempTokens = [NSMutableArray arrayWithArray:self.addressTokens];
    if (!tempTokens.count) {
        [self.delegate addressBarViewController:self didSelectParticipants:nil];
        [self.delegate addressBarViewControllerDidEndSearching:self];
    } else {
        [self.addressTokens removeAllObjects];
        for (LYRUIAddressToken *token in tempTokens) {
            [self addTokenForParticipant:token.participant];
        }
        if (self.addressTokens.count > 0) {
            NSSet *participantIdentifiers = [NSSet setWithArray:[self.addressTokens valueForKeyPath:@"participant.userID"]];
            [self.delegate addressBarViewController:self didSelectParticipants:participantIdentifiers];
        }
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
    if ([text isEqualToString:@""]) {
        if (self.indexMapping.count > range.location) {
            if (![[self.indexMapping objectAtIndex:range.location] isKindOfClass:[NSNull class]]) {
                LYRUIAddressToken *token = [self.indexMapping objectAtIndex:range.location];
                if (range.length == 1) {
                    [self.addressBarView.addressBarTextView setSelectedRange:token.range];
                    return NO;
                } else {
                    [self removeToken:token];
                }
            }
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (!textView.text.length) {
        self.searchFilterIndex = 0;
        [self.delegate addressBarViewControllerDidEndSearching:self];
        self.tableView.alpha = 1.0f;
    } else {
        NSString *searchText = [self filterTextViewText:textView];
        if (searchText) {
            [self.dataSource searchForParticipantsMatchingText:searchText completion:^(NSSet *participants) {
                if (!self.isSearching) {
                    [self.delegate addressBarViewControllerDidBeginSearching:self];
                    self.tableView.alpha = 1.0;
                    [self updateWithTableViewConstraints];
                }
                self.isSearching = YES;
                self.participants = [self filteredParticipants:participants];
                [self.tableView reloadData];
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
    if (!self.addressBarView.addressBarTextView.isFirstResponder) {
        [self.addressBarView.addressBarTextView  becomeFirstResponder];
        [self setAddressBarText];
    }
    UITextView *textView = (UITextView *)recognizer.view;
    CGPoint point = [recognizer locationInView:textView];
    UITextPosition *tapPosition = [textView closestPositionToPoint:point];
    NSInteger tapIndex = [self.addressBarView.addressBarTextView offsetFromPosition:self.addressBarView.addressBarTextView.beginningOfDocument toPosition:tapPosition];
    if ((self.indexMapping.count > tapIndex )) {
        LYRUIAddressToken *token = [self.indexMapping objectAtIndex:tapIndex];
        if (![token isKindOfClass:[NSNull class]]) {
            [self.addressBarView.addressBarTextView setSelectedRange:token.range];
        } else {
            [self.addressBarView.addressBarTextView setSelectedRange:NSMakeRange(self.addressBarView.addressBarTextView.text.length, 0)];
        }
    } else {
        [self.addressBarView.addressBarTextView setSelectedRange:NSMakeRange(self.addressBarView.addressBarTextView.text.length, 0)];
    }
}

- (void)contactButtonTapped:(UIButton *)sender
{
    [self.delegate addressBarViewController:self didTapAddContactsButton:sender];
}

@end
