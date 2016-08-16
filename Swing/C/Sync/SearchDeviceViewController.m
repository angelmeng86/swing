//
//  SearchDeviceViewController.m
//  Swing
//
//  Created by Mapple on 16/7/27.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SearchDeviceViewController.h"
#import "LMBluetoothClient.h"

typedef enum : NSUInteger {
    SyncStatusNone,
    SyncStatusSearching,
    SyncStatusFound,
    SyncStatusSyncing,
    SyncStatusSyncCompleted
} SyncStatus;

@interface SearchDeviceViewController ()
{
    NSUInteger _status;
    
    MDRadialProgressTheme *progressTheme;
    MDRadialProgressTheme *doneTheme;
    
    LMBluetoothClient *client;
}

@end

@implementation SearchDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    progressTheme = [[MDRadialProgressTheme alloc] init];
    progressTheme.completedColor = COMMON_TITLE_COLOR;
    progressTheme.incompletedColor = [UIColor whiteColor];
    progressTheme.centerColor = [UIColor clearColor];
    progressTheme.sliceDividerHidden = YES;
    progressTheme.thickness = 20;
    
    doneTheme = [[MDRadialProgressTheme alloc] init];
    doneTheme.completedColor = COMMON_TITLE_COLOR;
    doneTheme.incompletedColor = [UIColor whiteColor];
    doneTheme.centerColor = [UIColor clearColor];
    doneTheme.sliceDividerHidden = NO;
    doneTheme.thickness = 20;
    doneTheme.sliceDividerThickness = 4;
    doneTheme.sliceDividerColor = [UIColor whiteColor];
    
    self.progressView.label.hidden = YES;
    
    client = [[LMBluetoothClient alloc] init];
    client.delegate = self;
    
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
    if (_status == status) {
        return;
    }
    switch (status) {
        case SyncStatusSearching:
        {
            self.statusLabel.text = @"Searching for your device!";
            self.button.hidden = YES;
            
            self.progressView.theme = progressTheme;
            self.progressView.progressTotal = 12;
            self.progressView.progressCounter = 1;
            self.progressView.isIndeterminateProgress = YES;
#if TARGET_IPHONE_SIMULATOR
            [self performSelector:@selector(performStatus:) withObject:[NSNumber numberWithUnsignedInteger:SyncStatusFound] afterDelay:3];
#else
            [client beginScan];
#endif
        }
            break;
        case SyncStatusFound:
        {
            self.statusLabel.text = @"Found your device!";
            self.button.hidden = NO;
            
            self.progressView.isIndeterminateProgress = NO;
            self.progressView.theme = doneTheme;
            self.progressView.progressTotal = 8;
            self.progressView.progressCounter = 8;
            
            
            [self.button setTitle:@"Sync Now" forState:UIControlStateNormal];
        }
            break;
        case SyncStatusSyncing:
        {
            self.statusLabel.text = @"Syncing";
            self.button.hidden = YES;
            
            self.progressView.theme = progressTheme;
            self.progressView.progressTotal = 12;
            self.progressView.progressCounter = 1;
            self.progressView.isIndeterminateProgress = YES;
            
#if TARGET_IPHONE_SIMULATOR
            [self performSelector:@selector(performStatus:) withObject:[NSNumber numberWithUnsignedInteger:SyncStatusSyncCompleted] afterDelay:3];
#endif
        }
            break;
        case SyncStatusSyncCompleted:
        {
            self.statusLabel.text = @"Sync Completed";
            [self.button setTitle:@"Go to Dashboard" forState:UIControlStateNormal];
            
            self.progressView.isIndeterminateProgress = NO;
            self.progressView.theme = doneTheme;
            self.progressView.progressTotal = 8;
            self.progressView.progressCounter = 8;
            
            
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
        
        [client stopScan];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventLoaded:) name:EVENT_LIST_UPDATE_NOTI object:nil];
        [[GlobalCache shareInstance] queryMonthEvents:[NSDate date]];
//        [client syncDevice];
    }
    else if (_status == SyncStatusSyncCompleted) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)eventLoaded:(NSNotification*)notification {
    //    NSLog(@"eventLoaded:%@ month:%@", _calendarManager.date, notification.object);
    NSString *month = [GlobalCache dateToMonthString:[NSDate date]];
    if ([month isEqualToString:notification.object]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        client.alertEvents = [[GlobalCache shareInstance] searchWeeklyEventsByDay:[NSDate date]];
        [client syncDevice];
    }
}

- (void)bluetoothClientScanDevice:(NSArray*)peripherals {
    [self changeStatus:SyncStatusFound];
}

- (void)bluetoothClientSyncFinished {
    [self changeStatus:SyncStatusSyncCompleted];
}

@end
