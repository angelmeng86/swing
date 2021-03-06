//
//  DayCalendarViewController.m
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "DayCalendarViewController.h"
#import "EventInfoViewController.h"
#import "TimeLineView.h"
#import "EventLabel.h"
#import "CommonDef.h"
#import "ColorLabel.h"
#import "LMCalendarDayView.h"
#import "MonthCalendarViewController.h"
#import "AddEventViewController2.h"
#import "CalendarViewController.h"

CGFloat const kDayCalendarViewControllerTimePading = 40.0f;

@interface DayCalendarViewController ()

@property (nonatomic, strong) NSArray *eventData;

@property (nonatomic, strong) NSArray *hourLines;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSMutableArray *eventLabels;

@end

@implementation DayCalendarViewController

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initCalendarManager:YES];
    
    UIView *contentView = [UIView new];
    self.contentView = contentView;
    [self.scrollView addSubview:contentView];
    [contentView autoPinEdgesToSuperviewEdges];
    [contentView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.scrollView];
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i <= 12; i++) {
        TimeLineView *view = [[TimeLineView alloc] init];
        view.textLabel.text = [NSString stringWithFormat:@"%d AM", i];
        [contentView addSubview:view];
        [array addObject:view];
    }
    for (int i = 1; i <= 12; i++) {
        TimeLineView *view = [[TimeLineView alloc] init];
        view.textLabel.text = [NSString stringWithFormat:@"%d PM", i];
        [contentView addSubview:view];
        [array addObject:view];
    }
    UIView *firstView = [array firstObject];
    [firstView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
    [firstView autoSetDimension:ALDimensionHeight toSize:kDayCalendarViewControllerTimePading];
    
    [array autoAlignViewsToEdge:ALEdgeLeading];
    [array autoAlignViewsToEdge:ALEdgeTrailing];
    [array autoMatchViewsDimension:ALDimensionHeight];
    
    UIView *previousView = nil;
    for (UIView *v in array) {
        if (previousView) {
            [v autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:previousView];
        }
        previousView = v;
    }
    
    UIView *lastView = [array lastObject];
    [lastView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    self.hourLines = array;
    
    self.calendarManager.date = self.dateSelected;
//    [self reloadEventData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    ctl.currentDate = self.dateSelected;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)eventLoaded:(NSNotification*)notification {
    [super eventLoaded:notification];
    [self reloadData];
    [self reloadEventData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"calendar_icon") style:UIBarButtonItemStylePlain target:self action:@selector(modeAction:)];
    [super viewWillAppear:animated];
    [self reloadData];
    [self reloadEventData];
}

- (void)didBecomeActive:(NSNotification*)notification {
    [self reloadData];
}

- (void)reloadData {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *start = [cal components:NSCalendarUnitHour fromDate:[NSDate date]];
    for (int i = (int)_hourLines.count; --i >= 0;) {
        TimeLineView *view = _hourLines[i];
        if (i == [start hour] && [cal isDateInToday:self.dateSelected]) {
            view.lineColor = COMMON_TITLE_COLOR;
        }
        else {
            view.lineColor = nil;
        }
        [view setNeedsDisplay];
    }
}

- (void)modeAction:(id)sender {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    MonthCalendarViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"MonthCalendar"];
    ctl.delegate = self;
    [self.navigationController pushViewController:ctl animated:YES];
    
//    if (!self.calendarManager.settings.weekModeEnabled) {
//        self.scrollView.hidden = NO;
//        self.monthBtn.hidden = NO;
//        self.todayBtn.hidden = NO;
//        self.timeLabel.hidden = NO;
//        self.descLabel.hidden = NO;
//        self.calendarHeight.constant = 70;
//    }
//    else {
//        self.scrollView.hidden = YES;
//        self.monthBtn.hidden = YES;
//        self.todayBtn.hidden = YES;
//        self.timeLabel.hidden = YES;
//        self.descLabel.hidden = YES;
//        self.calendarHeight.constant = 300;
//    }
//    self.calendarManager.settings.weekModeEnabled = !self.calendarManager.settings.weekModeEnabled;
//    [self.calendarManager reload];
//    [UIView animateWithDuration:0.3f animations:^{
//        [self.view layoutIfNeeded];
//    }];
    
}

- (void)monthCalendarDidSelected:(NSDate*)date {
    self.dateSelected = date;
    [self.calendarManager setDate:date];
    [self reloadData];
    [self reloadEventData];
}

