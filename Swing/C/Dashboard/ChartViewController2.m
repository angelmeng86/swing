//
//  ChartViewController.m
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ChartViewController2.h"
#import "CommonDef.h"
#import "JBBarChartView.h"
#import "JBLineChartView.h"
#import "ChartFooterView.h"
#import "LMBarView.h"
#import "JBChartTooltipView.h"
#import "JBChartTooltipTipView.h"
#import "LMArrowView.h"
#import "RoundButton.h"
#import "StepsTableViewController.h"
#import "LFLineView.h"
#import "LMArrowLabel.h"

// Numerics
static CGFloat const kJBBarChartViewControllerBarPadding = 20.0f;

#define CHART_VIEW_LINE_VALUE       12000.0f

@interface ChartViewController2 ()<JBBarChartViewDelegate, JBBarChartViewDataSource, ChartFooterViewDelegate>
{
    NSURLSessionDataTask *task;
    UIButton *indoorBtn;
    UIButton *outdoorBtn;
    NSDateFormatter *localeDateFormatter;
    
    NSLayoutConstraint *standardLC;
    CGFloat lineValue;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) JBBarChartView *stepsChartView;

@property (nonatomic, strong) ChartFooterView *stepFooter;

@property (nonatomic, strong) UIColor *stepChartColor;

@property (nonatomic, strong) NSDictionary *stepChartData;

@property (nonatomic, strong) NSDictionary *indoorData;
@property (nonatomic, strong) NSDictionary *outdoorData;

@property (nonatomic) BOOL isLoadData;

@end

@implementation ChartViewController2

//- (void)initFakeData:(int)count value:(int)value
//{
//    NSMutableArray *mutableChartData = [NSMutableArray array];
//    for (int i=0; i<count; i++)
//    {
//        NSInteger delta = (count - labs((count - i) - i)) + 2;
//        if (value < 0) {
//            [mutableChartData addObject:[NSNumber numberWithFloat:MAX((delta * kJBBarChartViewControllerMinBarHeight), arc4random() % (delta * kJBBarChartViewControllerMaxBarHeight))]];
//        }
//        else {
//            [mutableChartData addObject:[NSNumber numberWithInt:value]];
//        }
//        
//    }
//    _stepChartData = [NSArray arrayWithArray:mutableChartData];
//    _distanceChartData = [NSArray arrayWithArray:mutableChartData];
//}

