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

@interface CalendarViewController ()

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initCalendarManager:YES];
    
    self.progressView.progressTotal = 12;
    self.progressView.progressCounter = 1;
    self.progressView.startingSlice = 2;
    self.progressView.clockwise = YES;
    self.progressView.theme.completedColor = COMMON_TITLE_COLOR;
    self.progressView.theme.incompletedColor = [UIColor whiteColor];
    self.progressView.theme.thickness = 20;
    self.progressView.theme.sliceDividerHidden = YES;
    self.progressView.label.hidden = YES;
    
    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.descLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Mode" style:UIBarButtonItemStylePlain target:self action:@selector(modeAction:)];
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

- (void)addAction:(id)sender {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"AddEvent"];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender == self.monthBtn) {
        MonthCalendarViewController *ctl = segue.destinationViewController;
        ctl.delegate = self;
    }
    else if (sender == self.todayBtn) {
//        DayCalendarViewController *ctl = segue.destinationViewController;
    }
}

- (void)monthCalendarDidSelected:(NSDate*)date {
    self.dateSelected = date;
    [self.calendarManager setDate:date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CalendarManager delegate

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
//    [super calendar:calendar didTouchDayView:dayView];
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    DayCalendarViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"DayCalendar"];
    ctl.dateSelected = dayView.date;
    [self.navigationController pushViewController:ctl animated:YES];
}

@end
