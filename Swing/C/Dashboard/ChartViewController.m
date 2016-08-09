//
//  ChartViewController.m
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ChartViewController.h"
#import "CommonDef.h"
#import "JBBarChartView.h"
#import "JBLineChartView.h"
#import "ChartFooterView.h"

#import "JBChartTooltipView.h"
#import "JBChartTooltipTipView.h"

// Numerics
CGFloat const kJBBarChartViewControllerBarPadding = 20.0f;
NSInteger const kJBBarChartViewControllerMaxBarHeight = 10;
NSInteger const kJBBarChartViewControllerMinBarHeight = 5;

@interface ChartViewController ()<JBBarChartViewDelegate, JBBarChartViewDataSource, JBLineChartViewDataSource, JBLineChartViewDelegate>


@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) JBChartView *stepsChartView;
@property (nonatomic, strong) JBChartView *distanceChartView;

@property (nonatomic, strong) UIColor *stepChartColor;
@property (nonatomic, strong) UIColor *distanceChartColor;

@property (nonatomic, strong) NSArray *chartData;

@property (nonatomic) BOOL isLoadData;

@end

@implementation ChartViewController

- (void)initFakeData:(int)count
{
    NSMutableArray *mutableChartData = [NSMutableArray array];
    for (int i=0; i<count; i++)
    {
        NSInteger delta = (count - labs((count - i) - i)) + 2;
        [mutableChartData addObject:[NSNumber numberWithFloat:MAX((delta * kJBBarChartViewControllerMinBarHeight), arc4random() % (delta * kJBBarChartViewControllerMaxBarHeight))]];
        
    }
    _chartData = [NSArray arrayWithArray:mutableChartData];
}

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel = [UILabel new];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont avenirFontOfSize:17];
    [self.view addSubview:_titleLabel];
    [_titleLabel autoSetDimensionsToSize:CGSizeMake(100, 30)];
    [_titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:30];
    
    
    
    switch (_type) {
        case ChartTypeMonth:
        {
            [self initFakeData:30];
            self.stepsChartView = [self createLineChartView];
            self.distanceChartView = [self createLineChartView];
            self.stepChartColor = RGBA(58, 188, 164, 1.0f);
            self.distanceChartColor = RGBA(34, 110, 96, 1.0f);
            self.view.backgroundColor = RGBA(173, 240, 181, 1.0f);
            self.titleLabel.text = @"This Month";
        }
            break;
        case ChartTypeYear:
        {
            [self initFakeData:12];
            self.stepsChartView = [self createBarChartView];
            self.distanceChartView = [self createLineChartView];
            self.stepChartColor = RGBA(240, 91, 36, 1.0f);
            self.distanceChartColor = RGBA(208, 0, 23, 1.0f);
            self.view.backgroundColor = RGBA(254, 245, 171, 1.0f);
            self.titleLabel.text = @"This Year";
        }
            break;
        default:
            //ChartTypeWeek
        {
            [self initFakeData:7];
            self.stepsChartView = [self createBarChartView];
            self.distanceChartView = [self createBarChartView];
            self.stepChartColor = RGBA(98, 91, 180, 1.0f);
            self.distanceChartColor = RGBA(144, 146, 197, 1.0f);
            self.view.backgroundColor = RGBA(222, 205, 255, 1.0f);
            self.titleLabel.text = @"This Week";
        }
            break;
    }
    
    [self.view addSubview:self.stepsChartView];
    [self.view addSubview:self.distanceChartView];
    
    [_stepsChartView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_titleLabel withOffset:10];
    [_stepsChartView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:40];
    [_stepsChartView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:40];
    
    [_distanceChartView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_stepsChartView withOffset:20];
    [_distanceChartView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:40];
    [_distanceChartView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:40];
    [_distanceChartView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
    
    [_stepsChartView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:_distanceChartView];
    
    self.isLoadData = NO;
//    [self performSelector:@selector(reloadChartView) withObject:nil afterDelay:1];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.isLoadData) {
        [self reloadChartView];
    }
}

