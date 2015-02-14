//
//  LYRUIParticipantListViewController.m
//  Atlas
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
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

#import "LYRUIParticipantTableViewController.h"
#import "LYRUIParticipantTableDataSet.h"
#import "LYRUIParticipantSectionHeaderView.h"
#import "LYRUIConstants.h"
#import "LYRUIAvatarImageView.h"

static NSString *const LYRUIParticipantTableSectionHeaderIdentifier = @"LYRUIParticipantTableSectionHeaderIdentifier";
static NSString *const LYRUIParticipantCellIdentifier = @"LYRUIParticipantCellIdentifier";

@interface LYRUIParticipantTableViewController () <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic) LYRUIParticipantTableDataSet *unfilteredDataSet;
@property (nonatomic) LYRUIParticipantTableDataSet *filteredDataSet;
@property (nonatomic) NSMutableSet *selectedParticipants;
@property (nonatomic) UISearchDisplayController *searchController;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) BOOL hasAppeared;

@end

@implementation LYRUIParticipantTableViewController

NSString *const LYRUIParticipantTableViewAccessibilityIdentifier = @"Participant Table View Controller";

+ (instancetype)participantTableViewControllerWithParticipants:(NSSet *)participants sortType:(LYRUIParticipantPickerSortType)sortType
{
    return  [[self alloc] initWithParticipants:participants sortType:sortType];
}

- (id)initWithParticipants:(NSSet *)participants sortType:(LYRUIParticipantPickerSortType)sortType
{
    NSAssert(participants, @"Participants cannot be nil");
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _participants = participants;
        _sortType = sortType;
        [self lyr_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (void)lyr_commonInit
{
    _cellClass = [LYRUIParticipantTableViewCell class];
    _rowHeight = 48;
    _allowsMultipleSelection = YES;
    _selectedParticipants = [[NSMutableSet alloc] init];
}

- (void)loadView
{
    self.view = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = self.allowsMultipleSelection;
    self.tableView.accessibilityIdentifier = LYRUIParticipantTableViewAccessibilityIdentifier;
    self.tableView.sectionFooterHeight = 0;
    self.tableView.sectionHeaderHeight = 20;
    [self.tableView registerClass:[LYRUIParticipantSectionHeaderView class] forHeaderFooterViewReuseIdentifier:LYRUIParticipantTableSectionHeaderIdentifier];
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.sortType) self.sortType = LYRUIParticipantPickerSortTypeFirstName;
    if (!self.hasAppeared) {
        self.tableView.rowHeight = self.rowHeight;
        self.tableView.allowsMultipleSelection = self.allowsMultipleSelection;
        [self.tableView registerClass:self.cellClass forCellReuseIdentifier:LYRUIParticipantCellIdentifier];
        self.unfilteredDataSet = [LYRUIParticipantTableDataSet dataSetWithParticipants:self.participants sortType:self.sortType];
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.hasAppeared = YES;
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

- (void)setCellClass:(Class<LYRUIParticipantPresenting>)cellClass
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change cell class after view has been presented" userInfo:nil];
    }
    _cellClass = cellClass;
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

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.allowsMultipleSelection = self.allowsMultipleSelection;
    tableView.sectionHeaderHeight = self.tableView.sectionHeaderHeight;
    tableView.rowHeight = self.rowHeight;
    [tableView registerClass:self.cellClass forCellReuseIdentifier:LYRUIParticipantCellIdentifier];
    [tableView registerClass:[LYRUIParticipantSectionHeaderView class] forHeaderFooterViewReuseIdentifier:LYRUIParticipantTableSectionHeaderIdentifier];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.delegate participantTableViewController:self didSearchWithString:searchString completion:^(NSSet *filteredParticipants) {
        if (![searchString isEqualToString:controller.searchBar.text]) return;
        self.filteredDataSet = [LYRUIParticipantTableDataSet dataSetWithParticipants:filteredParticipants sortType:self.sortType];
        UITableView *tableView = controller.searchResultsTableView;
        [tableView reloadData];
        for (id<LYRUIParticipant> participant in self.selectedParticipants) {
            NSIndexPath *indexPath = [self indexPathForParticipant:participant inTableView:tableView];
            if (!indexPath) continue;
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }];
    return NO;
}

#pragma mark - UITableViewDataSource

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
    UITableViewCell <LYRUIParticipantPresenting> *participantCell = [tableView dequeueReusableCellWithIdentifier:LYRUIParticipantCellIdentifier];
    [self configureCell:participantCell atIndexPath:indexPath forTableView:tableView];
    return participantCell;
}

#pragma mark - Cell Configuration

- (void)configureCell:(UITableViewCell<LYRUIParticipantPresenting> *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView
{
    id<LYRUIParticipant> participant = [self participantForTableView:tableView atIndexPath:indexPath];
    [cell presentParticipant:participant withSortType:self.sortType shouldShowAvatarItem:YES];
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    LYRUIParticipantTableDataSet *dataSet = [self dataSetForTableView:tableView];
    NSString *sectionName = dataSet.sectionTitles[section];
    LYRUIParticipantSectionHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:LYRUIParticipantTableSectionHeaderIdentifier];
    headerView.sectionHeaderLabel.text = sectionName;
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<LYRUIParticipant> participant = [self participantForTableView:tableView atIndexPath:indexPath];
    [self.selectedParticipants addObject:participant];
    if (tableView != self.tableView) {
        NSIndexPath *unfilteredIndexPath = [self indexPathForParticipant:participant inTableView:self.tableView];
        [self.tableView selectRowAtIndexPath:unfilteredIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    [self.delegate participantTableViewController:self didSelectParticipant:participant];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<LYRUIParticipant> participant = [self participantForTableView:tableView atIndexPath:indexPath];
    [self.selectedParticipants removeObject:participant];
    if (tableView != self.tableView) {
        NSIndexPath *unfilteredIndexPath = [self indexPathForParticipant:participant inTableView:self.tableView];
        [self.tableView deselectRowAtIndexPath:unfilteredIndexPath animated:NO];
    }
    if ([self.delegate respondsToSelector:@selector(participantTableViewController:didDeselectParticipant:)]) {
        [self.delegate participantTableViewController:self didDeselectParticipant:participant];
    }
}

#pragma mark - Helpers

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
