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
    self.timeLabel.text = nil;
    self.descLabel.text = nil;
}

- (void)loadEventView {
    NSArray *events = [[GlobalCache shareInstance] searchEventsByDay:self.dateSelected];
    if (events.count > 0) {
        if (events.count > 1) {
            events = [events sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(EventModel *obj1, EventModel * obj2) {
                return [obj1.startDate compare:obj2.startDate];
            }];
        }
        for (EventModel *event in events) {
            if (NSOrderedDescending == [event.startDate compare:[NSDate date]]) {
                static NSDateFormatter *dateFormatter;
                if(!dateFormatter){
                    dateFormatter = [NSDateFormatter new];
                    dateFormatter.dateFormat = @"HH:mm";
                }
                self.timeLabel.text = [dateFormatter stringFromDate:event.startDate];
                self.descLabel.text = event.eventName;
                
                NSCalendar *cal = [NSCalendar currentCalendar];
                NSDateComponents *start = [cal components:NSHourCalendarUnit fromDate:event.startDate];
                
                self.progressView.progressCounter = 1;
                self.progressView.startingSlice = [start hour] % 12;
                return;
            }
        }
        
    }
    self.timeLabel.text = @"No Event";
    self.descLabel.text = nil;
    self.progressView.progressCounter = 0;
}

- (void)eventLoaded:(NSNotification*)notification {
    [super eventLoaded:notification];
    [self loadEventView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"calendar_icon") style:UIBarButtonItemStylePlain target:self action:@selector(modeAction:)];
    [super viewWillAppear:animated];
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

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if (sender == self.monthBtn) {
//        MonthCalendarViewController *ctl = segue.destinationViewController;
//        ctl.delegate = self;
//    }
//    else if (sender == self.todayBtn) {
////        DayCalendarViewController *ctl = segue.destinationViewController;
//    }
//}

- (void)monthCalendarDidSelected:(NSDate*)date {
    self.dateSelected = date;
    [self.calendarManager setDate:date];
    [self loadEventView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CalendarManager delegate

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(LMCalendarDayView *)dayView
{
    if (dayView.dotColors.count > 0) {
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
        DayCalendarViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"DayCalendar"];
        ctl.dateSelected = dayView.date;
        [self.navigationController pushViewController:ctl animated:YES];
    }
    else {
        [super calendar:calendar didTouchDayView:dayView];
    }
}

- (IBAction)todayAction:(id)sender {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    DayCalendarViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"DayCalendar"];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (IBAction)monthlyAction:(id)sender {
    
}

@end
