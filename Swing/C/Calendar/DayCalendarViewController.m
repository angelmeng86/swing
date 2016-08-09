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

CGFloat const kDayCalendarViewControllerTimePading = 40.0f;

@interface DayCalendarViewController ()

@property (nonatomic, strong) NSArray *eventData;

@property (nonatomic, strong) NSArray *hourLines;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSMutableArray *eventLabels;

@end

@implementation DayCalendarViewController

/*
- (void)initFakeData
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"HH:mm";
    }
    
    NSMutableArray *mutableData = [NSMutableArray array];
    
    EventModel *model = [EventModel new];
    model.eventName = @"Walk in the park";
    model.startDate = [dateFormatter dateFromString:@"6:30"];
    model.endDate = [dateFormatter dateFromString:@"8:00"];
    model.color = RGBA(247, 202, 49, 1.0f);
    [mutableData addObject:model];
    
    model = [EventModel new];
    model.eventName = @"Swimming";
    model.startDate = [dateFormatter dateFromString:@"9:00"];
    model.endDate = [dateFormatter dateFromString:@"10:00"];
    model.color = RGBA(99, 90, 185, 1.0f);
    [mutableData addObject:model];
    
    model = [EventModel new];
    model.eventName = @"Baseball";
    model.startDate = [dateFormatter dateFromString:@"11:00"];
    model.endDate = [dateFormatter dateFromString:@"12:00"];
    model.color = RGBA(58, 187, 166, 1.0f);
    [mutableData addObject:model];
    
    model = [EventModel new];
    model.eventName = @"Walk in the park";
    model.startDate = [dateFormatter dateFromString:@"12:00"];
    model.endDate = [dateFormatter dateFromString:@"13:45"];
    model.color = RGBA(237, 47, 107, 1.0f);
    [mutableData addObject:model];
    
    _eventData = [NSArray arrayWithArray:mutableData];
}
*/
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
    
    self.eventLabels = [NSMutableArray new];
    [self loadEventData];
}

- (void)loadEventData {
    self.eventData = [[GlobalCache shareInstance] searchEventsByDay:self.dateSelected];
    self.eventData = [self.eventData sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(EventModel *obj1, EventModel * obj2) {
        return [obj1.startDate compare:obj2.startDate];
    }];
    
    for (EventModel *model in self.eventData) {
        [self addEvent:model color:model.color];
    }
    self.calendarManager.date = self.dateSelected;
}

- (void)addEvent:(EventModel*)model color:(UIColor*)color {
    if (color == nil) {
        color = [[ColorLabel colors] firstObject];
    }
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *start = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:model.startDate];
    TimeLineView *startLine = [self.hourLines objectAtIndex:[start hour]];
    float startH = [start minute] * 40 / 60;
    
    
    NSDateComponents *end = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:model.endDate];
    float height = (([end hour] - [start hour]) * 60 + [end minute] - [start minute]) * 40 / 60;
    
    EventLabel *label = [EventLabel new];
//    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldAvenirFontOfSize:20];
    label.text = model.eventName;
    label.backgroundColor = color;
    label.adjustsFontSizeToFitWidth = YES;
    label.model = model;
    
    [self.contentView addSubview:label];
    label.positionLayoutConstaint = [label autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:startLine withOffset:40];
    [label autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:startLine withOffset:kDayCalendarViewControllerTimePading / 2 + startH];
    [label autoSetDimension:ALDimensionHeight toSize:height];
    [label autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:startLine withOffset:-40];
    
    label.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDelete:)];
    [swipeGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [label addGestureRecognizer:swipeGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [label addGestureRecognizer:tapGesture];
}

- (void)tapAction:(UITapGestureRecognizer*)recognizer {
    EventLabel *label = (EventLabel *)[recognizer view];
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
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
        [[SwingClient sharedClient] calendarDeleteEvent:[NSString stringWithFormat:@"%d", label.model.objId] completion:^(NSError *error) {
            if (!error) {
                LOG_D(@"calendarDeleteEvent sucess.");
                [[GlobalCache shareInstance] deleteEvent:label.model];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
