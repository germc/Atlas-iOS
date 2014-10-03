//
//  LYRUIParticipantListViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIParticipantTableViewController.h"
#import "LYRUIPaticipantSectionHeaderView.h"
#import "LYRUISelectionIndicator.h"
#import "LYRUIConstants.h"
#import "LYRUIParticipantPickerController.h"

@interface LYRUIParticipantTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic) NSArray *sortedContactKeys;
@property (nonatomic) NSDictionary *sortedParticipants;
@property (nonatomic) NSDictionary *filteredParticipants;
@property (nonatomic) NSMutableSet *selectedParticipants;
@property (nonatomic) UISearchDisplayController *searchController;
@property (nonatomic) UISearchBar *searchBar;

@end

@implementation LYRUIParticipantTableViewController

static NSString *const LYRParticipantCellIdentifier = @"participantCellIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _selectedParticipants = [[NSMutableSet alloc] init];
        [self configureAppearance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Configure TableView
    self.tableView.allowsMultipleSelection = self.allowsMultipleSelection;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionFooterHeight = 0.0;
    
    // Configure Search Bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    self.searchBar.accessibilityLabel = @"Search Bar";
    self.searchBar.delegate = self;
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
    self.tableView.tableHeaderView = self.searchBar;

    //Configure title
    self.title = @"Participants";
    self.accessibilityLabel = @"Participants";
    
    // Left bar button item is the text Cancel
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(cancelButtonTapped)];
    cancelButtonItem.accessibilityLabel = @"Cancel";
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    // Right bar button item is the text Done
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(doneButtonTapped)];
    doneButtonItem.accessibilityLabel = @"Done";
    self.navigationItem.rightBarButtonItem = doneButtonItem;
    self.filteredParticipants = self.sortedParticipants;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.rowHeight = self.rowHeight;
    [self.tableView registerClass:self.participantCellClass forCellReuseIdentifier:LYRParticipantCellIdentifier];
    self.searchController.searchResultsTableView.rowHeight = self.rowHeight;
    [self.searchController.searchResultsTableView registerClass:self.participantCellClass forCellReuseIdentifier:LYRParticipantCellIdentifier];
}

- (void)setParticipants:(NSSet *)participants
{
    if (_participants != participants) {
        _participants = participants;
        _sortedParticipants = [self sortAndGroupContactListByAlphabet:participants];
    }
}

#pragma mark public Boolean configurations
- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    self.tableView.allowsMultipleSelection = allowsMultipleSelection;
}

- (NSDictionary *)currentDataArray
{
    if (self.isSearching) {
        return self.filteredParticipants;
    } else {
        return self.sortedParticipants;
    }
}

- (BOOL)isSearching
{
    return self.searchController.active;
}

#pragma mark - UISearchDisplayDelegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    //
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterParticipantsWithSearchText:searchText completion:^(NSDictionary *participants) {
        self.filteredParticipants = participants;
        [self reloadContacts];
    }];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self currentDataArray] allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:section];
    return [[[self currentDataArray] objectForKey:key] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    id<LYRUIParticipant> participant = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];

    UITableViewCell <LYRUIParticipantPresenting> *participantCell = [self.tableView dequeueReusableCellWithIdentifier:LYRParticipantCellIdentifier];
    [participantCell presentParticipant:participant];
    [participantCell shouldDisplaySelectionIndicator:TRUE];
    return participantCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:section];
    return [[LYRUIPaticipantSectionHeaderView alloc] initWithKey:key];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[tableView indexPathsForSelectedRows] containsObject:indexPath]) {
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    } else {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    id<LYRUIParticipant> participant = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];
    [self.delegate participantTableViewController:self didSelectParticipant:participant];
}

#pragma mark UIBarButtonItem implementation methods

- (void)cancelButtonTapped
{
    [self.delegate participantTableViewControllerDidSelectCancelButton];
}

- (void)doneButtonTapped
{
    for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
         NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
        id<LYRUIParticipant> participant = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];
        [self.selectedParticipants addObject:participant];
    }
    [self.delegate participantTableViewControllerDidSelectDoneButtonWithSelectedParticipants:self.selectedParticipants];
}

- (void)reloadContacts
{
    if (self.isSearching) {
        [self.searchController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

- (void)filterParticipantsWithSearchText:(NSString *)searchText completion:(void(^)(NSDictionary *participants))completion
{
    [self.delegate participantTableViewController:self didSearchWithString:searchText completion:^(NSSet *filteredParticipants) {
        completion([self sortAndGroupContactListByAlphabet:filteredParticipants]);
    }];
}

- (NSArray *)sortedContactKeys
{
    NSMutableArray *mutableKeys = [NSMutableArray arrayWithArray:[[self currentDataArray] allKeys]];
    [mutableKeys sortUsingSelector:@selector(compare:)];
    _sortedContactKeys = mutableKeys;
    return _sortedContactKeys;
}

- (NSDictionary *)sortAndGroupContactListByAlphabet:(NSSet *)participants
{
    NSArray *sortedParticipants;
    
    switch (self.sortType) {
        case LYRUIParticipantPickerControllerSortTypeFirst:
            sortedParticipants = [[participants allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]]];
            break;
            
        case LYRUIParticipantPickerControllerSortTypeLast:
            sortedParticipants = [[participants allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]]];
            break;
            
        default:
            break;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (id<LYRUIParticipant>participant in sortedParticipants) {
        NSString *sortName;
        switch (self.sortType) {
            case LYRUIParticipantPickerControllerSortTypeFirst:
                sortName = participant.firstName;
                break;
                
            case LYRUIParticipantPickerControllerSortTypeLast:
                sortName = participant.lastName;
                break;
                
            default:
                break;
        }
        NSString *firstLetter = [[sortName substringToIndex:1] uppercaseString];
        NSMutableArray *letterList = [dict objectForKey:firstLetter];
        if (!letterList) {
            letterList = [NSMutableArray array];
        }
        [letterList addObject:participant];
        [dict setObject:letterList forKey:firstLetter];
    }
    return dict;
}

- (void)configureAppearance
{
    [[LYRUIParticipantTableViewCell appearance] setTitleColor:[UIColor blackColor]];
    [[LYRUIParticipantTableViewCell appearance] setTitleFont:[UIFont systemFontOfSize:14]];
}

@end
