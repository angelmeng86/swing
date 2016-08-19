//
//  ActivityViewController.m
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ActivityViewController.h"
#import "ChartViewController.h"
#import "TodayChartViewController.h"
#import "CommonDef.h"

@interface ActivityViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    NSUInteger scrollIndex;
}

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (nonatomic, strong) NSArray* ctlArray;

@end

@implementation ActivityViewController

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    TodayChartViewController *todayCtl = [stroyBoard instantiateViewControllerWithIdentifier:@"TodayChart"];
    todayCtl.delegate = self;
    todayCtl.pageIndex = 0;
    
    ChartViewController *weekCtl = [ChartViewController new];
    weekCtl.type = ChartTypeWeek;
    weekCtl.pageIndex = 1;
    
    ChartViewController *monthCtl = [ChartViewController new];
    monthCtl.type = ChartTypeMonth;
    monthCtl.pageIndex = 2;
    
    ChartViewController *yearCtl = [ChartViewController new];
    yearCtl.type = ChartTypeYear;
    yearCtl.pageIndex = 3;
    
    self.ctlArray = @[todayCtl, weekCtl, monthCtl, yearCtl];
    
    NSArray *viewControllers = @[todayCtl];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
//    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController.view autoPinEdgesToSuperviewEdges];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.pageControl = [UIPageControl new];
    [self.view addSubview:self.pageControl];
    self.pageControl.numberOfPages = self.ctlArray.count;
    self.pageControl.currentPageIndicatorTintColor = RGBA(0x89, 0x87, 0x8b, 1.0f);
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    
    [self.pageControl autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 20, 0, 20) excludingEdge:ALEdgeBottom];
    [self.pageControl autoSetDimension:ALDimensionHeight toSize:20];
}

- (void)showChanged:(BOOL)isOutdoor {
    for (int i = 1; i < self.ctlArray.count; i++) {
        ChartViewController *ctl = self.ctlArray[i];
        ctl.isOutdoor = isOutdoor;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    scrollIndex = (int)[[pendingViewControllers firstObject] performSelector:@selector(pageIndex) withObject:nil];
//    self.pageControl.currentPage = ((ChartViewController*) [pendingViewControllers firstObject]).pageIndex;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        self.pageControl.currentPage = scrollIndex;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = (NSUInteger)[viewController performSelector:@selector(pageIndex) withObject:nil];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    return [self.ctlArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = (NSUInteger)[viewController performSelector:@selector(pageIndex) withObject:nil];
    
    index++;
    if (index == self.ctlArray.count) {
        return nil;
    }
    return [self.ctlArray objectAtIndex:index];
}

@end
