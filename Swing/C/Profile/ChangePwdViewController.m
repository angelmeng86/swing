//
//  ChangePwdViewController.m
//  Swing
//
//  Created by Mapple on 2017/10/29.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "ChangePwdViewController.h"
#import "CommonDef.h"

@interface ChangePwdViewController ()

@end

@implementation ChangePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LOC_STR(@"Reset Password");
    // Do any additional setup after loading the view.
    self.pwdTF.placeholder = LOC_STR(@"New password");
    self.pwdTF2.placeholder = LOC_STR(@"Enter new password again");
    [self.saveBtn setTitle:LOC_STR(@"Save") forState:UIControlStateNormal];
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

- (IBAction)saveAction:(id)sender {
    
}

@end
