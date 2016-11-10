//
//  LMTabBarController2.m
//  Swing
//
//  Created by Mapple on 16/8/10.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMTabBarController2.h"
#import "CommonDef.h"

@interface LMTabBarController2 ()<UITabBarControllerDelegate>

@property (nonatomic, assign) UIViewController *syncDialog;

@end

@implementation LMTabBarController2

- (void)awakeFromNib {
    [super awakeFromNib];
    
    for (UITabBarItem *item in self.tabBar.items) {
        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    int i = 0;
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    for (UINavigationController *navCtl in self.viewControllers) {
        if(i == 3) {
            i++;
        }
        UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"SwingTab%d", i]];
        [navCtl setViewControllers:@[ctl] animated:NO];
        i++;
    }
    
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.viewControllers[2] == viewController) {
        [self showSyncDialog];
    }
}

- (void)showSyncDialog {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"SyncDevice" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateInitialViewController];
    [self presentViewController:ctl animated:YES completion:nil];
    self.syncDialog = ctl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[GlobalCache shareInstance] queryWeather];
    
    self.delegate = self;
    self.selectedIndex = 2;
    [self performSelector:@selector(showSyncDialog) withObject:nil afterDelay:0.3];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteInfo:) name:REMOTE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDismiss) name:@"SYNC_DISMISS" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)syncDismiss {
    self.syncDialog = nil;
}

- (void)handleRemoteInfo:(NSNotification*)noti {
    self.selectedIndex = 1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showSyncDialog) object:nil];
    if (self.syncDialog) {
        [self.syncDialog dismissViewControllerAnimated:YES completion:nil];
        self.syncDialog = nil;
    }
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
