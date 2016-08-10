//
//  LMTabBarController2.m
//  Swing
//
//  Created by Mapple on 16/8/10.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMTabBarController2.h"
#import "CommonDef.h"

@interface LMTabBarController2 ()

@end

@implementation LMTabBarController2

- (void)awakeFromNib {
    [super awakeFromNib];
    
    for (UITabBarItem *item in self.tabBar.items) {
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    int i = 0;
    for (UINavigationController *navCtl in self.viewControllers) {
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
        UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"SwingTab%d", i]];
        [navCtl setViewControllers:@[ctl] animated:NO];
        i++;
    }
    
    [[GlobalCache shareInstance] queryKids];
    [[GlobalCache shareInstance] queryWeather];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[GlobalCache shareInstance] queryKids];
    [[GlobalCache shareInstance] queryWeather];
    
    self.selectedIndex = 2;
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
