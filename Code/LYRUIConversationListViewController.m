//
//  LYRUIConversationListViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "LYRUIConversationListViewController.h"
#import "LYRUIDataSourceChange.h"
#import "LYRUIConstants.h"

@interface LYRUIConversationListViewController () <UISearchBarDelegate, UISearchDisplayDelegate, LYRQueryControllerDelegate>

@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UISearchDisplayController *searchController;
@property (nonatomic) NSMutableArray *filteredConversations;
@property (nonatomic) NSPredicate *searchPredicate;
@property (nonatomic) LYRQueryController *queryController;
@property (nonatomic) NSMutableArray *objectChages;
@property (nonatomic) BOOL isOnScreen;

@end

@implementation LYRUIConversationListViewController

static NSString *const LYRUIConversationCellReuseIdentifier = @"conversationCellReuseIdentifier";

+ (instancetype)conversationListViewControllerWithLayerClient:(LYRClient *)layerClient
{
    NSAssert(layerClient, @"layerClient cannot be nil");
    return [[self alloc] initConversationlistViewControllerWithLayerClient:layerClient];
}

- (id)initConversationlistViewControllerWithLayerClient:(LYRClient *)layerClient
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)  {
        // Set property from designated initializer
        _layerClient = layerClient;
        
        // Set default configuration for public configuration properties
        _cellClass = [LYRUIConversationTableViewCell class];
        _displaysConversationImage = NO;
        _allowsEditing = YES;
        _rowHeight = 72.0f;
    }
    return self;
}

- (id) init
{
    [NSException raise:NSInternalInconsistencyException format:@"Failed to call designated initializer"];
    return nil;
}

#pragma mark - VC Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Accessibility
    self.title = @"Messages";
    self.accessibilityLabel = @"Messages";
    self.tableView.accessibilityLabel = @"Conversation List";
    
    // Search Bar Setup
//    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
//    self.searchBar.accessibilityLabel = @"Search Bar";
//    self.searchBar.delegate = self;
//    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
//    self.searchController.delegate = self;
//    self.searchController.searchResultsDelegate = self;
//    self.searchController.searchResultsDataSource = self;

    // Set Search Bar as Table View Header
    //self.tableView.tableHeaderView = self.searchBar;
    //[self.tableView setContentOffset:CGPointMake(0, 44)];

    // DataSoure
    [self setupConversationDataSource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isOnScreen = TRUE;
    
    // Set public configuration properties once view has loaded
    [self.tableView registerClass:self.cellClass forCellReuseIdentifier:LYRUIConversationCellReuseIdentifier];
    [self.searchController.searchResultsTableView registerClass:self.cellClass forCellReuseIdentifier:LYRUIConversationCellReuseIdentifier];
    
    self.tableView.rowHeight = self.rowHeight;
    self.searchController.searchResultsTableView.rowHeight = self.rowHeight;
    
    if (self.allowsEditing) {
        [self addEditButton];
    }
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.isOnScreen = NO;
}

#pragma mark - Public setters

- (void)setAllowsEditing:(BOOL)allowsEditing
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot set editing mode after the view has been loaded" userInfo:nil];
    }
    _allowsEditing = allowsEditing;

    if (self.navigationItem.leftBarButtonItem && !allowsEditing) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)setCellClass:(Class<LYRUIConversationPresenting>)cellClass
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot set cellClass after the view has been loaded" userInfo:nil];
    }
    
    if (!class_conformsToProtocol(cellClass, @protocol(LYRUIConversationPresenting))) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cell class cellClass must conform to LYRUIConversationPresenting Protocol" userInfo:nil];

    }
    _cellClass = cellClass;
}

- (void)setRowHeight:(CGFloat)rowHeight
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot set rowHeight after the view has been loaded" userInfo:nil];
    }
    _rowHeight = rowHeight;
}

- (void)setDisplaysConversationImage:(BOOL)displaysConversationImage
{
    if (self.isOnScreen) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot set displaysConversationImage after the view has been loaded" userInfo:nil];
    }
    _displaysConversationImage = displaysConversationImage;
}

#pragma mark - Navigation Bar Edit Button

- (void)addEditButton
{
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(editButtonTapped)];
    editButtonItem.accessibilityLabel = @"Edit Button";
    self.navigationItem.leftBarButtonItem = editButtonItem;
}


- (void)setupConversationDataSource
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.receivedAt" ascending:NO]];
    
    self.queryController = [self.layerClient queryControllerWithQuery:query];
    self.queryController.delegate = self;
    NSError *error = nil;
    BOOL success = [self.queryController execute:&error];
    if (!success) NSLog(@"LayerKit failed to execute query with error: %@", error);
    [self.tableView reloadData];
}

