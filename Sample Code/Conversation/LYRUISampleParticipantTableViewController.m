//
//  LYRUISampleParticipantTableViewController.m
//  LayerUIKit
//
//  Created by Kevin Coleman on 2/11/15.
//
//

#import "LYRUISampleParticipantTableViewController.h"

@interface LYRUISampleParticipantTableViewController ()

@end

@implementation LYRUISampleParticipantTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelTap)];
    self.navigationItem.leftBarButtonItem = cancelItem;
}

- (void)handleCancelTap
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