- (void)viewDidLoad {
//    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel = [UILabel new];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldAvenirFontOfSize:17];
    [self.view addSubview:_titleLabel];
    [_titleLabel autoSetDimensionsToSize:CGSizeMake(180, 30)];
    [_titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:40];
    
    switch (_type) {
        case ChartTypeMonth:
        {
            lineValue = CHART_VIEW_LINE_VALUE;
//            [self initFakeData:30 value:0];
            self.stepsChartView = [self createBarChartView];
            self.stepChartColor = RGBA(58, 188, 164, 1.0f);
//            self.view.backgroundColor = RGBA(173, 240, 181, 1.0f);
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-activity-2"]];
            self.titleLabel.text = LOC_STR(@"This Month");
        }
            break;
        case ChartTypeYear:
        {
//            [self initFakeData:12 value:0];
            self.stepsChartView = [self createBarChartView];
            self.stepChartColor = RGBA(240, 91, 36, 1.0f);
//            self.view.backgroundColor = RGBA(254, 245, 171, 1.0f);
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-activity-3"]];
            self.titleLabel.text = LOC_STR(@"This Year");
        }
            break;
//        case ChartTypeWeek:
            default:
        {
            lineValue = CHART_VIEW_LINE_VALUE;
//            [self initFakeData:7 value:0];
            self.stepsChartView = [self createBarChartView];
            self.stepChartColor = RGBA(98, 91, 180, 1.0f);
//            self.view.backgroundColor = RGBA(222, 205, 255, 1.0f);
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-activity-1"]];
            self.titleLabel.text = LOC_STR(@"This Week");
        }
            break;
    }
    
    long steps = [GlobalCache shareInstance].local.indoorSteps + [GlobalCache shareInstance].local.outdoorSteps;
    if (steps < STEPS_LEVEL_LOW) {
        self.stepChartColor = RGBA(99, 92, 170, 1.0f);;
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-monster-1"]];
    }
    else if(steps > STEPS_LEVEL_GOOD) {
        self.stepChartColor = RGBA(56, 181, 155, 1.0f);
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-monster-2"]];
    }
    else {
        self.stepChartColor = RGBA(226, 103, 46, 1.0f);
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-monster-3"]];
    }
    
    _titleLabel.textColor = _stepChartColor;
    
    LMArrowView *leftView = [LMArrowView new];
    LMArrowView *rightView = [LMArrowView new];
    rightView.arrow = LMArrowRight;
    
    leftView.color = _titleLabel.textColor;
    rightView.color = _titleLabel.textColor;
    
    [self.view addSubview:leftView];
    [self.view addSubview:rightView];
    [leftView autoSetDimensionsToSize:CGSizeMake(10, 10)];
    [leftView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_titleLabel];
    [leftView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:_titleLabel];
    [rightView autoSetDimensionsToSize:CGSizeMake(10, 10)];
    [rightView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_titleLabel];
    [rightView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_titleLabel];
    
    UIView *backView = [UIView new];
    backView.layer.cornerRadius = 10.0f;
    backView.layer.masksToBounds = YES;
    backView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    [self.view addSubview:backView];
    [self.view addSubview:self.stepsChartView];
    
    UILabel *label = [UILabel new];
    [backView addSubview:label];
    [label autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 0, 0, 0) excludingEdge:ALEdgeBottom];
    [label autoSetDimension:ALDimensionHeight toSize:20];
    label.textColor = _stepChartColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldAvenirFontOfSize:17];
    label.text = LOC_STR(@"Steps");
    
    [backView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20];
    [backView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:20];
    [backView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleLabel withOffset:30];
    
    [self.stepsChartView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:backView withOffset:15];
    [self.stepsChartView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:backView withOffset:-15];
    [self.stepsChartView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:backView withOffset:-10];
    [self.stepsChartView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:backView withOffset:30];
    
    [self createBtn:backView offset:30];
    
    if (lineValue > 0) {
        LFLineView *line = [[LFLineView alloc] initWithLineLength:6 withLineSpacing:3 withLineColor:_stepChartColor];
        line.horizontalLine = YES;
        [self.view addSubview:line];
        
        [line autoSetDimension:ALDimensionHeight toSize:2];
        standardLC = [line autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.stepsChartView withOffset:-20];
        [line autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:backView withOffset:10];
        [line autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:backView withOffset:-10];
        
        LMArrowLabel *label = [LMArrowLabel new];
        label.font = [UIFont avenirFontOfSize:13];
        label.adjustsFontSizeToFitWidth = YES;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [Fun countNumAndChangeformat:lineValue];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = _stepChartColor;
        [self.view addSubview:label];
        [label autoSetDimensionsToSize:CGSizeMake(30, 16)];
        [label autoAlignAxis:ALAxisHorizontal toSameAxisOfView:line];
        [label autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:line];
        
    }
    

    self.isLoadData = NO;
    task = nil;
//    [self performSelector:@selector(reloadChartView) withObject:nil afterDelay:1];
}