- (void)reloadConversations
{
    if (self.searchController.active) {
        [self.searchController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

- (BOOL)isSearching
{
    return self.searchController.active;
}

#pragma mark - UISearchDisplayDelegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    // We react to search begining
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    // We respond to ending the search
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([self.dataSource respondsToSelector:@selector(conversationListViewController:didSearchWithString:completion:)]) {
        [self.dataSource conversationListViewController:self didSearchWithString:searchText completion:^(NSSet *conversations) {
            [self.tableView reloadData];
        }];
    }
}

#pragma mark - Table view data source methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.queryController numberOfObjectsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell<LYRUIConversationPresenting> *conversationCell = [tableView dequeueReusableCellWithIdentifier:LYRUIConversationCellReuseIdentifier forIndexPath:indexPath];
    [self configureCell:conversationCell atIndexPath:indexPath];
    return conversationCell;
}

/**
 
 LAYER - Extracting content from an LYRConversation object so that it can be displayed in a tableViewCell.
 
 */
- (void)configureCell:(UITableViewCell<LYRUIConversationPresenting> *)conversationCell atIndexPath:(NSIndexPath *)indexPath
{
    // Present Conversation
    LYRConversation *conversation = [self.queryController objectAtIndexPath:indexPath];
    [conversationCell presentConversation:conversation];
    
    // Update cell with image if needed
    if (self.displaysConversationImage) {
        if ([self.dataSource respondsToSelector:@selector(conversationListViewController:imageForConversation:)]) {
            UIImage *conversationImage = [self.dataSource conversationListViewController:self imageForConversation:conversation];
            [conversationCell updateWithConversationImage:conversationImage];
        } else {
           @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Conversation View Delegate must return a conversation image" userInfo:nil]; 
        }
    }
    
    // Update Cell with unread message count
    LYRRecipientStatus status = [[conversation.lastMessage.recipientStatusByUserID objectForKey:self.layerClient.authenticatedUserID] integerValue];
    [conversationCell updateWithLastMessageRecipientStatus:status];
    
    // Update Cell with Label
    if ([self.dataSource respondsToSelector:@selector(conversationListViewController:labelForConversation:)]) {
        NSString *conversationLabel = [self.dataSource conversationListViewController:self labelForConversation:conversation];
        [conversationCell updateWithConversationLabel:conversationLabel];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Conversation View Delegate must return a conversation label" userInfo:nil];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *localDeleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Local" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self deleteConversationAtIndexPath:indexPath withDeletionMode:LYRDeletionModeLocal];
    }];
    localDeleteAction.backgroundColor = [UIColor grayColor];

    UITableViewRowAction *globalDeleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Global" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self deleteConversationAtIndexPath:indexPath withDeletionMode:LYRDeletionModeAllParticipants];
    }];
    
    globalDeleteAction.backgroundColor = [UIColor redColor];
    return @[globalDeleteAction, localDeleteAction];
}

/**
 
 LAYER - Deleting a Layer Conversation
 
 */
- (void)deleteConversationAtIndexPath:(NSIndexPath *)indexPath withDeletionMode:(LYRDeletionMode)deletionMode
{
    LYRConversation *conversation = [self.queryController objectAtIndexPath:indexPath];
    NSError *error;
    BOOL success = [conversation delete:deletionMode error:&error];
    if (!success) {
        if ([self.delegate respondsToSelector:@selector(conversationListViewController:didFailDeletingConversation:deletionMode:error:)]) {
            [self.delegate conversationListViewController:self didFailDeletingConversation:conversation deletionMode:deletionMode error:error];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(conversationListViewController:didDeleteConversation:deletionMode:)]) {
            [self.delegate conversationListViewController:self didDeleteConversation:conversation deletionMode:deletionMode];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Not implemented
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYRConversation *conversation = [self.queryController objectAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(conversationListViewController:didSelectConversation:)]){
        [self.delegate conversationListViewController:self didSelectConversation:conversation];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}

#pragma mark - Conversation Editing Methods

// Set table view into editing mode and change left bar buttong to a done button
- (void)editButtonTapped
{
    [self.tableView setEditing:TRUE animated:TRUE];
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(doneButtonTapped)];
    doneButtonItem.accessibilityLabel = @"Done";
    self.navigationItem.leftBarButtonItem = doneButtonItem;
}

- (void)doneButtonTapped
{
    [self.tableView setEditing:NO animated:YES];
    [self addEditButton];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Conversation Query Controller 

- (void)queryControllerWillChangeContent:(LYRQueryController *)queryController
{
    [self.tableView beginUpdates];
}


- (void)queryController:(LYRQueryController *)controller
        didChangeObject:(id)object
            atIndexPath:(NSIndexPath *)indexPath
          forChangeType:(LYRQueryControllerChangeType)type
           newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case LYRQueryControllerChangeTypeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case LYRQueryControllerChangeTypeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        default:
            break;
    }
}

- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController
{
    [self.tableView endUpdates];
}

@end
