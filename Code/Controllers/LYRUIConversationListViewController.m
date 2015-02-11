//
//  LYRUIConversationListViewController.m
//  LayerSample
//
//  Created by Kevin Coleman on 8/29/14.
//  Copyright (c) 2014 Layer, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import "LYRUIConversationListViewController.h"

static NSString *const LYRUIConversationCellReuseIdentifier = @"LYRUIConversationCellReuseIdentifier";

@interface LYRUIConversationListViewController () <UIActionSheetDelegate, LYRQueryControllerDelegate>

@property (nonatomic) LYRQueryController *queryController;
@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) BOOL hasAppeared;
@property (nonatomic) LYRConversation *conversationToDelete;
@property (nonatomic) LYRConversation *conversationSelectedBeforeContentChange;

@end

@implementation LYRUIConversationListViewController

NSString *const LYRUIConversationListViewControllerTitle = @"Messages";
NSString *const LYRUIConversationTableViewAccessibilityLabel = @"Conversation Table View";
NSString *const LYRUIConversationTableViewAccessibilityIdentifier = @"Conversation Table View Identifier";


+ (instancetype)conversationListViewControllerWithLayerClient:(LYRClient *)layerClient
{
    NSAssert(layerClient, @"layerClient cannot be nil");
    return [[self alloc] initConversationlistViewControllerWithLayerClient:layerClient];
}
    
- (id)initConversationlistViewControllerWithLayerClient:(LYRClient *)layerClient
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)  {
        _layerClient = layerClient;
        _cellClass = [LYRUIConversationTableViewCell class];
        _displaysAvatarItem = NO;
        _allowsEditing = YES;
        _rowHeight = 76.0f;
    }
    return self;
}

- (id)init
{
    [NSException raise:NSInternalInconsistencyException format:@"Failed to call designated initializer"];
    return nil;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = LYRUIConversationListViewControllerTitle;
    self.accessibilityLabel = LYRUIConversationListViewControllerTitle;
    self.tableView.accessibilityLabel = LYRUIConversationTableViewAccessibilityLabel;
    self.tableView.accessibilityIdentifier = LYRUIConversationTableViewAccessibilityIdentifier;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setupConversationDataSource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.hasAppeared) {
        // Set public configuration properties once view has loaded
        [self.tableView registerClass:self.cellClass forCellReuseIdentifier:LYRUIConversationCellReuseIdentifier];
        self.tableView.rowHeight = self.rowHeight;
        if (self.allowsEditing) {
            [self addEditButton];
        }
        self.hasAppeared = YES;
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

#pragma mark - Public Setters

- (void)setCellClass:(Class<LYRUIConversationPresenting>)cellClass
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change cell class after the view has been presented" userInfo:nil];
    }
    if (!class_conformsToProtocol(cellClass, @protocol(LYRUIConversationPresenting))) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cell class must conform to LYRUIConversationPresenting" userInfo:nil];
        
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
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" operator:LYRPredicateOperatorIsIn value:self.layerClient.authenticatedUserID];
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastMessage.receivedAt" ascending:NO]];

    self.queryController = [self.layerClient queryControllerWithQuery:query];
    self.queryController.delegate = self;
    NSError *error;
    BOOL success = [self.queryController execute:&error];
    if (!success) NSLog(@"LayerKit failed to execute query with error: %@", error);
}

#pragma mark - UITableViewDataSource

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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.allowsEditing;
}

#pragma mark - Cell Configuration

- (void)configureCell:(UITableViewCell<LYRUIConversationPresenting> *)conversationCell atIndexPath:(NSIndexPath *)indexPath
{
    LYRConversation *conversation = [self.queryController objectAtIndexPath:indexPath];
    [conversationCell presentConversation:conversation];
    
    if (self.displaysAvatarItem) {
        if ([self.dataSource respondsToSelector:@selector(conversationListViewController:avatarItemForConversation:)]) {
            id<LYRUIAvatarItem> avatarItem = [self.dataSource conversationListViewController:self avatarItemForConversation:conversation];
            [conversationCell updateWithAvatarItem:avatarItem];
        } else {
           @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Conversation View Delegate must return an object conforming to the `LYRUIAvatarItem` protocol." userInfo:nil];
        }
    }
    
    if ([self.dataSource respondsToSelector:@selector(conversationListViewController:titleForConversation:)]) {
        NSString *conversationLabel = [self.dataSource conversationListViewController:self titleForConversation:conversation];
        [conversationCell updateWithConversationLabel:conversationLabel];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Conversation View Delegate must return a conversation label" userInfo:nil];
    }
}

#pragma mark - UITableViewDelegate

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *actions = [NSMutableArray new];
    for (NSNumber *deletionMode in self.deletionModes) {
        NSString *actionString;
        UIColor *actionColor;
        switch (deletionMode.integerValue) {
            case LYRDeletionModeLocal:
                actionString = @"Local";
                actionColor = [UIColor redColor];
                break;
            case LYRDeletionModeAllParticipants:
                actionString = @"Global";
                actionColor = [UIColor grayColor];
                break;

            default:
                break;
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

#pragma mark - Helpers

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
