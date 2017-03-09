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
    BOOL isBecomeActive;
    
    MDRadialProgressTheme *progressTheme;
//    MDRadialProgressTheme *doneTheme;
    
    BLEClient *client;
    
    BOOL updateLoaded;
}

@property (nonatomic, strong) NSMutableArray *activitys;
@property (nonatomic, strong) CBPeripheral *peripheral;

@end

@implementation SearchDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = LOC_STR(@"Sync");
    self.statusLabel.adjustsFontSizeToFitWidth = YES;
    
    progressTheme = [[MDRadialProgressTheme alloc] init];
    progressTheme.completedColor = COMMON_TITLE_COLOR;
    progressTheme.incompletedColor = [UIColor whiteColor];
    progressTheme.centerColor = [UIColor clearColor];
    progressTheme.sliceDividerHidden = YES;
    progressTheme.thickness = 20;
    progressTheme.drawIncompleteArcIfNoProgress = YES;
    
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
    isBecomeActive = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    updateLoaded = NO;
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

- (void)didBecomeActive:(NSNotification*)notification {
    if (_status == SyncStatusSearching || (_status == SyncStatusSyncing && !updateLoaded)) {
        self.progressView.isIndeterminateProgress = YES;
    }
    if (_status == SyncStatusSyncing) {
        isBecomeActive = YES;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)changeStatus:(SyncStatus)status {
    if (_status == status) {
        return;
    }
    self.subTitleLabel.text = nil;
    switch (status) {
        case SyncStatusSearching:
        {
            self.statusLabel.text = LOC_STR(@"Searching for your device!");
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
            [client searchDevice:[Fun hexToData:[GlobalCache shareInstance].kid.macId] completion:^(CBPeripheral *peripheral, NSError *error) {
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
            self.statusLabel.text = LOC_STR(@"Found your device!");
            self.button.hidden = NO;
            
            self.progressView.isIndeterminateProgress = NO;
//            self.progressView.theme = doneTheme;
            self.progressView.progressTotal = 8;
            self.progressView.progressCounter = 8;
            
            [self setCustomBackBarButtonItem];
            
            [self.button setTitle:LOC_STR(@"Sync Now") forState:UIControlStateNormal];
        }
            break;
        case SyncStatusSyncing:
        {
            self.statusLabel.text = LOC_STR(@"Syncing");
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
            self.statusLabel.text = LOC_STR(@"Sync Completed");
            [self.button setTitle:LOC_STR(@"Go to Dashboard") forState:UIControlStateNormal];
            
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
        
        NSArray *eventArray = [DBHelper queryNearAlertEventModel:100];
        LOG_D(@"queryNearEventModel count %lu", (unsigned long)eventArray.count);
        [self changeStatus:SyncStatusSyncing];
#if TARGET_IPHONE_SIMULATOR
        [self performSelector:@selector(performStatus:) withObject:[NSNumber numberWithUnsignedInteger:SyncStatusSyncCompleted] afterDelay:3];
#else
        [self performSelector:@selector(syncAction:) withObject:eventArray afterDelay:3];
#endif
    }
    else if (_status == SyncStatusSyncCompleted) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}
/*
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
*/
- (void)syncAction:(NSArray*)eventArray {
    [client syncDevice:_peripheral event:eventArray completion:^(NSMutableArray *activities, NSError *error) {
        self.statusLabel.text = LOC_STR(@"Syncing");
        self.progressView.progressTotal = 12;
        self.progressView.progressCounter = 1;
        self.progressView.isIndeterminateProgress = YES;
        
        [SVProgressHUD dismiss];
        LOG_D(@"syncDevice error %@", error);
        
        LOG_BEG(@"Upload Activity BEGIN");
        self.activitys = [DBHelper queryActivityModel];
        LOG_D(@"TotalActivity count %d, cur count %d", (int)self.activitys.count, (int)activities.count);
        /*
        LOG_D(@"PreActivity count %lu", (unsigned long)[GlobalCache shareInstance].activitys.count);
        if ([GlobalCache shareInstance].activitys) {
            [[GlobalCache shareInstance].activitys addObjectsFromArray:activities];
//            [[GlobalCache shareInstance] cacheActivity];//Test
        }
        else {
            [GlobalCache shareInstance].activitys = activities;
        }
         */
         
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
    } update:^(float percent, NSString *remainTime) {
        self.statusLabel.text = [@"Updating Your Watch!\f" stringByAppendingString:remainTime];
        if (!updateLoaded) {
            updateLoaded = YES;
            self.progressView.progressTotal = 100;
            self.progressView.progressCounter = 0;
            self.progressView.isIndeterminateProgress = NO;
            self.subTitleLabel.text = LOC_STR(@"Please Have Your Watch Close by.");
        }
        
        int count = percent * 100;
        if (self.progressView.progressCounter != count) {
            self.progressView.progressCounter = count;
        }
    }];
}

- (void)uploadData {
    ActivityModel *model = [self.activitys firstObject];
    if (model) {
        [[SwingClient sharedClient] deviceUploadRawData:model completion:^(NSError *error) {
            if (!error) {
                [DBHelper delObject:model.obj];
                [self.activitys removeObject:model];
                [self uploadData];
            }
            else {
                
                LOG_D(@"deviceUploadRawData fail: %@", error);
                if (isBecomeActive) {
                    //如果Sync过程中出现APP被切入后台，再回到前台时将提供一次机会进行网络重试。
                    isBecomeActive = NO;
                    [self uploadData];
                    return;
                }
                
                LOG_END(@"Upload Activity END, ret count:%d", (int)self.activitys.count);
//                [[GlobalCache shareInstance] cacheActivity];
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                [self changeStatus:SyncStatusSyncCompleted];
            }
            
        }];
    }
    else {
        ENTER(@"Upload Activity Done");
//        [[GlobalCache shareInstance] clearActivity];
        [self changeStatus:SyncStatusSyncCompleted];
    }
}

@end
