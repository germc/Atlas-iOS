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
#import "LYRUIConversationDataSource.h"

@interface LYRUIConversationListViewController () <UISearchBarDelegate, UISearchDisplayDelegate, LYRUIConversationDataSourceDelegate>

@property (nonatomic) LYRUIConversationDataSource *conversationListDataSource;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) UISearchDisplayController *searchController;
@property (nonatomic) NSMutableArray *filteredConversations;
@property (nonatomic) NSPredicate *searchPredicate;
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
        _displaysConversationImage = YES;
        _allowsEditing = YES;
        _rowHeight = 72.0f;
        
        // Configure default UIAppearance Proxy
        [self configureTableViewCellAppearance];
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
    self.conversationListDataSource = [[LYRUIConversationDataSource alloc] initWithLayerClient:self.layerClient];
    self.conversationListDataSource.delegate = self;
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
        //[self addEditButton];
    }
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.isOnScreen = NO;
}

- (void)dealloc
{
    self.conversationListDataSource = nil;
    self.conversationListDataSource.delegate = nil;
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
    editButtonItem.accessibilityLabel = @"Edit";
    self.navigationItem.leftBarButtonItem = editButtonItem;
}

- (void)reloadConversations
{
    if (self.searchController.active) {
        [self.searchController.searchResultsTableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

// Returns appropriate data set depending on search state
- (NSArray *)currentDataSet
{
    if (self.isSearching) {
        return self.filteredConversations;
    }
    return self.conversationListDataSource.identifiers;
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
    return [[self currentDataSet] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell<LYRUIConversationPresenting> *conversationCell = [tableView dequeueReusableCellWithIdentifier:LYRUIConversationCellReuseIdentifier forIndexPath:indexPath];
    [self configureCell:conversationCell atIndexPath:indexPath];
    return conversationCell;
}

- (void)configureCell:(UITableViewCell<LYRUIConversationPresenting> *)conversationCell atIndexPath:(NSIndexPath *)indexPath
{
    NSURL *conversationID = [[self currentDataSet] objectAtIndex:indexPath.row];
   
    // Present Conversation
    LYRConversation *conversation = [[[self.layerClient conversationsForIdentifiers:[NSSet setWithObject:conversationID]] allObjects] firstObject];
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
    return self.allowsEditing;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *localDeleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Local" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSURL *conversationIdentifier = [[self currentDataSet] objectAtIndex:indexPath.row];
        LYRConversation *conversation = [self.layerClient conversationForIdentifier:conversationIdentifier];
        [self.layerClient deleteConversation:conversation mode:LYRDeletionModeLocal error:nil];
    }];
    localDeleteAction.backgroundColor = [UIColor grayColor];

    UITableViewRowAction *globalDeleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Global" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSURL *conversationIdentifier = [[self currentDataSet] objectAtIndex:indexPath.row];
        LYRConversation *conversation = [self.layerClient conversationForIdentifier:conversationIdentifier];
        [self.layerClient deleteConversation:conversation mode:LYRDeletionModeAllParticipants error:nil];
    }];
    
    globalDeleteAction.backgroundColor = [UIColor redColor];
    
    return @[globalDeleteAction, localDeleteAction];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Not implemented
}

#pragma mark - Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *conversationID = [[self currentDataSet] objectAtIndex:indexPath.row];
    LYRConversation *conversation = [[[self.layerClient conversationsForIdentifiers:[NSSet setWithObject:conversationID]] allObjects] firstObject];
    if ([self.delegate respondsToSelector:@selector(conversationListViewController:didSelectConversation:)]){
        [self.delegate conversationListViewController:self didSelectConversation:conversation];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeight;
}

- (NSUInteger)unreadMessageCountForConversation:(LYRConversation *)conversation
{
    NSOrderedSet *messages = [self.layerClient messagesForConversation:conversation];
    NSUInteger unreadMessageCount = 0;
    for (LYRMessage *message in messages) {
        LYRRecipientStatus status = [[message.recipientStatusByUserID objectForKey:self.layerClient.authenticatedUserID] integerValue];
        switch (status) {
            case LYRRecipientStatusDelivered:
                unreadMessageCount += 1;
                break;
                
            default:
                break;
        }
    }
    return unreadMessageCount;
}

#pragma mark - Conversation Editing Methods

// Set table view into editing mode and change left bar buttong to a done button
- (void)editButtonTapped
{
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
    } completion:^(BOOL finished) {
        //
    }];
    
    
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

#pragma mark
#pragma mark Notification Observer Delegate Methods

- (void)observer:(LYRUIConversationDataSource *)observer updateWithChanges:(NSArray *)changes
{
//    NSLog(@"Changes %@", changes);
//    [self.tableView beginUpdates];
//    for (LYRUIDataSourceChange *change in changes) {
//        if (change.type == LYRUIDataSourceChangeTypeUpdate) {
//            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:change.newIndex inSection:0]]
//                                  withRowAnimation:UITableViewRowAnimationAutomatic];
//        } else if (change.type == LYRUIDataSourceChangeTypeInsert) {
//            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:change.newIndex inSection:0]]
//                                  withRowAnimation:UITableViewRowAnimationAutomatic];
//        } else if (change.type == LYRUIDataSourceChangeTypeMove) {
//            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:change.oldIndex inSection:0]]
//                                  withRowAnimation:UITableViewRowAnimationAutomatic];
//            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:change.newIndex inSection:0]]
//                                  withRowAnimation:UITableViewRowAnimationAutomatic];
//        } else if (change.type == LYRUIDataSourceChangeTypeDelete) {
//            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:change.newIndex inSection:0]]
//                                  withRowAnimation:UITableViewRowAnimationAutomatic];
//        }
//    }
}

- (void)observer:(LYRUIConversationDataSource *)observer didChangeContent:(BOOL)didChangeContent
{
//    [self.tableView endUpdates];
    [self.tableView reloadData];
}

- (void)configureTableViewCellAppearance
{
    [[LYRUIConversationTableViewCell appearance] setConversationLabelFont:LSBoldFont(14)];
    [[LYRUIConversationTableViewCell appearance] setConversationLableColor:[UIColor blackColor]];
    
    [[LYRUIConversationTableViewCell appearance] setLastMessageTextFont:LSLightFont(14)];
    [[LYRUIConversationTableViewCell appearance] setLastMessageTextColor:[UIColor grayColor]];
    
    [[LYRUIConversationTableViewCell appearance] setDateLabelFont:LSMediumFont(14)];
    [[LYRUIConversationTableViewCell appearance] setDateLabelColor:[UIColor grayColor]];
    
    [[LYRUIConversationTableViewCell appearance] setUnreadMessageIndicatorBackgroundColor:LSBlueColor()];
    
    [[LYRUIConversationTableViewCell appearance] setBackgroundColor:[UIColor whiteColor]];
}

@end
