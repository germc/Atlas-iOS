//
//  ATLUIConversationListViewController.m
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

#import <objc/runtime.h>
#import "ATLConversationListViewController.h"
#import "ATLMessagingUtilities.h"

static NSString *const ATLConversationCellReuseIdentifier = @"ATLConversationCellReuseIdentifier";
static NSString *const ATLImageMIMETypePlaceholderText = @"Attachment: Image";
static NSString *const ATLLocationMIMETypePlaceholderText = @"Attachment: Location";
static NSString *const ATLGIFMIMETypePlaceholderText = @"Attachment: GIF";

@interface ATLConversationListViewController () <UIActionSheetDelegate, LYRQueryControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate>

@property (nonatomic) LYRQueryController *queryController;
@property (nonatomic) LYRQueryController *searchQueryController;
@property (nonatomic) LYRConversation *conversationToDelete;
@property (nonatomic) LYRConversation *conversationSelectedBeforeContentChange;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) BOOL hasAppeared;

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, readwrite) UISearchDisplayController *searchController;
#pragma GCC diagnostic pop

@end

@implementation ATLConversationListViewController

NSString *const ATLConversationListViewControllerTitle = @"Messages";
NSString *const ATLConversationTableViewAccessibilityLabel = @"Conversation Table View";
NSString *const ATLConversationTableViewAccessibilityIdentifier = @"Conversation Table View Identifier";

+ (instancetype)conversationListViewControllerWithLayerClient:(LYRClient *)layerClient
{
    NSAssert(layerClient, @"Layer Client cannot be nil");
    return [[self alloc] initWithLayerClient:layerClient];
}

- (instancetype)initWithLayerClient:(LYRClient *)layerClient
{
    NSAssert(layerClient, @"Layer Client cannot be nil");
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)  {
        _layerClient = layerClient;
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
    _cellClass = [ATLConversationTableViewCell class];
    _deletionModes = @[@(LYRDeletionModeLocal), @(LYRDeletionModeAllParticipants)];
    _displaysAvatarItem = NO;
    _allowsEditing = YES;
    _rowHeight = 76.0f;
}

- (id)init
{
    [NSException raise:NSInternalInconsistencyException format:@"Failed to call designated initializer"];
    return nil;
}

- (void)setLayerClient:(LYRClient *)layerClient
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Layer Client cannot be set after the view has been presented" userInfo:nil];
    }
    _layerClient = layerClient;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = ATLConversationListViewControllerTitle;
    self.accessibilityLabel = ATLConversationListViewControllerTitle;

    self.tableView.accessibilityLabel = ATLConversationTableViewAccessibilityLabel;
    self.tableView.accessibilityIdentifier = ATLConversationTableViewAccessibilityIdentifier;
    self.tableView.isAccessibilityElement = YES;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    [self.searchBar sizeToFit];
    self.searchBar.translucent = NO;
    self.searchBar.accessibilityLabel = @"Search Bar";
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
#pragma GCC diagnostic pop
    self.searchController.delegate = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.searchResultsDataSource = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Hide the search bar
    if (!self.hasAppeared) {
        CGFloat contentOffset = self.tableView.contentOffset.y + self.searchBar.frame.size.height;
        self.tableView.contentOffset = CGPointMake(0, contentOffset);
        self.tableView.rowHeight = self.rowHeight;
        [self.tableView registerClass:self.cellClass forCellReuseIdentifier:ATLConversationCellReuseIdentifier];
        if (self.allowsEditing) [self addEditButton];
    }
    if (!self.queryController) {
        [self setupConversationDataSource];
    }
   
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    if (selectedIndexPath && self.clearsSelectionOnViewWillAppear) {
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:animated];
        [[self transitionCoordinator] notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            if (![context isCancelled]) return;
            if ([self.tableView indexPathForSelectedRow]) return;
            [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.hasAppeared = YES;
}

#pragma mark - Public Setters

- (void)setCellClass:(Class<ATLConversationPresenting>)cellClass
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change cell class after the view has been presented" userInfo:nil];
    }
    if (!class_conformsToProtocol(cellClass, @protocol(ATLConversationPresenting))) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cell class must conform to ATLConversationPresenting" userInfo:nil];
    }
    _cellClass = cellClass;
}

- (void)setDeletionModes:(NSArray *)deletionModes
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change deletion modes after the view has been presented" userInfo:nil];
    }
    _deletionModes = deletionModes;
}

- (void)setDisplaysAvatarItem:(BOOL)displaysAvatarItem
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change conversation image display after the view has been presented" userInfo:nil];
    }
    _displaysAvatarItem = displaysAvatarItem;
}

