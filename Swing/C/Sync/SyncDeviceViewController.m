//
//  SyncDeviceViewController.m
//  Swing
//
//  Created by Mapple on 16/7/27.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SyncDeviceViewController.h"

@interface SyncDeviceViewController ()

@end

@implementation SyncDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
