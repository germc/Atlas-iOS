//
//  LYRUIParticipantPickerController.m
//  
//
//  Created by Kevin Coleman on 8/29/14.
//
//

#import "LYRUIParticipantPickerController.h"

@interface LYRUIParticipantPickerController () <LYRUIParticipantTableViewControllerDelegate>

@property (nonatomic) LYRUIParticipantTableViewController *participantTableViewController;
@property (nonatomic) BOOL hasAppeared;

@end

@implementation LYRUIParticipantPickerController

+ (instancetype)participantPickerWithDataSource:(id<LYRUIParticipantPickerDataSource>)dataSource sortType:(LYRUIParticipantPickerSortType)sortType
{
    NSAssert(dataSource, @"Data Source cannot be nil");
    return [[self alloc] initWithDataSource:dataSource sortType:sortType];
}

- (id)initWithDataSource:(id<LYRUIParticipantPickerDataSource>)dataSource sortType:(LYRUIParticipantPickerSortType)sortType
{
    LYRUIParticipantTableViewController *controller = [[LYRUIParticipantTableViewController alloc] initWithStyle:UITableViewStylePlain];
    self = [super initWithRootViewController:controller];
    if (self) {
        _sortType = sortType;
        _participantTableViewController = controller;
        _dataSource = dataSource;
    }
    return self;
}

- (id)init
{
    [NSException raise:@"Invalid" format:@"Failed to call designated initializer"];
    return nil;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Configure default picker configuration
    self.allowsMultipleSelection = YES;
    self.cellClass = [LYRUIParticipantTableViewCell class];
    self.rowHeight = 40;
    self.title = @"Participants";
    self.accessibilityLabel = @"Participants";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!self.hasAppeared) {
        self.participantTableViewController.delegate = self;
        self.participantTableViewController.sortType = self.sortType;
        self.participantTableViewController.participants = [self.dataSource participantsForParticipantPickerController:self];
        self.participantTableViewController.allowsMultipleSelection = self.allowsMultipleSelection;
        self.participantTableViewController.participantCellClass = self.cellClass;
        self.participantTableViewController.rowHeight = self.rowHeight;
        self.participantTableViewController.sortType = self.sortType;
        self.hasAppeared = YES;
    }
}

#pragma mark - Public Picker Configuration Options

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

- (void)setParticipantPickerSortType:(LYRUIParticipantPickerSortType)participantPickerSortType
{
    if (self.hasAppeared) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot change sort type after view has been presented" userInfo:nil];
    }
    _sortType = participantPickerSortType;
}

#pragma mark - LYRUIParticipantTableViewControllerDelegate

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<LYRUIParticipant>)participant
{
    [self.participantPickerDelegate participantPickerController:self didSelectParticipant:participant];
}

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didDeselectParticipant:(id<LYRUIParticipant>)participant
{
    if ([self.participantPickerDelegate respondsToSelector:@selector(participantPickerController:didDeselectParticipant:)]) {
        [self.participantPickerDelegate participantPickerController:self didDeselectParticipant:participant];
    }
}

- (void)participantTableViewController:(LYRUIParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    [self.dataSource participantPickerController:self searchForParticipantsMatchingText:searchText completion:^(NSSet *participants) {
        completion(participants);
    }];
}

- (void)participantTableViewControllerDidCancel:(LYRUIParticipantTableViewController *)participantTableViewController
{
    [self.participantPickerDelegate participantPickerControllerDidCancel:self];
}

@end
