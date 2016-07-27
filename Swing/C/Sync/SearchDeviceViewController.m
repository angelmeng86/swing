//
//  SearchDeviceViewController.m
//  Swing
//
//  Created by Mapple on 16/7/27.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SearchDeviceViewController.h"

typedef enum : NSUInteger {
    SyncStatusSearching,
    SyncStatusFound,
    SyncStatusSyncing,
    SyncStatusSyncCompleted
} SyncStatus;

@interface SearchDeviceViewController ()
{
    NSUInteger _status;
}

@end

@implementation SearchDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self changeStatus:SyncStatusSearching];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performStatus:(NSNumber*)status {
    [self changeStatus:[status unsignedIntegerValue]];
}

- (void)changeStatus:(SyncStatus)status {
    switch (status) {
        case SyncStatusSearching:
        {
            self.statusLabel.text = @"Searching for your device!";
            self.button.hidden = YES;
            [self performSelector:@selector(performStatus:) withObject:[NSNumber numberWithUnsignedInteger:SyncStatusFound] afterDelay:3];
        }
            break;
        case SyncStatusFound:
        {
            self.statusLabel.text = @"Found your device!";
            self.button.hidden = NO;
            [self.button setTitle:@"Sync Now" forState:UIControlStateNormal];
        }
            break;
        case SyncStatusSyncing:
        {
            self.statusLabel.text = @"Syncing";
            self.button.hidden = YES;
            [self performSelector:@selector(performStatus:) withObject:[NSNumber numberWithUnsignedInteger:SyncStatusSyncCompleted] afterDelay:3];
        }
            break;
        case SyncStatusSyncCompleted:
        {
            self.statusLabel.text = @"Sync Completed";
            [self.button setTitle:@"Go to Dashboard" forState:UIControlStateNormal];
            self.button.hidden = NO;
        }
            break;
        default:
            break;
    }
    _status = status;
}

- (IBAction)btnAction:(id)sender {
    if (_status == SyncStatusFound) {
        [self changeStatus:SyncStatusSyncing];
    }
    else if (_status == SyncStatusSyncCompleted) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