- (void)createBtn:(UIView*)layoutView offset:(CGFloat)offset {
//    UIImage *image = [ControlFactory imageFromColor:RGBA(0x67, 0x5c, 0xa7, 1.0f) size:CGSizeMake(100, 30)];
    UIImage *image = [ControlFactory imageFromColor:self.stepChartColor size:CGSizeMake(100, 30)];
    
    //    UIImage *image = [ControlFactory imageFromColor:[UIColor redColor] size:CGSizeMake(100, 30)];
    
    indoorBtn = [RoundButton new];
    outdoorBtn = [RoundButton new];
    UIView *middleView = [UIView new];
    [self.view addSubview:indoorBtn];
    [self.view addSubview:outdoorBtn];
    [self.view addSubview:middleView];
    
    [middleView autoSetDimensionsToSize:CGSizeMake(20, 30)];
    [middleView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
    [middleView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    
    [indoorBtn autoSetDimension:ALDimensionWidth toSize:100];
    [indoorBtn autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:middleView];
    [indoorBtn autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:middleView];
    [indoorBtn autoAlignAxis:ALAxisHorizontal toSameAxisOfView:middleView];
    
    [outdoorBtn autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:indoorBtn];
    [outdoorBtn autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:middleView];
    [outdoorBtn autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:middleView];
    [outdoorBtn autoAlignAxis:ALAxisHorizontal toSameAxisOfView:middleView];
    
    [indoorBtn setTitle:LOC_STR(@"Indoor") forState:UIControlStateNormal];
    indoorBtn.titleLabel.font = [UIFont avenirFontOfSize:17];
    indoorBtn.backgroundColor = [UIColor whiteColor];
    indoorBtn.layer.borderWidth = 2;
    indoorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    indoorBtn.layer.masksToBounds = YES;
    indoorBtn.adjustsImageWhenHighlighted = NO;
    indoorBtn.showsTouchWhenHighlighted = NO;
    [indoorBtn setTitleColor:self.stepChartColor forState:UIControlStateNormal];
    [indoorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [indoorBtn setBackgroundImage:image forState:UIControlStateSelected];
    [indoorBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    indoorBtn.selected = YES;
    
    [outdoorBtn setTitle:LOC_STR(@"Outdoor") forState:UIControlStateNormal];
    outdoorBtn.titleLabel.font = [UIFont avenirFontOfSize:17];
    outdoorBtn.backgroundColor = [UIColor whiteColor];
    outdoorBtn.layer.borderWidth = 2;
    outdoorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    outdoorBtn.layer.masksToBounds = YES;
    outdoorBtn.adjustsImageWhenHighlighted = NO;
    outdoorBtn.showsTouchWhenHighlighted = NO;
    [outdoorBtn setTitleColor:self.stepChartColor forState:UIControlStateNormal];
    [outdoorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [outdoorBtn setBackgroundImage:image forState:UIControlStateSelected];
    [outdoorBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [middleView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:layoutView withOffset:offset];
}

- (void)btnAction:(id)sender {
    if (indoorBtn == sender) {
        indoorBtn.selected = YES;
        outdoorBtn.selected = NO;
        [self reloadData];
    }
    else {
        indoorBtn.selected = NO;
        outdoorBtn.selected = YES;
        [self reloadData];
    }
//    if ([_delegate respondsToSelector:@selector(showChanged:)]) {
//        [_delegate showChanged:self.outdoorBtn.selected];
//    }
}

- (void)requestByTimestamp:(int64_t)kidId {
    
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSDate *todayDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
    
    NSDate *startDate = nil;
    if (_type == GetActivityTypeWeekly) {
        startDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-6 toDate:todayDate options:0];
    }
    else {
        startDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:todayDate options:0];
    }
    
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:todayDate options:0];
    
    [[SwingClient sharedClient] deviceGetActivityByTime:kidId beginTimestamp:startDate endTimestamp:endDate completion:^(id dailyActs, NSError *error) {
        task = nil;
        if (!error) {
            LOG_D(@"dailyActs:%@", dailyActs);
            NSMutableDictionary *indoors = [NSMutableDictionary dictionary];
            NSMutableDictionary *outdoors = [NSMutableDictionary dictionary];
            for (ActivityResultModel *m in dailyActs) {
                NSString *key = [GlobalCache dateToDayString:m.receivedDate];

                if ([m.type isEqualToString:@"INDOOR"]) {
                    if (indoors[key]) {
                        ActivityResultModel *model = indoors[key];
                        model.steps += m.steps;
                    }
                    else {
                        indoors[key] = m;
                    }
                }
                else if([m.type isEqualToString:@"OUTDOOR"]) {
                    if (outdoors[key]) {
                        ActivityResultModel *model = outdoors[key];
                        model.steps += m.steps;
                    }
                    else {
                        outdoors[key] = m;
                    }
                }
            }
            self.indoorData = indoors;
            self.outdoorData = outdoors;
            [self reloadData];
        }
        else {
            LOG_D(@"deviceGetActivity fail: %@", error);
        }
    }];
}

- (void)requestData {
    if (task) {
        return;
    }
    int64_t kidId = [GlobalCache shareInstance].currentKid.objId;
    if (kidId == 0) {
        return;
    }
    
    if (_type == GetActivityTypeWeekly || _type == GetActivityTypeMonth) {
        [self requestByTimestamp:kidId];
        return;
    }
    
    task = [[SwingClient sharedClient] deviceGetActivity:kidId type:(GetActivityType)_type completion:^(id dailyActs, NSError *error) {
        task = nil;
        if (!error) {
            LOG_D(@"dailyActs:%@", dailyActs);
            NSMutableDictionary *indoors = [NSMutableDictionary dictionary];
            NSMutableDictionary *outdoors = [NSMutableDictionary dictionary];
            for (ActivityResultModel *m in dailyActs) {
                NSString *key = nil;
                if (_type == GetActivityTypeYear) {
                    key = [GlobalCache dateToMonthString:m.receivedDate];
                }
                else {
                    key = [GlobalCache dateToDayString:m.receivedDate];
                }
                if ([m.type isEqualToString:@"INDOOR"]) {
                    if (indoors[key]) {
                        ActivityResultModel *model = indoors[key];
                        model.steps += m.steps;
                    }
                    else {
                        indoors[key] = m;
                    }
                }
                else if([m.type isEqualToString:@"OUTDOOR"]) {
                    if (outdoors[key]) {
                        ActivityResultModel *model = outdoors[key];
                        model.steps += m.steps;
                    }
                    else {
                        outdoors[key] = m;
                    }
                }
            }
            self.indoorData = indoors;
            self.outdoorData = outdoors;
            [self reloadData];
        }
        else {
            LOG_D(@"deviceGetActivity fail: %@", error);
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.isLoadData) {
        [self reloadChartView];
        [self requestData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    if (self.indoorData == nil) {
        [self requestData];
//    }
}

//- (void)setIsOutdoor:(BOOL)isOutdoor {
//    _isOutdoor = isOutdoor;
//    [self reloadData];
//}

- (int)dataCount {
    switch (_type) {
        case ChartTypeMonth:
            return 30;
        case ChartTypeYear:
            return 12;
        default:
            return 7;
    }
}

- (CGFloat)dataDate:(NSDictionary*)dict index:(NSUInteger)index {
    int maxCount = [self dataCount];
    NSDate *date = [NSDate date];
//    if (maxCount > 0) {
//        return 12000 / maxCount * (index + 1) + 3000;
//    }
    switch (_type) {
        case ChartTypeYear:
        {
            /*
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDateComponents *comp = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
            NSInteger month = comp.month - 11 + (int)index;
            NSInteger year = comp.year;
            if (month < 0) {
                month += 12;
                year--;
            }
            NSString *key = [NSString stringWithFormat:@"%ld-%02ld", (long)year, (long)month];
             */
            //从前12个月开始计算
            NSDate *targetDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMonth value:index-maxCount+1 toDate:date options:0];
            NSString *key = [GlobalCache dateToMonthString:targetDate];
//            LOG_D(@"month:%@", key);
            ActivityResultModel *model = dict[key];
            if (model) {
                return model.steps;
            }
        }
            break;
        default:
        {
//            int pos = (int)index;
//            NSDate *targetDate = [date dateByAddingTimeInterval: (pos - maxCount + 1) * 24 * 60 * 60];
            NSDate *targetDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:index-maxCount+1 toDate:date options:0];
            NSString *key = [GlobalCache dateToDayString:targetDate];
            
            ActivityResultModel *model = dict[key];
            if (model) {
                return model.steps;
            }
        }
            break;
    }
    return 0.0f;
}

- (void)reloadData {
    NSDictionary *dailyActs = outdoorBtn.selected ? self.outdoorData : self.indoorData;

    _stepChartData = dailyActs;
    
    LOG_D(@"stepChartData:%@", _stepChartData);
    [self.stepsChartView reloadData];
    if (lineValue > 0) {
        CGFloat maxHeight = _stepsChartView.maximumValue;
        CGFloat boundHeight = [_stepsChartView availableHeight];
        CGFloat realHeight = lineValue / maxHeight * boundHeight;
        standardLC.constant = - 20.0f - realHeight;
    }
//    [self.stepFooter reload];
}

- (void)reloadChartView {
//    NSLog(@"1 %@", NSStringFromCGRect(_stepsChartView.frame));
//    NSLog(@"2 %@", NSStringFromCGRect(_distanceChartView.frame));
    
    self.isLoadData = YES;
    
    ChartFooterView *stepFooter = [[ChartFooterView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
//    stepFooter.titleLabel.text = LOC_STR(@"Steps");

    stepFooter.lineColor = self.stepChartColor;
    
    self.stepsChartView.footerView = stepFooter;
    
    if (_type != ChartTypeMonth) {

    }
    else {
        static NSDateFormatter *df = nil;
        if (df == nil) {
            df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM/dd"];
        }
        
        NSDate *date = [NSDate date];
        NSDate *preMonthDate = [date dateByAddingTimeInterval:- 30 * 24 * 60 * 60];
        
        stepFooter.leftLabel.text = [df stringFromDate:preMonthDate];
        stepFooter.rightLabel.text = [df stringFromDate:date];
    }
    
    [_stepsChartView reloadData];
    if (lineValue > 0) {
        CGFloat maxHeight = _stepsChartView.maximumValue;
        CGFloat boundHeight = [_stepsChartView availableHeight];
        CGFloat realHeight = lineValue / maxHeight * boundHeight;
        standardLC.constant = - 20.0f - realHeight;
    }
//    [stepFooter reload];
    
    self.stepFooter = stepFooter;
}

- (JBBarChartView*)createBarChartView {
    JBBarChartView* barChartView = [[JBBarChartView alloc] init];
    barChartView.delegate = self;
    barChartView.dataSource = self;
    barChartView.headerPadding = 10.f;
    barChartView.minimumValue = 0.0f;
    barChartView.inverted = NO;
    barChartView.maximumValue = lineValue;
    barChartView.clipsToBounds = NO;
    
    [ControlFactory setClickAction:barChartView target:self action:@selector(detailAction)];
    
    return barChartView;
}

- (void)detailAction
{
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Dashboard" bundle:nil];
    StepsTableViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"StepsTableCtl"];
    ctl.title = self.titleLabel.text;
    ctl.todaySteps = NO;
    ctl.outdoorFirstShow = outdoorBtn.selected;
    ctl.indoorData = self.indoorData.allValues;
    ctl.outdoorData = self.outdoorData.allValues;
    [self.navigationController pushViewController:ctl animated:YES];
    /*
    switch (_type) {
        case ChartTypeMonth:
        {
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Dashboard" bundle:nil];
            StepsTableViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"StepsTableCtl"];
            ctl.title = self.titleLabel.text;
            ctl.todaySteps = NO;
            [self.navigationController pushViewController:ctl animated:YES];
        }
            break;
        case ChartTypeYear:
        {
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Dashboard" bundle:nil];
            StepsTableViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"StepsTableCtl"];
            ctl.title = self.titleLabel.text;
            ctl.todaySteps = NO;
            [self.navigationController pushViewController:ctl animated:YES];
        }
            break;
        default:
        {
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Dashboard" bundle:nil];
            StepsTableViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"StepsTableCtl"];
            ctl.title = self.titleLabel.text;
            ctl.todaySteps = NO;
            [self.navigationController pushViewController:ctl animated:YES];
        }
            break;
    }
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)numberOfBarsInChartFooterView:(ChartFooterView *)footerView {
    return [self dataCount];
}

- (NSString*)chartFooterView:(ChartFooterView *)footerView textAtIndex:(NSUInteger)index {
    if (_type == ChartTypeWeek) {
        static NSDateFormatter *df = nil;
        if (df == nil) {
            df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM/dd"];
        }
        int pos = (int)index;
        NSDate *preDate = [[NSDate date] dateByAddingTimeInterval: (pos - 6) * 24 * 60 * 60];
        return [df stringFromDate:preDate];
    }
    else {
        if (localeDateFormatter == nil) {
            localeDateFormatter = [NSDateFormatter new];
//            localeDateFormatter = [NSLocale localeWithLocaleIdentifier:@"en_US"];
            localeDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:[GlobalCache shareInstance].curLanguage];
        }
        NSArray *array = [localeDateFormatter shortStandaloneMonthSymbols];
        return [array objectAtIndex:index % 12];
    }
}

#pragma mark - JBChartViewDataSource

- (BOOL)shouldExtendSelectionViewIntoHeaderPaddingForChartView:(JBChartView *)chartView
{
    return YES;
}

- (BOOL)shouldExtendSelectionViewIntoFooterPaddingForChartView:(JBChartView *)chartView
{
    return NO;
}

#pragma mark - JBBarChartViewDataSource

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return [self dataCount];
}
/*
- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
//    NSNumber *valueNumber = [self.chartData objectAtIndex:index];
//    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint atChartView:barChartView];
//    [self.tooltipView setText:[valueNumber stringValue]];
}

- (void)didDeselectBarChartView:(JBBarChartView *)barChartView
{
//    [self setTooltipVisible:NO animated:YES atChartView:barChartView];
}
*/

#pragma mark - JBBarChartViewDelegate

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index
{
    return [self dataDate:_stepChartData index:index];
}

- (UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    return _stepChartColor;
}

- (UIView *)barChartView:(JBBarChartView *)barChartView barViewAtIndex:(NSUInteger)index {
    UIView *view = nil;
    
    if (_type == ChartTypeWeek) {
        static NSDateFormatter *df = nil;
        if (df == nil) {
            df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM/dd"];
        }
        int pos = (int)index;
        NSDate *preDate = [[NSDate date] dateByAddingTimeInterval: (pos - 6) * 24 * 60 * 60];
        
        LMBarView *v = [LMBarView new];
        v.label.text = [Fun countNumAndChangeformat:[self barChartView:barChartView heightForBarViewAtIndex:index]];
//        v.label.text = [NSString stringWithFormat:@"%d", (int)[self barChartView:barChartView heightForBarViewAtIndex:index]];
//        v.label.textColor = _stepChartColor;
        v.dateLabel.textColor = _stepChartColor;
        v.dateLabel.text = [df stringFromDate:preDate];
        view = v;
    }
    else if (_type == ChartTypeYear) {
        if (localeDateFormatter == nil) {
            localeDateFormatter = [NSDateFormatter new];
//            localeDateFormatter = [NSLocale localeWithLocaleIdentifier:@"en_US"];
            localeDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:[GlobalCache shareInstance].curLanguage];
        }
        NSArray *array = [localeDateFormatter shortStandaloneMonthSymbols];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *comp = [cal components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]];
        
        LMBarView *v = [LMBarView new];
//        v.label.textColor = _stepChartColor;
        v.dateLabel.textColor = _stepChartColor;
        v.dateLabel.text = [array objectAtIndex:(index + comp.month) % 12];
        view = v;
    }
    else {
        view = [UIView new];
    }
    view.backgroundColor = [self barChartView:barChartView colorForBarViewAtIndex:index];
    return view;
}

- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
{
    return [UIColor clearColor];
}

- (CGFloat)barPaddingForBarChartView:(JBBarChartView *)barChartView
{
    NSUInteger count = [self dataCount];
    CGFloat padWidth = barChartView.frame.size.width / (count * 2 - 1);
    if (padWidth < kJBBarChartViewControllerBarPadding) {
        return padWidth;
    }
    return kJBBarChartViewControllerBarPadding;
//    return padWidth;
}

@end
