//
//  SyncNavViewController.m
//  Swing
//
//  Created by Mapple on 2017/7/14.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "SyncNavViewController.h"
#import "CommonDef.h"

@interface SyncNavViewController ()

@end

@implementation SyncNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoteInfo:) name:REMOTE_NOTIFICATION object:nil];
}

- (void)handleRemoteInfo:(NSNotification*)noti {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
