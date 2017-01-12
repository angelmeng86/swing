//
//  LMTabBarController.m
//  Swing
//
//  Created by Mapple on 16/7/15.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMTabBarController.h"
#import "CommonDef.h"

@interface LMTabBarController ()

@end

@implementation LMTabBarController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.navigationItem.title = [self.viewControllers firstObject].title;
    self.delegate = self;
    
    for (UITabBarItem *item in self.tabBar.items) {
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
//    [[GlobalCache shareInstance] queryProfile];
//    [[GlobalCache shareInstance] queryWeather];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    self.navigationItem.title = viewController.title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedIndex = 2;
    // Do any additional setup after loading the view.
//    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
//    {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.extendedLayoutIncludesOpaqueBars = YES;
//    }
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
