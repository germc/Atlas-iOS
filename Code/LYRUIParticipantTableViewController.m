//
//  LYRUIParticipantListViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIParticipantTableViewController.h"
#import "LYRUIPaticipantSectionHeaderView.h"
#import "LYRUIConstants.h"
#import "LYRUIParticipantPickerController.h"
#import "LYRUIAvatarImageView.h"

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
    self.tableView.sectionFooterHeight = 0.0;
    self.tableView.accessibilityIdentifier = @"Participant TableView Controller";
    
    // Configure Search Bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [self.searchBar sizeToFit];
    self.searchBar.translucent = NO;
    self.searchBar.accessibilityLabel = @"Search Bar";
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;

    //Configure title
    self.title = @"Participants";
    
    // Left bar button item is the text Cancel
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(cancelButtonTapped)];
    cancelButtonItem.accessibilityLabel = @"Cancel";
    self.navigationItem.rightBarButtonItem = cancelButtonItem;
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
    self.searchDisplayController.searchResultsTableView.allowsMultipleSelection = TRUE;
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
    self.filteredParticipants = self.sortedParticipants;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterParticipantsWithSearchText:searchText completion:^(NSDictionary *participants) {
        self.filteredParticipants = participants;
        [self reloadContacts];
    }];
}

#pragma mark - Table View Data Source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self sortedContactKeys];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[self sortedContactKeys] indexOfObject:title];
}

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
    UITableViewCell <LYRUIParticipantPresenting> *participantCell = [self.tableView dequeueReusableCellWithIdentifier:LYRParticipantCellIdentifier];
    [self configureCell:participantCell atIndexPath:indexPath];
    return participantCell;
}

- (void)configureCell:(UITableViewCell<LYRUIParticipantPresenting> *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    id<LYRUIParticipant> participant = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];
    [cell presentParticipant:participant];
    [cell updateWithSortType:self.sortType];
    [cell shouldShowAvatarImage:YES];
}

#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    id<LYRUIParticipant> participant = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];

    if ([self.selectedParticipants containsObject:participant]) {
        [tableView selectRowAtIndexPath:indexPath animated:TRUE scrollPosition:UITableViewScrollPositionNone];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:section];
    return [[LYRUIPaticipantSectionHeaderView alloc] initWithKey:key];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    id<LYRUIParticipant> participant = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];
    if ([[tableView indexPathsForSelectedRows] containsObject:indexPath]) {
        [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
        if ([self.selectedParticipants containsObject:participant]) {
            [self.selectedParticipants removeObject:participant];
        }
    } else {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[self sortedContactKeys] objectAtIndex:indexPath.section];
    id<LYRUIParticipant> participant = [[[self currentDataArray] objectForKey:key] objectAtIndex:indexPath.row];
    [self.selectedParticipants addObject:participant];
    [self.delegate participantTableViewController:self didSelectParticipant:participant];
}

#pragma mark - UIBarButtonItem implementation methods

- (void)cancelButtonTapped
{
    [self.delegate participantTableViewControllerDidCancel:self];
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
    [[LYRUIParticipantTableViewCell appearance] setBoldTitleFont:[UIFont boldSystemFontOfSize:14]];
    
    [[LYRUIAvatarImageView appearance] setBackgroundColor:LYRUIGrayColor()];
    [[LYRUIAvatarImageView appearance] setInitialsColor:[UIColor blackColor]];
    [[LYRUIAvatarImageView appearance] setInitialsFont:LYRUILightFont(14)];
}

@end
