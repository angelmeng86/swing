//
//  CalendarViewController.m
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "CalendarViewController.h"
#import "MonthCalendarViewController.h"
#import "CommonDef.h"

@interface CalendarViewController ()

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initCalendarManager:YES];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender == self.monthBtn) {
        MonthCalendarViewController *ctl = segue.destinationViewController;
        ctl.delegate = self;
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
    [super calendar:calendar didTouchDayView:dayView];
}

@end
