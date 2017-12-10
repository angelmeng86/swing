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
    SyncStatusSyncCompleted,
    SyncStatusNotFound,
} SyncStatus;

@interface SearchDeviceViewController ()
{
    NSUInteger _status;
    BOOL isBecomeActive;
    
    MDRadialProgressTheme *progressTheme;
//    MDRadialProgressTheme *doneTheme;
    
    UIImageView *iconView;
    
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
    self.button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
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
    iconView = [UIImageView new];
    [self.view addSubview:iconView];
    [self.view sendSubviewToBack:iconView];
//    [iconView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.progressView];
//    [iconView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.progressView];
//    [iconView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.progressView];
    
    [iconView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:self.progressView withMultiplier:0.45];
    [iconView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.progressView withMultiplier:0.45];
    [iconView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [iconView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.progressView withOffset:-5];
    
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
    if (self.navigationController.viewControllers.count == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [super backAction];
    }
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
    self.button2.hidden = YES;
    iconView.image = nil;
    self.statusLabelLC.constant = 195;
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
            [client searchDevice:[Fun hexToData:[GlobalCache shareInstance].currentKid.macId] completion:^(CBPeripheral *peripheral, NSError *error) {
                if (!error) {
                    self.peripheral = peripheral;
                    [self changeStatus:SyncStatusFound];
                }
                else {
                    LOG_D(@"searchDevice error:%@", error);
                    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                    //[self backAction];
                    [self changeStatus:SyncStatusNotFound];
                }
            }];
#endif
        }
            break;
        case SyncStatusFound:
        {
            self.statusLabel.text = LOC_STR(@"Found!");
            iconView.image = LOAD_IMAGE(@"happy_sync_icon");
            self.statusLabelLC.constant = 130;
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
            self.statusLabel.text = LOC_STR(@"Completed");
            self.statusLabelLC.constant = 130;
            iconView.image = LOAD_IMAGE(@"happy_sync_icon");
            [self.button setTitle:LOC_STR(@"Go to dashboard") forState:UIControlStateNormal];
            
            self.progressView.isIndeterminateProgress = NO;
//            self.progressView.theme = doneTheme;
            self.progressView.progressTotal = 8;
            self.progressView.progressCounter = 8;
            
            self.navigationItem.leftBarButtonItem = nil;
            self.button.hidden = NO;
            
            if (updateLoaded) {
                self.statusLabel.text = LOC_STR(@"Update Completed!");
                self.subTitleLabel.text = LOC_STR(@"Please Press the Button on Your Watch and Sync Again. Major update is incomplete, it will restart again during next sync.");
            }
        }
            break;
        case SyncStatusNotFound:
        {
            self.statusLabel.text = LOC_STR(@"We can't find your watch!");
            self.statusLabelLC.constant = 130;
            iconView.image = LOAD_IMAGE(@"unhappy_sync_icon");
            self.button.hidden = NO;
            self.button2.hidden = NO;
            
            self.progressView.isIndeterminateProgress = NO;
            self.progressView.progressTotal = 8;
            self.progressView.progressCounter = 0;
            
            [self setCustomBackBarButtonItem];
            
            [self.button setTitle:LOC_STR(@"Try again") forState:UIControlStateNormal];
            [self.button2 setTitle:LOC_STR(@"Go to last synced data") forState:UIControlStateNormal];
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
    else if (_status == SyncStatusNotFound) {
        //Try again
        [self changeStatus:SyncStatusSearching];
    }
}

- (IBAction)btn2Action:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)syncAction:(NSArray*)eventArray {
    [client syncDevice:_peripheral macAddress:nil/*[GlobalCache shareInstance].kid.macId*/ event:eventArray completion:^(NSMutableArray *activities, NSError *error, int battery, NSString *macId) {
        [self changeStatus:SyncStatusSyncing];
        self.statusLabel.text = LOC_STR(@"Uploading");
        
        [SVProgressHUD dismiss];
        LOG_D(@"syncDevice error %@", error);
        
        LOG_BEG(@"Upload Activity BEGIN");
        self.activitys = [DBHelper queryActivityModel];
        LOG_D(@"TotalActivity count %d, cur count %d", (int)self.activitys.count, (int)activities.count);
        
//        [self uploadBattery:battery];
        [self checkMacId:macId battery:battery];
    } update:^(float percent, NSString *remainTime) {
        NSString *text = [LOC_STR(@"Updating Your Watch!") stringByAppendingString:@"\f"];
        self.statusLabel.text = [text stringByAppendingString:remainTime];
        if (!updateLoaded) {
            updateLoaded = YES;
            iconView.image = nil;
            self.statusLabelLC.constant = 195;
            self.progressView.progressTotal = 100;
            self.progressView.progressCounter = 0;
            self.progressView.isIndeterminateProgress = NO;
            self.subTitleLabel.text = LOC_STR(@"Please Have Your Watch Close by. the watch is locked during sync.");
        }
        
        int count = percent * 100;
        if (self.progressView.progressCounter != count) {
            self.progressView.progressCounter = count;
        }
    }  check:!self.needUpdate];
}

- (void)uploadBattery:(int)battery
{
    if (battery < 0) {
        [self uploadData];
    }
    else {
        [[SwingClient sharedClient] kidsUploadBatteryStatus:battery macId:[GlobalCache shareInstance].currentKid.macId completion:^(NSError *error) {
            if (!error) {
                LOG_D(@"kidsBatteryStatus success.");
            }
            else {
                LOG_D(@"kidsBatteryStatus fail: %@", error);
            }
            [self uploadData];
        }];
    }
}

- (void)checkMacId:(NSString*)realMac battery:(int)battery {
    if (realMac && ![[GlobalCache shareInstance].currentKid.macId isEqualToString:realMac]) {
        LOG_D(@"macId is reverse.");
//        realMac = [Fun dataToHex:[Fun dataReversal:[Fun hexToData:realMac]]];//后台又做了倒置，所以我们还得倒置成反的。。。
        [[SwingClient sharedClient] updateKidRevertMacID:[GlobalCache shareInstance].currentKid.objId macId:realMac completion:^(NSError *error) {
            if (!error) {
                LOG_D(@"updateKidRevertMacID success.");
                [GlobalCache shareInstance].currentKid.macId = realMac;
                [DBHelper saveDatabase];
                [self uploadData];
            }
            else {
                LOG_D(@"updateKidRevertMacID fail: %@", error);
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                [self changeStatus:SyncStatusSyncCompleted];
            }
            
        }];
    }
    else {
        [self uploadBattery:battery];
    }
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
