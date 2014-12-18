//
//  LYRUIParticipantListViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import "LYRUIParticipantTableViewController.h"
#import "LYRUIParticipantTableDataSet.h"
#import "LYRUIPaticipantSectionHeaderView.h"
#import "LYRUIConstants.h"
#import "LYRUIParticipantPickerController.h"
#import "LYRUIAvatarImageView.h"

@interface LYRUIParticipantTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic) LYRUIParticipantTableDataSet *unfilteredDataSet;
@property (nonatomic) LYRUIParticipantTableDataSet *filteredDataSet;
@property (nonatomic) NSMutableSet *selectedParticipants;
@property (nonatomic) UISearchDisplayController *searchController;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) BOOL hasAppeared;

@end

@implementation LYRUIParticipantTableViewController

static NSString *const LYRParticipantCellIdentifier = @"participantCellIdentifier";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _selectedParticipants = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.allowsMultipleSelection = self.allowsMultipleSelection;
    self.tableView.sectionFooterHeight = 0.0;
    self.tableView.accessibilityIdentifier = @"Participant TableView Controller";
    
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

    self.title = @"Participants";
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped)];
    cancelButtonItem.accessibilityLabel = @"Cancel";
    self.navigationItem.rightBarButtonItem = cancelButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!self.hasAppeared) {
        self.unfilteredDataSet = [LYRUIParticipantTableDataSet dataSetWithParticipants:self.participants sortType:self.sortType];
        self.tableView.rowHeight = self.rowHeight;
        self.tableView.allowsMultipleSelection = self.allowsMultipleSelection;
        [self.tableView registerClass:self.participantCellClass forCellReuseIdentifier:LYRParticipantCellIdentifier];
        self.hasAppeared = YES;
    }

    [super viewWillAppear:animated];
}

#pragma mark - Public Configuration

- (void)setParticipants:(NSSet *)participants
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change participants after view has been presented" userInfo:nil];
    }
    _participants = participants;
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change multiple selection mode after view has been presented" userInfo:nil];
    }
    _allowsMultipleSelection = allowsMultipleSelection;
}

- (void)setParticipantCellClass:(Class<LYRUIParticipantPresenting>)participantCellClass
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change cell class after view has been presented" userInfo:nil];
    }
    _participantCellClass = participantCellClass;
}

- (void)setRowHeight:(CGFloat)rowHeight
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change row height after view has been presented" userInfo:nil];
    }
    _rowHeight = rowHeight;
}

- (void)setSortType:(LYRUIParticipantPickerSortType)sortType
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change sort type after view has been presented" userInfo:nil];
    }
    _sortType = sortType;
}

#pragma mark - UISearchDisplayDelegate Methods

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.allowsMultipleSelection = self.allowsMultipleSelection;
    tableView.rowHeight = self.rowHeight;
    [tableView registerClass:self.participantCellClass forCellReuseIdentifier:LYRParticipantCellIdentifier];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.delegate participantTableViewController:self didSearchWithString:searchString completion:^(NSSet *filteredParticipants) {
        self.filteredDataSet = [LYRUIParticipantTableDataSet dataSetWithParticipants:filteredParticipants sortType:self.sortType];
        [controller.searchResultsTableView reloadData];
    }];
    return NO;
}

#pragma mark - Table View Data Source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    LYRUIParticipantTableDataSet *dataSet = [self dataSetForTableView:tableView];
    return dataSet.sectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    LYRUIParticipantTableDataSet *dataSet = [self dataSetForTableView:tableView];
    return [dataSet.sectionTitles indexOfObject:title];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    LYRUIParticipantTableDataSet *dataSet = [self dataSetForTableView:tableView];
    return dataSet.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LYRUIParticipantTableDataSet *dataSet = [self dataSetForTableView:tableView];
    return [dataSet numberOfParticipantsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell <LYRUIParticipantPresenting> *participantCell = [tableView dequeueReusableCellWithIdentifier:LYRParticipantCellIdentifier];
    [self configureCell:participantCell atIndexPath:indexPath forTableView:tableView];
    return participantCell;
}

- (void)configureCell:(UITableViewCell<LYRUIParticipantPresenting> *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView
{
    id<LYRUIParticipant> participant = [self participantForTableView:tableView atIndexPath:indexPath];
    [cell presentParticipant:participant];
    [cell updateWithSortType:self.sortType];
    [cell shouldShowAvatarImage:YES];
}

#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<LYRUIParticipant> participant = [self participantForTableView:tableView atIndexPath:indexPath];
    if ([self.selectedParticipants containsObject:participant]) {
        [tableView selectRowAtIndexPath:indexPath animated:TRUE scrollPosition:UITableViewScrollPositionNone];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    LYRUIParticipantTableDataSet *dataSet = [self dataSetForTableView:tableView];
    NSString *sectionName = dataSet.sectionTitles[section];
    return [[LYRUIPaticipantSectionHeaderView alloc] initWithKey:sectionName];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<LYRUIParticipant> participant = [self participantForTableView:tableView atIndexPath:indexPath];
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
    id<LYRUIParticipant> participant = [self participantForTableView:tableView atIndexPath:indexPath];
    [self.selectedParticipants addObject:participant];
    [self.delegate participantTableViewController:self didSelectParticipant:participant];
}

#pragma mark - UIBarButtonItem implementation methods

- (void)cancelButtonTapped
{
    [self.delegate participantTableViewControllerDidCancel:self];
}

- (LYRUIParticipantTableDataSet *)dataSetForTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return self.unfilteredDataSet;
    } else {
        return self.filteredDataSet;
    }
}

- (id<LYRUIParticipant>)participantForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    LYRUIParticipantTableDataSet *dataSet = [self dataSetForTableView:tableView];
    id<LYRUIParticipant> participant = [dataSet participantAtIndexPath:indexPath];
    return participant;
}

- (NSIndexPath *)indexPathForParticipant:(id<LYRUIParticipant>)participant inTableView:(UITableView *)tableView
{
    LYRUIParticipantTableDataSet *dataSet = [self dataSetForTableView:tableView];
    NSIndexPath *indexPath = [dataSet indexPathForParticipant:participant];
    return indexPath;
}

@end