- (void)reloadChartView {
//    NSLog(@"1 %@", NSStringFromCGRect(_stepsChartView.frame));
//    NSLog(@"2 %@", NSStringFromCGRect(_distanceChartView.frame));
    
    self.isLoadData = YES;
    
    ChartFooterView *stepFooter = [[ChartFooterView alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
    stepFooter.titleLabel.text = @"Steps";
    stepFooter.leftLabel.text = @"07/25";
    stepFooter.rightLabel.text = @"08/12";
    
    ChartFooterView *distanceFooter = [[ChartFooterView alloc] initWithFrame:CGRectMake(0, 0, 0, 40)];
    distanceFooter.titleLabel.text = @"Distance";
    
    distanceFooter.leftLabel.text = @"07/25";
    distanceFooter.rightLabel.text = @"08/12";
    
    stepFooter.lineColor = self.stepChartColor;
    distanceFooter.lineColor = self.distanceChartColor;
    
    self.stepsChartView.footerView = stepFooter;
    self.distanceChartView.footerView = distanceFooter;
    
    [_stepsChartView reloadData];
    [_distanceChartView reloadData];
}

- (JBBarChartView*)createBarChartView {
    JBBarChartView* barChartView = [[JBBarChartView alloc] init];
    barChartView.delegate = self;
    barChartView.dataSource = self;
    barChartView.headerPadding = 10.f;
    barChartView.minimumValue = 0.0f;
    barChartView.inverted = NO;
    return barChartView;
}

- (JBLineChartView*)createLineChartView {
    JBLineChartView *lineChartView = [[JBLineChartView alloc] init];
    lineChartView.delegate = self;
    lineChartView.dataSource = self;
    lineChartView.headerPadding = 10.f;
    return lineChartView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.chartData count];
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    NSNumber *valueNumber = [self.chartData objectAtIndex:index];
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint atChartView:barChartView];
    [self.tooltipView setText:[valueNumber stringValue]];
}

- (void)didDeselectBarChartView:(JBBarChartView *)barChartView
{
    [self setTooltipVisible:NO animated:YES atChartView:barChartView];
}

#pragma mark - JBBarChartViewDelegate

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index
{
    return [[self.chartData objectAtIndex:index] floatValue];
}

- (UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index
{
    if (barChartView == _stepsChartView) {
        return _stepChartColor;
    }
    else {
        return _distanceChartColor;
    }
}

- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
{
    return [UIColor whiteColor];
}

- (CGFloat)barPaddingForBarChartView:(JBBarChartView *)barChartView
{
    CGFloat padWidth = barChartView.frame.size.width / (self.chartData.count * 2 - 1);
    if (padWidth < kJBBarChartViewControllerBarPadding) {
        return padWidth;
    }
    return kJBBarChartViewControllerBarPadding;
}

#pragma mark - JBLineChartViewDataSource

- (NSUInteger)numberOfLinesInLineChartView:(JBLineChartView *)lineChartView
{
    return 1;
}

- (NSUInteger)lineChartView:(JBLineChartView *)lineChartView numberOfVerticalValuesAtLineIndex:(NSUInteger)lineIndex
{
    return [self.chartData count];
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView showsDotsForLineAtLineIndex:(NSUInteger)lineIndex
{
    return YES;
}

- (BOOL)lineChartView:(JBLineChartView *)lineChartView smoothLineAtLineIndex:(NSUInteger)lineIndex
{
    return YES;
}

#pragma mark - JBLineChartViewDelegate

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView verticalValueForHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return [[self.chartData objectAtIndex:horizontalIndex] floatValue];
}

- (void)lineChartView:(JBLineChartView *)lineChartView didSelectLineAtIndex:(NSUInteger)lineIndex horizontalIndex:(NSUInteger)horizontalIndex touchPoint:(CGPoint)touchPoint
{
    
}

- (void)didDeselectLineInLineChartView:(JBLineChartView *)lineChartView
{
    
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView colorForLineAtLineIndex:(NSUInteger)lineIndex
{
    if (lineChartView == _stepsChartView) {
        return _stepChartColor;
    }
    else {
        return _distanceChartColor;
    }
}

- (CGFloat)lineChartView:(JBLineChartView *)lineChartView dotRadiusForDotAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex
{
    return 0.0;
}

- (UIView *)lineChartView:(JBLineChartView *)lineChartView dotViewAtHorizontalIndex:(NSUInteger)horizontalIndex atLineIndex:(NSUInteger)lineIndex {
    if (horizontalIndex == 0 || self.chartData.count == horizontalIndex + 1) {
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        dot.backgroundColor = [UIColor whiteColor];
        dot.layer.cornerRadius = 8.0f;
        dot.layer.borderWidth = 3.0f;
        if (lineChartView == _stepsChartView) {
            dot.layer.borderColor = _stepChartColor.CGColor;
        }
        else {
            dot.layer.borderColor = _distanceChartColor.CGColor;
        }
        dot.layer.masksToBounds = YES;
        return dot;
        
    }
    return nil;
}

- (UIColor *)lineChartView:(JBLineChartView *)lineChartView verticalSelectionColorForLineAtLineIndex:(NSUInteger)lineIndex
{
    return [UIColor whiteColor];
}

@end