- (void)setAllowsEditing:(BOOL)allowsEditing
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change editing mode after the view has been presented" userInfo:nil];
    }
    _allowsEditing = allowsEditing;
}

- (void)setRowHeight:(CGFloat)rowHeight
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change row height after the view has been presented" userInfo:nil];
    }
    _rowHeight = rowHeight;
}

#pragma mark - Set Up

- (void)addEditButton
{
    if (self.navigationItem.leftBarButtonItem) return;
    self.editButtonItem.accessibilityLabel = @"Edit Button";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)setupConversationDataSource
{
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsIn value:self.layerClient.authenticatedUserID];
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.receivedAt" ascending:NO]];
    
    if ([self.dataSource respondsToSelector:@selector(conversationListViewController:willLoadWithQuery:)]) {
        query = [self.dataSource conversationListViewController:self willLoadWithQuery:query];
        if (![query isKindOfClass:[LYRQuery class]]){
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Data source must return an `LYRQuery` object." userInfo:nil];
        }
    }
    
    self.queryController = [self.layerClient queryControllerWithQuery:query];
    self.queryController.delegate = self;
    NSError *error;
    BOOL success = [self.queryController execute:&error];
    if (!success) {
        NSLog(@"LayerKit failed to execute query with error: %@", error);
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.queryController numberOfObjectsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = [self reuseIdentifierForConversation:nil atIndexPath:indexPath];
    
    UITableViewCell<ATLConversationPresenting> *conversationCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    [self configureCell:conversationCell atIndexPath:indexPath];
    return conversationCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.allowsEditing;
}

#pragma mark - Cell Configuration

- (void)configureCell:(UITableViewCell<ATLConversationPresenting> *)conversationCell atIndexPath:(NSIndexPath *)indexPath
{
    LYRConversation *conversation = [self.queryController objectAtIndexPath:indexPath];
    [conversationCell presentConversation:conversation];
    
    if (self.displaysAvatarItem) {
        if ([self.dataSource respondsToSelector:@selector(conversationListViewController:avatarItemForConversation:)]) {
            id<ATLAvatarItem> avatarItem = [self.dataSource conversationListViewController:self avatarItemForConversation:conversation];
            [conversationCell updateWithAvatarItem:avatarItem];
        } else {
           @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Conversation View Delegate must return an object conforming to the `ATLAvatarItem` protocol." userInfo:nil];
        }
    }
    
    if ([self.dataSource respondsToSelector:@selector(conversationListViewController:titleForConversation:)]) {
        NSString *conversationTitle = [self.dataSource conversationListViewController:self titleForConversation:conversation];
        [conversationCell updateWithConversationTitle:conversationTitle];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Conversation View Delegate must return a conversation label" userInfo:nil];
    }
    
    NSString *lastMessageText;
    if ([self.dataSource respondsToSelector:@selector(conversationListViewController:lastMessageTextForConversation:)]) {
        lastMessageText = [self.dataSource conversationListViewController:self lastMessageTextForConversation:conversation];
    }
    if (!lastMessageText) {
        lastMessageText = [self defaultLastMessageTextForConversation:conversation];
    }
    [conversationCell updateWithLastMessageText:lastMessageText];
}

#pragma mark - Reloading Conversations

- (void)reloadCellForConversation:(LYRConversation *)conversation
{
    if (!conversation) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"`conversation` cannot be nil." userInfo:nil];
    }
    NSIndexPath *indexPath = [self.queryController indexPathForObject:conversation];
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDelegate

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *actions = [NSMutableArray new];
    for (NSNumber *deletionMode in self.deletionModes) {
        NSString *actionString;
        UIColor *actionColor;
        if ([self.dataSource respondsToSelector:@selector(conversationListViewController:textForButtonWithDeletionMode:)]) {
            actionString = [self.dataSource conversationListViewController:self textForButtonWithDeletionMode:deletionMode.integerValue];
        } else {
            switch (deletionMode.integerValue) {
                case LYRDeletionModeLocal:
                    actionString = @"Local";
                    break;
                case LYRDeletionModeAllParticipants:
                    actionString = @"Global";
                    break;
                default:
                    break;
            }
        }
        if ([self.dataSource respondsToSelector:@selector(conversationListViewController:colorForButtonWithDeletionMode:)]) {
            actionColor = [self.dataSource conversationListViewController:self colorForButtonWithDeletionMode:deletionMode.integerValue];
        } else {
            switch (deletionMode.integerValue) {
                case LYRDeletionModeLocal:
                    actionColor = [UIColor redColor];
                    break;
                case LYRDeletionModeAllParticipants:
                    actionColor = [UIColor grayColor];
                    break;
                default:
                    break;
            }
        }
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:actionString handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [self deleteConversationAtIndexPath:indexPath withDeletionMode:deletionMode.integerValue];
        }];
        deleteAction.backgroundColor = actionColor;
        [actions addObject:deleteAction];
    }
    return actions;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.conversationToDelete = [self.queryController objectAtIndexPath:indexPath];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Global" otherButtonTitles:@"Local", nil];
    [actionSheet showInView:self.view];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(conversationListViewController:didSelectConversation:)]){
        LYRConversation *conversation = [self.queryController objectAtIndexPath:indexPath];
        [self.delegate conversationListViewController:self didSelectConversation:conversation];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self deleteConversation:self.conversationToDelete withDeletionMode:LYRDeletionModeAllParticipants];
    } else if (buttonIndex == actionSheet.firstOtherButtonIndex) {
        [self deleteConversation:self.conversationToDelete withDeletionMode:LYRDeletionModeLocal];
    } else if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self setEditing:NO animated:YES];
    }
    self.conversationToDelete = nil;
}

