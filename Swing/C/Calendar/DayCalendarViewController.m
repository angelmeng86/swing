//
//  DayCalendarViewController.m
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "DayCalendarViewController.h"
#import "TimeLineView.h"
#import "EventLabel.h"
#import "CommonDef.h"

CGFloat const kDayCalendarViewControllerTimePading = 40.0f;

@interface DayCalendarViewController ()

@property (nonatomic, strong) NSArray *eventData;
@property (nonatomic, strong) NSArray *eventColors;

@property (nonatomic, strong) NSArray *hourLines;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation DayCalendarViewController

- (void)initFakeData
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"HH:mm";
    }
    
    NSMutableArray *mutableData = [NSMutableArray array];
    
    EventModel *model = [EventModel new];
    model.name = @"Walk in the park";
    model.start = [dateFormatter dateFromString:@"6:30"];
    model.end = [dateFormatter dateFromString:@"8:00"];
    [mutableData addObject:model];
    
    model = [EventModel new];
    model.name = @"Swimming";
    model.start = [dateFormatter dateFromString:@"9:00"];
    model.end = [dateFormatter dateFromString:@"10:00"];
    [mutableData addObject:model];
    
    model = [EventModel new];
    model.name = @"Baseball";
    model.start = [dateFormatter dateFromString:@"11:00"];
    model.end = [dateFormatter dateFromString:@"12:00"];
    [mutableData addObject:model];
    
    model = [EventModel new];
    model.name = @"Walk in the park";
    model.start = [dateFormatter dateFromString:@"12:00"];
    model.end = [dateFormatter dateFromString:@"13:45"];
    [mutableData addObject:model];
    
    _eventData = [NSArray arrayWithArray:mutableData];
    
    _eventColors = @[RGBA(247, 202, 49, 1.0f), RGBA(99, 90, 185, 1.0f), RGBA(58, 187, 166, 1.0f), RGBA(237, 47, 107, 1.0f)];
}

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initCalendarManager:YES];
    
    [self initFakeData];
    
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
    
    [self loadEventData];
}

- (void)loadEventData {
    int i = 0;
    for (EventModel *model in self.eventData) {
        [self addEvent:model color:[_eventColors objectAtIndex:i % 4]];
        i++;
    }
}

- (void)addEvent:(EventModel*)model color:(UIColor*)color {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *start = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:model.start];
    TimeLineView *startLine = [self.hourLines objectAtIndex:[start hour]];
    float startH = [start minute] * 40 / 60;
    
    
    NSDateComponents *end = [cal components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:model.end];
    float height = (([end hour] - [start hour]) * 60 + [end minute] - [start minute]) * 40 / 60;
    
//    NSTimeInterval interval = [model.end timeIntervalSince1970] - [model.start timeIntervalSince1970];
//    float height = interval / 60 * 40 / 60;
    
    EventLabel *label = [EventLabel new];
//    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldAvenirFontOfSize:20];
    label.text = model.name;
    label.backgroundColor = color;
    
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
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"EventInfo"];
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