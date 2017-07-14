//
//  CalendarViewController.m
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "CalendarViewController.h"
#import "MonthCalendarViewController.h"
#import "DayCalendarViewController.h"
#import "CommonDef.h"
#import "MDRadialProgressView.h"
#import "LMCalendarDayView.h"
#import "LFSyncSheet.h"
#import "SyncNavViewController.h"

@interface CalendarViewController ()

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initCalendarManager:YES];
    
    self.progressView.progressTotal = 12;
    self.progressView.progressCounter = 0;
    self.progressView.clockwise = YES;
    self.progressView.theme.completedColor = COMMON_TITLE_COLOR;
    self.progressView.theme.incompletedColor = [UIColor whiteColor];
    self.progressView.theme.thickness = 20;
    self.progressView.theme.sliceDividerHidden = YES;
    self.progressView.theme.drawIncompleteArcIfNoProgress = YES;
    self.progressView.label.hidden = YES;
    
    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.descLabel.adjustsFontSizeToFitWidth = YES;
    [self setTimeDesc:LOC_STR(@"No Event") desc:nil];
    
    self.todayBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.monthBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.todayBtn setTitle:LOC_STR(@"Today's Schedule") forState:UIControlStateNormal];
    [self.monthBtn setTitle:LOC_STR(@"Monthly Schedule") forState:UIControlStateNormal];
    [self.syncBtn setTitle:LOC_STR(@"Sync Now") forState:UIControlStateNormal];
}

- (void)setTimeDesc:(NSString*)time desc:(NSString*)desc {
    self.timeLabel.text = time;
    self.descLabel.text = desc;
    
    self.descLabel.hidden = desc.length > 0 ? NO : YES;
    self.timeHeightConstraint.constant = desc.length > 0 ? 50 : 100;
}

- (void)loadEventView {
    NSArray *events = [DBHelper queryEventModelByDay:self.dateSelected];
    if (events.count > 0) {
        for (EventModel *event in events) {
            if (NSOrderedDescending == [Fun compareTimePart:event.startDate andDate:[NSDate date]]) {
                static NSDateFormatter *dateFormatter;
                if(!dateFormatter){
                    dateFormatter = [NSDateFormatter new];
                    dateFormatter.dateFormat = @"HH:mm";
                }
                
                [self setTimeDesc:[dateFormatter stringFromDate:event.startDate] desc:event.eventName];
                
                NSCalendar *cal = [NSCalendar currentCalendar];
                NSDateComponents *start = [cal components:NSCalendarUnitHour fromDate:event.startDate];
                
                self.progressView.progressCounter = 1;
                if([start hour] % 12 == 0) {
                    self.progressView.startingSlice = 12;
                }
                else {
                    self.progressView.startingSlice = [start hour] % 12;
                }
                
                return;
            }
        }
        
    }
    [self setTimeDesc:LOC_STR(@"No Event") desc:nil];
    self.progressView.progressCounter = 0;
}

- (void)eventLoaded:(NSNotification*)notification {
    [super eventLoaded:notification];
//    [self loadEventView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.leftBarButtonItem = nil;
    
    //当被隐藏时恢复原状
    if (!self.calendarManager.settings.weekModeEnabled) {
        self.progressView.hidden = NO;
        self.monthBtn.hidden = NO;
        self.todayBtn.hidden = NO;
        self.timeLabel.hidden = NO;
        self.descLabel.hidden = NO;
        self.calendarHeight.constant = 70;
        self.calendarManager.settings.weekModeEnabled = !self.calendarManager.settings.weekModeEnabled;
        [self.calendarManager reload];
        [self.view layoutIfNeeded];
    }
    [self.calendarManager setDate:[NSDate date]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"calendar_icon") style:UIBarButtonItemStylePlain target:self action:@selector(modeAction:)];
    [self loadEventView];
}

- (void)modeAction:(id)sender {
    if (!self.calendarManager.settings.weekModeEnabled) {
        self.progressView.hidden = NO;
        self.monthBtn.hidden = NO;
        self.todayBtn.hidden = NO;
        self.timeLabel.hidden = NO;
        self.descLabel.hidden = NO;
        self.calendarHeight.constant = 70;
    }
    else {
        self.progressView.hidden = YES;
        self.monthBtn.hidden = YES;
        self.todayBtn.hidden = YES;
        self.timeLabel.hidden = YES;
        self.descLabel.hidden = YES;
        self.calendarHeight.constant = 300;
    }
    self.calendarManager.settings.weekModeEnabled = !self.calendarManager.settings.weekModeEnabled;
    [self.calendarManager reload];
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if (sender == self.monthBtn) {
//        MonthCalendarViewController *ctl = segue.destinationViewController;
//        ctl.delegate = self;
//    }
//    else if (sender == self.todayBtn) {
////        DayCalendarViewController *ctl = segue.destinationViewController;
//    }
//}

//- (void)monthCalendarDidSelected:(NSDate*)date {
//    self.dateSelected = date;
//    [self.calendarManager setDate:date];
//    [self loadEventView];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CalendarManager delegate

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(LMCalendarDayView *)dayView
{
//    if (dayView.dotColors.count > 0) {
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
        DayCalendarViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"DayCalendar"];
        ctl.dateSelected = dayView.date;
        [self.navigationController pushViewController:ctl animated:YES];
//    }
//    else {
//        [super calendar:calendar didTouchDayView:dayView];
//    }
}

- (IBAction)todayAction:(id)sender {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    DayCalendarViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"DayCalendar"];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (IBAction)monthlyAction:(id)sender {
    
}

- (IBAction)syncAction:(id)sender {
    if ([GlobalCache shareInstance].kid) {
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"SyncDevice" bundle:nil];
        UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"Syncing"];
        SyncNavViewController *navCtl = [[SyncNavViewController alloc] initWithRootViewController:ctl];
        [self presentViewController:navCtl animated:YES completion:nil];
    }
    else {
        [SVProgressHUD showErrorWithStatus:LOC_STR(@"you have not bind device yet, please sync a watch.")];
    }
    /*
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"SyncDevice" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateInitialViewController];
    [self presentViewController:ctl animated:YES completion:nil];
     */
}

- (void)eventViewDidAdded:(NSDate*)date
{
    if (![GlobalCache shareInstance].local.disableSyncTip) {
        UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
        CGRect rect = [self.syncBtn convertRect:self.syncBtn.bounds toView:window];
        
        LFSyncSheet *sheet = [LFSyncSheet actionSheetViewWithBlock:^(LFSyncSheet *actionSheet, BOOL check) {
            if (check) {
                [GlobalCache shareInstance].local.disableSyncTip = check;
                [[GlobalCache shareInstance] saveInfo];
            }
        }];
        [sheet showArrow:rect];
    }
}

@end
