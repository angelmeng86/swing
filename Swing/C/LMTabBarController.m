//
//  LMTabBarController.m
//  Swing
//
//  Created by 刘武忠 on 16/7/15.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMTabBarController.h"

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
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    self.navigationItem.title = viewController.title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