- (void)reloadEventData {
    for (UIView *view in _eventLabels) {
        [view removeFromSuperview];
    }
    
    self.eventLabels = [NSMutableArray new];
    self.eventData = [DBHelper queryEventModelByDay:self.dateSelected];
//    self.eventData = [self.eventData sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(EventModel *obj1, EventModel * obj2) {
//        return [Fun compareTimePart:obj1.startDate andDate:obj2.startDate];
//    }];
    
    NSMutableArray *colArray = [NSMutableArray array];
    for (EventModel *model in self.eventData) {
        if (colArray.count > 0) {
            EventModel *m = [colArray lastObject];
            if (NSOrderedDescending != [Fun compareTimePart:m.minEndDate andDate:model.startDate]) {
            /*if (NSOrderedDescending != [m.minEndDate compare:model.startDate]) {*/
                if (colArray.count == 1) {
                    [self addEvent:m];
                }
                else {
                    [self addEvents:colArray];
                }
                [colArray removeAllObjects];
            }
        }
        [colArray addObject:model];
    }
    
    if (colArray.count == 1) {
        EventModel *m = [colArray lastObject];
        [self addEvent:m];
    }
    else {
        [self addEvents:colArray];
    }
    
    
//    for (EventModel *model in self.eventData) {
//        [self addEvent:model];
//    }
    
}

- (EventLabel*)createEvent:(EventModel*)model {
    UIColor *color = model.color;
    if (color == nil) {
        color = [[ColorLabel colors] firstObject];
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *start = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:model.startDate];
    
    NSInteger hour = [start hour];
    
    TimeLineView *startLine = [self.hourLines objectAtIndex:hour];
    float startH = [start minute] * 40 / 60;
    
//    NSTimeInterval ti = [model.minEndDate timeIntervalSinceDate:model.startDate];
//    float height = (ti / 60) * 40 / 60;
    
    NSDateComponents *end = [cal components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:model.endDate];
    float height = (([end hour] - [start hour]) * 60 + [end minute] - [start minute]) * 40 / 60;
    if (height < 20) {
        //最小半格
        height = 20;
    }
    
    EventLabel *label = [EventLabel new];
//    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldAvenirFontOfSize:20];
    label.text = model.eventName;
    label.backgroundColor = color;
//    label.adjustsFontSizeToFitWidth = YES;
    label.model = model;
    
    [self.contentView addSubview:label];
    [self.eventLabels addObject:label];
//    label.positionLayoutConstaint = [label autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:startLine withOffset:40];
    [label autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:startLine withOffset:kDayCalendarViewControllerTimePading / 2 + startH];
    [label autoSetDimension:ALDimensionHeight toSize:height];
//    [label autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:startLine withOffset:-40];
    
    label.userInteractionEnabled = YES;
    //注释滑动删除功能
//    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDelete:)];
//    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
//    [label addGestureRecognizer:swipeGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [label addGestureRecognizer:tapGesture];
    
    return label;
}

- (void)addEvents:(NSArray*)array {
    float width = (kDeviceWidth - 40) / array.count;
    for (int i = 0; i < array.count; i++) {
        EventModel *model = array[i];
        EventLabel *label = [self createEvent:model];
        if (label) {
            [label autoSetDimension:ALDimensionWidth toSize:width];
            label.positionLayoutConstaint = [label autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:40 + i * width];
        }
    }
}

- (void)addEvent:(EventModel*)model {
    EventLabel *label = [self createEvent:model];
    if (label) {
        label.positionLayoutConstaint = [label autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:40];
        [label autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:label.superview withOffset:-40];
    }
}

- (void)tapAction:(UITapGestureRecognizer*)recognizer {
    EventLabel *label = (EventLabel *)[recognizer view];
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"Calendar" bundle:nil];
    EventInfoViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"EventInfo"];
    ctl.dateSelected = self.dateSelected;
    ctl.model = label.model;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)swipeToDelete:(UISwipeGestureRecognizer *)recognizer {
    EventLabel *label = (EventLabel *)[recognizer view];
    label.positionLayoutConstaint.constant += kDeviceWidth;
    
    [UIView animateWithDuration:0.5f animations:^{
        label.alpha = 0.0;
        [label.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
        [[SwingClient sharedClient] calendarDeleteEvent:label.model.objId completion:^(NSError *error) {
            if (!error) {
                LOG_D(@"calendarDeleteEvent sucess.");
                [[GlobalCache shareInstance] postUpdateNotification:label.model.startDate];
            }
            else {
                LOG_D(@"calendarDeleteEvent fail: %@", error);
            }
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(LMCalendarDayView *)dayView
{
    [super calendar:calendar didTouchDayView:dayView];
    [self reloadData];
    [self reloadEventData];
}

- (void)eventViewDidAdded:(NSDate*)date {
    self.dateSelected = date;
    [self.calendarManager setDate:date];
    [self reloadData];
    [self reloadEventData];
    
    
    for (UIViewController *ctl in self.navigationController.viewControllers) {
        if ([ctl isKindOfClass:[CalendarViewController class]]) {
            CalendarViewController *calendar = (CalendarViewController*)ctl;
            [calendar eventViewDidAdded:date];
            break;
        }
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

@end
