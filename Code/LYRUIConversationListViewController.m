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

@interface LYRUIConversationListViewController () <UIActionSheetDelegate, LYRQueryControllerDelegate>

@property (nonatomic) LYRQueryController *queryController;
@property (nonatomic) BOOL hasAppeared;
@property (nonatomic) LYRConversation *conversationToDelete;

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
        _layerClient = layerClient;
        _cellClass = [LYRUIConversationTableViewCell class];
        _displaysConversationImage = YES;
        _allowsEditing = YES;
        _rowHeight = 72.0f;
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

    self.title = @"Messages";
    self.accessibilityLabel = @"Messages";
    self.tableView.accessibilityLabel = @"Conversation List";

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
}

#pragma mark - Public Setters

- (void)setAllowsEditing:(BOOL)allowsEditing
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change editing mode after the view has been presented" userInfo:nil];
    }
    _allowsEditing = allowsEditing;
}

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

- (void)setRowHeight:(CGFloat)rowHeight
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change row height after the view has been presented" userInfo:nil];
    }
    _rowHeight = rowHeight;
}

- (void)setDisplaysConversationImage:(BOOL)displaysConversationImage
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change conversation image display after the view has been presented" userInfo:nil];
    }
    _displaysConversationImage = displaysConversationImage;
}

#pragma mark - Set Up

- (void)addEditButton
{
    self.editButtonItem.accessibilityLabel = @"Edit Button";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)setupConversationDataSource
{
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
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

#pragma mark - Cell Configuration

- (void)configureCell:(UITableViewCell<LYRUIConversationPresenting> *)conversationCell atIndexPath:(NSIndexPath *)indexPath
{
    LYRConversation *conversation = [self.queryController objectAtIndexPath:indexPath];
    [conversationCell presentConversation:conversation];
    
    if (self.displaysConversationImage) {
        if ([self.dataSource respondsToSelector:@selector(conversationListViewController:imageForConversation:)]) {
            UIImage *conversationImage = [self.dataSource conversationListViewController:self imageForConversation:conversation];
            [conversationCell updateWithConversationImage:conversationImage];
        } else {
           @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Conversation View Delegate must return a conversation image" userInfo:nil]; 
        }
    }
    
    LYRRecipientStatus status = [[conversation.lastMessage.recipientStatusByUserID objectForKey:self.layerClient.authenticatedUserID] integerValue];
    [conversationCell updateWithLastMessageRecipientStatus:status];
    
    if ([self.dataSource respondsToSelector:@selector(conversationListViewController:labelForConversation:)]) {
        NSString *conversationLabel = [self.dataSource conversationListViewController:self labelForConversation:conversation];
        [conversationCell updateWithConversationLabel:conversationLabel];
    } else {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Conversation View Delegate must return a conversation label" userInfo:nil];
    }
}

#pragma mark - UITableViewDelegate

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
