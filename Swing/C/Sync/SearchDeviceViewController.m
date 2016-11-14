//
//  SearchDeviceViewController.m
//  Swing
//
//  Created by Mapple on 16/7/27.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SearchDeviceViewController.h"
#import "BLEClient.h"

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
//    MDRadialProgressTheme *doneTheme;
    
    BLEClient *client;
}

@property (nonatomic, strong) NSMutableArray *activitys;
@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation SearchDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Sync";
    
    progressTheme = [[MDRadialProgressTheme alloc] init];
    progressTheme.completedColor = COMMON_TITLE_COLOR;
    progressTheme.incompletedColor = [UIColor whiteColor];
    progressTheme.centerColor = [UIColor clearColor];
    progressTheme.sliceDividerHidden = YES;
    progressTheme.thickness = 20;
    
//    doneTheme = [[MDRadialProgressTheme alloc] init];
//    doneTheme.completedColor = COMMON_TITLE_COLOR;
//    doneTheme.incompletedColor = [UIColor whiteColor];
//    doneTheme.centerColor = [UIColor clearColor];
//    doneTheme.sliceDividerHidden = YES;
//    doneTheme.thickness = 20;
//    doneTheme.sliceDividerThickness = 4;
//    doneTheme.sliceDividerColor = [UIColor whiteColor];
    
    self.progressView.label.hidden = YES;
    self.navigationItem.hidesBackButton = YES;
    client = [[BLEClient alloc] init];
    [self changeStatus:SyncStatusSearching];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performStatus:(NSNumber*)status {
    [self changeStatus:[status unsignedIntegerValue]];
}

- (void)backAction {
#if TARGET_IPHONE_SIMULATOR
#else
    [client cannelAll];
#endif
    [super backAction];
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
            
//            self.navigationItem.leftBarButtonItem = nil;
            [self setCustomBackBarButtonItem];
            
#if TARGET_IPHONE_SIMULATOR
            [self performSelector:@selector(performStatus:) withObject:[NSNumber numberWithUnsignedInteger:SyncStatusFound] afterDelay:3];
#else
            [client searchDevice:[GlobalCache shareInstance].local.deviceMAC completion:^(CBPeripheral *peripheral, NSError *error) {
                if (!error) {
                    self.peripheral = peripheral;
                    [self changeStatus:SyncStatusFound];
                }
                else {
                    LOG_D(@"searchDevice error:%@", error);
                    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
#endif
        }
            break;
        case SyncStatusFound:
        {
            self.statusLabel.text = @"Found your device!";
            self.button.hidden = NO;
            
            self.progressView.isIndeterminateProgress = NO;
//            self.progressView.theme = doneTheme;
            self.progressView.progressTotal = 8;
            self.progressView.progressCounter = 8;
            
            [self setCustomBackBarButtonItem];
            
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
            
            self.navigationItem.leftBarButtonItem = nil;
            
        }
            break;
        case SyncStatusSyncCompleted:
        {
            self.statusLabel.text = @"Sync Completed";
            [self.button setTitle:@"Go to Dashboard" forState:UIControlStateNormal];
            
            self.progressView.isIndeterminateProgress = NO;
//            self.progressView.theme = doneTheme;
            self.progressView.progressTotal = 8;
            self.progressView.progressCounter = 8;
            
            self.navigationItem.leftBarButtonItem = nil;
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
        [SVProgressHUD showWithStatus:@"Get event, please wait..."];
        [[SwingClient sharedClient] calendarGetEvents:[NSDate date] type:GetEventTypeMonth completion:^(NSArray *eventArray, NSError *error) {
            if (error) {
                LOG_D(@"calendarGetEvents fail: %@", error);
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }
            else {
                [SVProgressHUD dismiss];
                [self changeStatus:SyncStatusSyncing];
#if TARGET_IPHONE_SIMULATOR
                [self performSelector:@selector(performStatus:) withObject:[NSNumber numberWithUnsignedInteger:SyncStatusSyncCompleted] afterDelay:3];
#else
                [self performSelector:@selector(syncAction:) withObject:eventArray afterDelay:3];
#endif
                
            }
        }];
    }
    else if (_status == SyncStatusSyncCompleted) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)syncAction:(NSArray*)eventArray {
    [client syncDevice:_peripheral event:eventArray completion:^(NSMutableArray *activities, NSError *error) {
        LOG_D(@"syncDevice error %@", error);
        LOG_D(@"syncDevice activities count %d", (int)activities.count);
        self.activitys = activities;
        /*
        long time = [[NSDate date] timeIntervalSince1970];
        NSMutableData *data = [NSMutableData data];
        [data appendData:[Fun longToByteArray:time]];
        char *ptr = "\x00\x76\x01\x00\x00\x76\x01\x00\x00\x76\x01\x00\x00\x76\x01\x00\x00";
        [data appendBytes:ptr length:17];
        NSMutableData *data2 = [NSMutableData data];
        [data2 appendData:[Fun longToByteArray:time]];
        char *ptr2 = "\x01\x76\x01\x00\x00\x76\x01\x00\x00\x76\x01\x00\x00\x76\x01\x00\x00";
        [data2 appendBytes:ptr2 length:17];
        ActivityModel *m = [ActivityModel new];
        m.time = time;
        [m setIndoorData:data];
        [m setOutdoorData:data2];
        m.macId = [Fun dataToHex:[GlobalCache shareInstance].local.deviceMAC];
        [activities addObject:m];
         */
        /*
        if (_activitys.count == 0) {
            ActivityModel *model = [ActivityModel new];
            model.macId = [Fun dataToHex:[GlobalCache shareInstance].local.deviceMAC];
//            [model reset];
            _activitys = [NSMutableArray arrayWithObject:model];
        }
        */
        [self uploadData];
    }];
}

//- (void)eventLoaded:(NSNotification*)notification {
//    //    NSLog(@"eventLoaded:%@ month:%@", _calendarManager.date, notification.object);
//    NSString *month = [GlobalCache dateToMonthString:[NSDate date]];
//    if ([month isEqualToString:notification.object]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//        NSMutableArray *event = [[GlobalCache shareInstance] searchWeeklyEventsByDay:[NSDate date]];
//        for (int i = event.count; --i >= 0; ) {
//            EventModel *m = event[i];
//            if (m.alert < 34) {
//                [event removeObjectAtIndex:i];
//            }
//        }
//        client.alertEvents = event;
//        
//        [client syncDevice];
//        self.activitys = [NSMutableArray array];
//    }
//}

//- (void)bluetoothClientSyncFinished {
//    if (_activitys.count == 0) {
//        ActivityModel *model = [ActivityModel new];
//        model.macId = [Fun dataToHex:[GlobalCache shareInstance].deviceMAC];
////        [model reset];
//        _activitys = [NSMutableArray arrayWithObject:model];
//    }
//    [self uploadData];
//}

- (void)uploadData {
    ActivityModel *model = [_activitys firstObject];
    if (model) {
        [[SwingClient sharedClient] deviceUploadRawData:model completion:^(NSError *error) {
            if (!error) {
                [_activitys removeObject:model];
                [self uploadData];
            }
            else {
                LOG_D(@"deviceUploadRawData fail: %@", error);
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                [self changeStatus:SyncStatusSyncCompleted];
            }
            
        }];
    }
    else {
        [self changeStatus:SyncStatusSyncCompleted];
    }
}

@end
