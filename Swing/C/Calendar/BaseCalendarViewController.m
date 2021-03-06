//
//  BaseCalendarViewController.m
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "BaseCalendarViewController.h"
#import "LMCalendarDayView.h"
#import "LMCalendarWeekDayView.h"
#import "AddEventViewController2.h"
#import "CommonDef.h"

@interface BaseCalendarViewController ()
{
    NSDateFormatter *dateFormatter;
}

@end

@implementation BaseCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = LOC_STR(@"Calendar");
    
    if (_dateSelected == nil) {
        _dateSelected = [NSDate date];
    }
    // Generate random events sort by date using a dateformatter for the demonstration
//    [self createRandomEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventLoaded:) name:EVENT_LIST_UPDATE_NOTI object:nil];
    
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    btn.titleLabel.font = [UIFont systemFontOfSize:35];
//    [btn setTitle:@"+" forState:UIControlStateNormal];
//    [btn setTitleColor:COMMON_NAV_TINT_COLOR forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"navi_add") style:UIBarButtonItemStylePlain target:self action:@selector(addAction:)];
}

- (void)addAction:(id)sender {
    int64_t kidId = [GlobalCache shareInstance].currentKid.objId;
    if (kidId == 0) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"You have not bind device yet.")];
        return;
    }
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"Calendar" bundle:nil];
    AddEventViewController2 *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"AddEvent2"];
    ctl.delegate = self;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)leftAction:(id)sender {
    [self.calendarContentView loadPreviousPageWithAnimation];
}

- (void)rightAction:(id)sender {
    [self.calendarContentView loadNextPageWithAnimation];
}

- (void)eventLoaded:(NSNotification*)notification {
//    NSString *month = [GlobalCache dateToMonthString:_calendarManager.date];
//    if (notification.object == nil || [month isEqualToString:notification.object]) {
//        [_calendarManager reload];
//    }
    if (notification.object == nil) {
        [_calendarManager reload];
    }
}

- (void)initCalendarManager:(BOOL)weekModeEnabled {
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    _calendarManager.settings.weekModeEnabled = weekModeEnabled;
    _calendarManager.settings.weekDayFormat = JTCalendarWeekDayFormatSingle;
    
    _calendarManager.dateHelper.calendar.locale = [NSLocale localeWithLocaleIdentifier:[GlobalCache shareInstance].curLanguage];

    _calendarManager.dateHelper.calendar.firstWeekday = 2;
    [_calendarManager setMenuView:self.calendarMenuView];
    [_calendarManager setContentView:self.calendarContentView];
    
//    NSDate *date = [_calendarManager.dateHelper firstDayOfMonth:[NSDate date]];
    [_calendarManager setDate:[NSDate date]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Views customization

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_calendarManager reload];
}

- (UIView *)calendarBuildMenuItemView:(JTCalendarManager *)calendar
{
    UILabel *label = [UILabel new];
    label.textColor = COMMON_TITLE_COLOR;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldAvenirFontOfSize:20];
    
    LMArrowView *leftView = [LMArrowView new];
    LMArrowView *rightView = [LMArrowView new];
    rightView.arrow = LMArrowRight;
    
    leftView.color = RGBA(0x89, 0x85, 0x87, 1.0f);
    rightView.color = RGBA(0x89, 0x85, 0x87, 1.0f);
    
    leftView.userInteractionEnabled = NO;
    rightView.userInteractionEnabled = NO;
    
    UIButton *leftBtn = [[UIButton alloc] init];
