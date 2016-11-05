//
//  SyncDeviceViewController.m
//  Swing
//
//  Created by Mapple on 16/7/27.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SyncDeviceViewController.h"
#import "CommonDef.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SyncDeviceViewController ()

@end

@implementation SyncDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.imageView.layer.cornerRadius = 60.f;
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = 3.f;
    self.imageView.layer.masksToBounds = YES;
    
    self.label1.adjustsFontSizeToFitWidth = YES;
    self.label2.adjustsFontSizeToFitWidth = YES;
    
    self.navigationItem.title = @"Sync";
    
    if ([GlobalCache shareInstance].info.profileImage) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[@"http://avatar.childrenlab.com/" stringByAppendingString:[GlobalCache shareInstance].info.profileImage]]];
    }
    if ([GlobalCache shareInstance].user) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [GlobalCache shareInstance].user.firstName, [GlobalCache shareInstance].user.lastName];
    }
    
    [self setCustomBackBarButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userProfileLoaded:) name:USER_PROFILE_LOAD_NOTI object:nil];
    
    if (![GlobalCache shareInstance].local.deviceMAC) {
        //当前用户没有绑定设备，执行查询
        [[GlobalCache shareInstance] queryProfile];
    }
}

- (void)userProfileLoaded:(NSNotification*)notification {
    if (![GlobalCache shareInstance].local.deviceMAC) {
        //确认当前用户没有绑定设备
        self.label1.text = @"You have not bind";
        self.label2.text = @"device yet.";
        [self.button1 setTitle:@"Search a watch" forState:UIControlStateNormal];
        [self.button2 setTitle:@"Go to dashboard" forState:UIControlStateNormal];
    }
}

- (void)backAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SYNC_DISMISS" object:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)syncAnotherAction:(id)sender {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"SearchWatch"];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (IBAction)goDashboardAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SYNC_DISMISS" object:nil];
    }];
}

- (IBAction)syncCurrentAction:(UIButton*)sender {
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:@"Search a watch"]) {
        [self syncAnotherAction:sender];
        return;
    }
    if ([GlobalCache shareInstance].local.deviceMAC) {
        UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"SyncDevice" bundle:nil];
        UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"Syncing"];
        [self.navigationController pushViewController:ctl animated:YES];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"you have not bind device yet, please sync a watch."];
    }
    
    
}

@end
