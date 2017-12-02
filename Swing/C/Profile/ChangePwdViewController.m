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
    self.pwdTF2.placeholder = LOC_STR(@"New Password, Again!");
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
    if (![self.pwdTF.text isEqualToString:self.pwdTF2.text]) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"Your password does not match.")];
        return;
    }
    if (self.pwdTF.text.length < 6) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"The password length has to be longer than 6 characters")];
        return;
    }
    [SVProgressHUD show];
    [[SwingClient sharedClient] updatePassword:self.pwdTF.text completion:^(NSError *error) {
        if (error) {
            LOG_D(@"updatePassword fail: %@", error);
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
        else {
            [SVProgressHUD showSuccessWithStatus:nil];
            [self backAction];
        }
    }];
}

@end
