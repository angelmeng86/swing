//
//  BaseCalendarViewController.m
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "BaseCalendarViewController.h"
#import "CommonDef.h"

@interface BaseCalendarViewController ()
//{
//    NSMutableDictionary *_eventsByDate;
//}

@end

@implementation BaseCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (_dateSelected == nil) {
        _dateSelected = [NSDate date];
    }
    // Generate random events sort by date using a dateformatter for the demonstration
//    [self createRandomEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventLoaded:) name:EVENT_LIST_UPDATE_NOTI object:nil];
    [[GlobalCache shareInstance] queryMonthEvents:_dateSelected];
}

- (void)eventLoaded:(NSNotification*)notification {
//    NSLog(@"eventLoaded:%@ month:%@", _calendarManager.date, notification.object);
    NSString *month = [[GlobalCache shareInstance] dateToMonthString:_calendarManager.date];
    if ([month isEqualToString:notification.object]) {
        [_calendarManager reload];
    }
}

- (void)initCalendarManager:(BOOL)weekModeEnabled {
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    _calendarManager.settings.weekModeEnabled = weekModeEnabled;
    
    [_calendarManager setMenuView:self.calendarMenuView];
    [_calendarManager setContentView:self.calendarContentView];
    [_calendarManager setDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
// Used only to have a key for _eventsByDate
- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(_eventsByDate[key] && [_eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
    
}

- (void)createRandomEvents
{
    _eventsByDate = [NSMutableDictionary new];
    
    for(int i = 0; i < 30; ++i){
        // Generate 30 random dates between now and 60 days later
        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
        
        // Use the date as key for eventsByDate
        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
        
        if(!_eventsByDate[key]){
            _eventsByDate[key] = [NSMutableArray new];
        }
        
        [_eventsByDate[key] addObject:@"OYE"];
    }
}
*/
#pragma mark - Views customization

//- (BOOL)calendar:(JTCalendarManager *)calendar canDisplayPageWithDate:(NSDate *)date {
//    NSLog(@"canDisplayPageWithDate:%@", date);
//    return YES;
//}

//- (NSDate *)calendar:(JTCalendarManager *)calendar dateForPreviousPageWithCurrentDate:(NSDate *)currentDate{
//    NSLog(@"dateForPreviousPageWithCurrentDate:%@", currentDate);
//    return currentDate;
//}

/*!
 * Provide the date for the next page.
 * Return 1 month after the current date by default.
 */
//- (NSDate *)calendar:(JTCalendarManager *)calendar dateForNextPageWithCurrentDate:(NSDate *)currentDate {
//    NSLog(@"dateForPreviousPageWithCurrentDate:%@", currentDate);
//    return currentDate;
//}

/*!
 * Indicate the previous page became the current page.
 */
- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar {
    NSLog(@"calendarDidLoadPreviousPage:%@", calendar.date);
    [[GlobalCache shareInstance] queryMonthEvents:calendar.date];
}

/*!
 * Indicate the next page became the current page.
 */
- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar {
    NSLog(@"calendarDidLoadNextPage:%@", calendar.date);
    [[GlobalCache shareInstance] queryMonthEvents:calendar.date];
}

- (UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar
{
    UILabel *label = [UILabel new];
    label.textColor = COMMON_TITLE_COLOR;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldAvenirFontOfSize:18];
    
    return label;
}

- (void)calendar:(JTCalendarManager *)calendar prepareMenuItemView:(UILabel *)menuItemView date:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"MMM d, yyyy";
        
        dateFormatter.locale = _calendarManager.dateHelper.calendar.locale;
        dateFormatter.timeZone = _calendarManager.dateHelper.calendar.timeZone;
    }
    
    menuItemView.text = [dateFormatter stringFromDate:date];
}

- (UIView<JTCalendarWeekDay> *)calendarBuildWeekDayView:(JTCalendarManager *)calendar
{
    JTCalendarWeekDayView *view = [JTCalendarWeekDayView new];
    
    for(UILabel *label in view.dayViews){
        label.textColor = [UIColor blackColor];
        label.font = [UIFont avenirFontOfSize:10];
    }
    
    return view;
}

#pragma mark - CalendarManager delegate

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    // Today
    if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor redColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor blueColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:calendar.contentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
    
    if([[GlobalCache shareInstance] haveEventForDay:dayView.date]){
        dayView.dotView.hidden = NO;
    }
    else{
        dayView.dotView.hidden = YES;
    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
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
    
    if(![_calendarManager.dateHelper date:calendar.contentView.date isTheSameMonthThan:dayView.date]){
        if([calendar.contentView.date compare:dayView.date] == NSOrderedAscending){
            [calendar.contentView loadNextPageWithAnimation];
        }
        else{
            [calendar.contentView loadPreviousPageWithAnimation];
        }
    }
}

#pragma mark - Getters

- (JTCalendarMenuView *)calendarMenuView {
    return nil;
}

- (JTHorizontalCalendarView *)calendarContentView {
    return nil;
}

@end