#pragma mark - Data Source

- (NSString *)reuseIdentifierForConversation:(LYRConversation *)conversation atIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier;
    if ([self.dataSource respondsToSelector:@selector(reuseIdentifierForConversationListViewController:)]) {
        reuseIdentifier = [self.dataSource reuseIdentifierForConversationListViewController:self];
    }
    if (!reuseIdentifier) {
        reuseIdentifier = ATLConversationCellReuseIdentifier;
    }
    return reuseIdentifier;
}

#pragma mark - LYRQueryControllerDelegate

- (void)queryControllerWillChangeContent:(LYRQueryController *)queryController
{
    LYRConversation *selectedConversation;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        selectedConversation = [self.queryController objectAtIndexPath:indexPath];
    }
    self.conversationSelectedBeforeContentChange = selectedConversation;
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
    if (self.conversationSelectedBeforeContentChange) {
        NSIndexPath *indexPath = [self.queryController indexPathForObject:self.conversationSelectedBeforeContentChange];
        if (indexPath) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        self.conversationSelectedBeforeContentChange = nil;
    }
}

#pragma mark - UISearchDisplayDelegate


- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = self.rowHeight;
    [tableView registerClass:self.cellClass forCellReuseIdentifier:ATLConversationCellReuseIdentifier];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if ([self.delegate respondsToSelector:@selector(conversationListViewController:didSearchForText:completion:)]) {
        [self.delegate conversationListViewController:self didSearchForText:searchString completion:^(NSSet *filteredParticipants) {
            if (![searchString isEqualToString:controller.searchBar.text]) return;
            NSSet *participantIdentifiers = [filteredParticipants valueForKey:@"participantIdentifier"];
            
            LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
            query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsIn value:participantIdentifiers];
            query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.receivedAt" ascending:NO]];
            self.searchQueryController = [self.layerClient queryControllerWithQuery:query];
            
            NSError *error;
            [self.searchQueryController execute:&error];
            [self.searchController.searchResultsTableView reloadData];
        }];
    }
    return NO;
}

- (LYRQueryController *)queryController
{
    if (self.searchController.isActive) {
        return _searchQueryController;
    } else {
        return _queryController;
    }
}

#pragma mark - Helpers

- (NSString *)defaultLastMessageTextForConversation:(LYRConversation *)conversation
{
    NSString *lastMessageText;
    LYRMessage *lastMessage = conversation.lastMessage;
    LYRMessagePart *messagePart = lastMessage.parts[0];
        if ([messagePart.MIMEType isEqualToString:ATLMIMETypeTextPlain]) {
            lastMessageText = [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding];
        } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImageJPEG]) {
            lastMessageText = ATLImageMIMETypePlaceholderText;
        } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImagePNG]) {
            lastMessageText = ATLImageMIMETypePlaceholderText;
        } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeImageGIF]) {
            lastMessageText = ATLGIFMIMETypePlaceholderText;
        } else if ([messagePart.MIMEType isEqualToString:ATLMIMETypeLocation]) {
            lastMessageText = ATLLocationMIMETypePlaceholderText;
        } else {
            lastMessageText = ATLImageMIMETypePlaceholderText;
        }
    return lastMessageText;
}

- (void)deleteConversationAtIndexPath:(NSIndexPath *)indexPath withDeletionMode:(LYRDeletionMode)deletionMode
{
    LYRConversation *conversation = [self.queryController objectAtIndexPath:indexPath];
    [self deleteConversation:conversation withDeletionMode:deletionMode];
}

- (void)deleteConversation:(LYRConversation *)conversation withDeletionMode:(LYRDeletionMode)deletionMode
{
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

@end
