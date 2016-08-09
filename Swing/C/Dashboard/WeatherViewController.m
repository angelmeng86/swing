//
//  WeatherViewController.m
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "WeatherViewController.h"
#import "WeatherContentViewController.h"
#import "CommonDef.h"

@interface WeatherViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIPageControl *pageControl;

@property (nonatomic, strong) NSArray* ctlArray;

@end

@implementation WeatherViewController

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    WeatherContentViewController *tempCtl = [stroyBoard instantiateViewControllerWithIdentifier:@"WeatherContent"];
    tempCtl.pageIndex = 0;
    
    WeatherContentViewController *humidityCtl = [stroyBoard instantiateViewControllerWithIdentifier:@"WeatherContent"];
    humidityCtl.pageIndex = 1;
    
    self.ctlArray = @[tempCtl, humidityCtl];
    
    NSArray *viewControllers = @[tempCtl];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    //    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController.view autoPinEdgesToSuperviewEdges];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.pageControl = [UIPageControl new];
    [self.view addSubview:self.pageControl];
    self.pageControl.numberOfPages = self.ctlArray.count;;
    self.pageControl.currentPageIndicatorTintColor = RGBA(0x89, 0x87, 0x8b, 1.0f);
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    
    [self.pageControl autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 20, 0, 20) excludingEdge:ALEdgeBottom];
    [self.pageControl autoSetDimension:ALDimensionHeight toSize:20];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    self.pageControl.currentPage = ((WeatherContentViewController*) [pendingViewControllers firstObject]).pageIndex;
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
    NSUInteger index = ((WeatherContentViewController*) viewController).pageIndex;
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    return [self.ctlArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WeatherContentViewController*) viewController).pageIndex;
    
    index++;
    if (index == self.ctlArray.count) {
        return nil;
    }
    return [self.ctlArray objectAtIndex:index];
}

@end
