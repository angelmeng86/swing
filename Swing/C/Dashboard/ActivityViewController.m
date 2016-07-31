//
//  ActivityViewController.m
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ActivityViewController.h"
#import "ChartViewController.h"
#import "CommonDef.h"

@interface ActivityViewController ()<UIPageViewControllerDataSource>

@property (nonatomic, strong) NSArray* ctlArray;

@end

@implementation ActivityViewController

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    
    ChartViewController *weekCtl = [ChartViewController new];
    weekCtl.pageIndex = 0;
    
    ChartViewController *monthCtl = [ChartViewController new];
    monthCtl.type = ChartTypeMonth;
    monthCtl.pageIndex = 1;
    
    ChartViewController *yearCtl = [ChartViewController new];
    yearCtl.type = ChartTypeYear;
    yearCtl.pageIndex = 2;
    
    self.ctlArray = @[weekCtl, monthCtl, yearCtl];
    
    NSArray *viewControllers = @[weekCtl];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
//    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController.view autoPinEdgesToSuperviewEdges];
    [self.pageViewController didMoveToParentViewController:self];
    
    
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

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ChartViewController*) viewController).pageIndex;
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    return [self.ctlArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ChartViewController*) viewController).pageIndex;
    
    index++;
    if (index == self.ctlArray.count) {
        return nil;
    }
    return [self.ctlArray objectAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.ctlArray.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
