//
//  BaseViewController.m
//  
//
//  Created by Mapple on 15-4-24.
//  Copyright (c) 2015年 TriggerOnce. All rights reserved.
//

#import "LMBaseViewController.h"
#import "CommonDef.h"
#import "LMArrowView.h"

@interface LMBaseViewController ()

@end

@implementation LMBaseViewController

- (void)setCustomBackButton {
    if (!self.navigationController.navigationBarHidden) {
        return;
    }
//    LMArrowView *arrow = [[LMArrowView alloc] initWithFrame:CGRectMake(0, 0, 10, 18)];
//    arrow.backgroundColor = [UIColor clearColor];
//    arrow.color = COMMON_NAV_TINT_COLOR;
//    arrow.isNotFill = YES;
//    UIButton *btn = [UIButton new];
//    [btn addSubview:arrow];
//    [arrow autoCenterInSuperviewMargins];
//    [arrow autoSetDimensionsToSize:CGSizeMake(10, 18)];
    
    UIButton *btn = [UIButton new];
    [btn setImage:LOAD_IMAGE(@"navi_back") forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    [btn autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [btn autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
    [btn autoSetDimensionsToSize:CGSizeMake(44, 44)];
}

- (void)setCustomBackBarButtonItem {
//    LMArrowView *arrow = [[LMArrowView alloc] initWithFrame:CGRectMake(0, 0, 10, 18)];
//    arrow.backgroundColor = [UIColor clearColor];
//    arrow.color = COMMON_NAV_TINT_COLOR;
//    arrow.isNotFill = YES;
//    [arrow addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:arrow];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"navi_back") style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    if (self.navigationController.viewControllers.count > 1) {
        [self setCustomBackBarButtonItem];
    }
    
    if (self.tabBarController.navigationController) {
        self.tabBarController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    if (!self.notLoadBackgroudImage) {
        UIImage *image = LOAD_IMAGE(self.backgroudImageName == nil ? @"california_bg" : self.backgroudImageName);
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = 2017;
        [self.view addSubview:imageView];
        
        [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [imageView autoSetDimension:ALDimensionHeight toSize:kDeviceWidth * image.size.height / image.size.width];
        
        
        [self.view sendSubviewToBack:imageView];
    }
    
    self.view.backgroundColor = COMMON_BACKGROUND_COLOR;
}

- (UINavigationItem*)navigationItem {
    if (self.tabBarController.navigationController && self.tabBarController.navigationController == self.navigationController) {
        return self.tabBarController.navigationItem;
    }
    return [super navigationItem];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