//    [leftBtn setImage:LOAD_IMAGE(@"arrow_left") forState:UIControlStateNormal];
    [leftBtn addSubview:leftView];
    [leftBtn addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightBtn = [[UIButton alloc] init];
//    [rightBtn setImage:LOAD_IMAGE(@"arrow_right") forState:UIControlStateNormal];
    [rightBtn addSubview:rightView];
    [rightBtn addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [leftView autoSetDimensionsToSize:CGSizeMake(10, 18)];
    [leftView autoCenterInSuperviewMargins];
    [rightView autoSetDimensionsToSize:CGSizeMake(10, 18)];
    [rightView autoCenterInSuperviewMargins];
    
    [label addSubview:leftBtn];
    [label addSubview:rightBtn];
    
    [leftBtn autoSetDimensionsToSize:CGSizeMake(120, 24)];
    [leftBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [leftBtn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0];
    
    [rightBtn autoSetDimensionsToSize:CGSizeMake(120, 24)];
    [rightBtn autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [rightBtn autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:0];
    label.userInteractionEnabled = YES;
    return label;
}

- (void)calendar:(JTCalendarManager *)calendar prepareMenuItemView:(UILabel *)menuItemView date:(NSDate *)date
{
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        
        if ([[GlobalCache shareInstance].curLanguage.lowercaseString isEqualToString:@"ja"] || [[GlobalCache shareInstance].curLanguage.lowercaseString isEqualToString:@"zh-hant"]) {
            dateFormatter.dateFormat = @"MMM d日, yyyy";
        }
        else {
            dateFormatter.dateFormat = @"MMM d, yyyy";
        }
        
        dateFormatter.locale = _calendarManager.dateHelper.calendar.locale;
        dateFormatter.timeZone = _calendarManager.dateHelper.calendar.timeZone;
    }
    
    menuItemView.text = [dateFormatter stringFromDate:_dateSelected];
    //menuItemView.text = [dateFormatter stringFromDate:date];
    
    if(calendar.settings.weekModeEnabled) {
        if (![calendar.dateHelper date:date isTheSameWeekThan:_dateSelected] && ![calendar.dateHelper date:calendar.contentView.date isTheSameWeekThan:[NSDate date]]) {
            NSDate *first = [calendar.dateHelper firstWeekDayOfWeek:date];
            menuItemView.text = [dateFormatter stringFromDate:first];
        }
    }
    else {
        if (![calendar.dateHelper date:date isTheSameMonthThan:_dateSelected] && ![calendar.dateHelper date:calendar.contentView.date isTheSameWeekThan:[NSDate date]]) {
            NSDate *first = [calendar.dateHelper firstDayOfMonth:date];
            menuItemView.text = [dateFormatter stringFromDate:first];
        }
    }
}

- (UIView<JTCalendarWeekDay> *)calendarBuildWeekDayView:(JTCalendarManager *)calendar
{
    LMCalendarWeekDayView *view = [LMCalendarWeekDayView new];
    
    for(UILabel *label in view.dayViews){
        label.textColor = COMMON_TITLE_COLOR;
        label.font = [UIFont boldAvenirFontOfSize:10];
    }
    
    return view;
}

#pragma mark - CalendarManager delegate

- (UIView<JTCalendarDay> *)calendarBuildDayView:(JTCalendarManager *)calendar {
    return [LMCalendarDayView new];
}

// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(LMCalendarDayView *)dayView
{
    
    // Today
    if([calendar.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = COMMON_TITLE_COLOR;
//        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
        dayView.dotColors = @[[UIColor blackColor]];
        self.todayView = dayView;
    }
    // Selected date
    else if(_dateSelected && [calendar.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = RGBA(153, 152, 153, 1.0f);//[UIColor blueColor];
//        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Other month
    else if(![calendar.dateHelper date:calendar.contentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
//        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
        if(calendar.settings.weekModeEnabled) {
            if (![calendar.dateHelper date:calendar.contentView.date isTheSameWeekThan:[NSDate date]] && ![calendar.dateHelper date:calendar.contentView.date isTheSameWeekThan:_dateSelected]) {
                NSDate *first = [calendar.dateHelper firstWeekDayOfWeek:calendar.contentView.date];
                if ([calendar.dateHelper date:first isTheSameDayThan:dayView.date])
                {
                    dayView.circleView.hidden = NO;
                    dayView.circleView.backgroundColor = RGBA(153, 152, 153, 1.0f);
                    dayView.textLabel.textColor = [UIColor whiteColor];
                }
            }
        }
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
//        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
        if(calendar.settings.weekModeEnabled) {
            if (![calendar.dateHelper date:calendar.contentView.date isTheSameWeekThan:[NSDate date]] && ![calendar.dateHelper date:calendar.contentView.date isTheSameWeekThan:_dateSelected]) {
                NSDate *first = [calendar.dateHelper firstWeekDayOfWeek:calendar.contentView.date];
                if ([calendar.dateHelper date:first isTheSameDayThan:dayView.date])
                {
                    dayView.circleView.hidden = NO;
                    dayView.circleView.backgroundColor = RGBA(153, 152, 153, 1.0f);
                    dayView.textLabel.textColor = [UIColor whiteColor];
                }
            }
        }
        else {
            if (![calendar.dateHelper date:calendar.contentView.date isTheSameMonthThan:[NSDate date]] && ![calendar.dateHelper date:calendar.contentView.date isTheSameWeekThan:_dateSelected]) {
                NSDate *first = [calendar.dateHelper firstDayOfMonth:calendar.contentView.date];
                if ([calendar.dateHelper date:first isTheSameDayThan:dayView.date])
                {
                    dayView.circleView.hidden = NO;
                    dayView.circleView.backgroundColor = RGBA(153, 152, 153, 1.0f);
                    dayView.textLabel.textColor = [UIColor whiteColor];
                }
            }
        }
    }
    
    dayView.dotColors = [[GlobalCache shareInstance] queryEventColorForDay:dayView.date];
    [dayView setNeedsLayout];
//    if([[GlobalCache shareInstance] haveEventForDay:dayView.date]){
//        dayView.dotView.hidden = NO;
//    }
//    else{
//        dayView.dotView.hidden = YES;
//    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(LMCalendarDayView *)dayView
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
