//
//  MonthCalendarViewController.m
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "MonthCalendarViewController.h"
#import "DayCalendarViewController.h"
#import "LFSyncSheet.h"
#import "CommonDef.h"
#import "SyncNavViewController.h"
#import "SearchDeviceViewController.h"

@interface MonthCalendarViewController ()

@end

@implementation MonthCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (kDevice_Is_iPhoneX) {
        self.contentHeightLC.constant = 400;
    }
    
    [self initCalendarManager:NO];
    
    [self.syncBtn setTitle:LOC_STR(@"Sync Now") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CalendarManager delegate

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    
    if ([_delegate respondsToSelector:@selector(monthCalendarDidSelected:)]) {
        [_delegate monthCalendarDidSelected:dayView.date];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
    
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
        DayCalendarViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"DayCalendar"];
        ctl.dateSelected = dayView.date;
        [self.navigationController pushViewController:ctl animated:YES];
    }
    /*
    _dateSelected = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    
    // Don't change page in week mode because block the selection of days in first and last weeks of the month
    if(_calendarManager.settings.weekModeEnabled){
        return;
    }
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
    */
}

- (IBAction)syncAction:(id)sender {
    if ([GlobalCache shareInstance].currentKid) {
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
