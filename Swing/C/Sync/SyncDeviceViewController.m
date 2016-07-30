//
//  SyncDeviceViewController.m
//  Swing
//
//  Created by Mapple on 16/7/27.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SyncDeviceViewController.h"
#import "CommonDef.h"

@interface SyncDeviceViewController ()

@end

@implementation SyncDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置导航默认标题的颜色及字体大小
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: RGBA(240, 92, 37, 1.0f), NSFontAttributeName : [UIFont boldAvenirFontOfSize:18]};
    
    // Do any additional setup after loading the view.
    self.imageView.layer.cornerRadius = 60.f;
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = 2.f;
    self.imageView.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goDashboardAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
