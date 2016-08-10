//
//  LoginViewController.m
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "CommonDef.h"
#import "RegisterViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.emailTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];

    self.emailTextField.delegate = self;
    self.pwdTextField.delegate = self;
    
//    self.emailTextField.text = @"123@qq.com";
//    self.pwdTextField.text = @"111111";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)validateTextField {
    if (self.emailTextField.text.length == 0 || self.pwdTextField.text.length == 0) {
        [Fun showMessageBoxWithTitle:@"Error" andMessage:@"Please input info."];
        return NO;
    }
    if (![Fun isValidateEmail:self.emailTextField.text]) {
        [Fun showMessageBoxWithTitle:@"Error" andMessage:@"Email is invalid."];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.pwdTextField becomeFirstResponder];
    }
    else if (textField == self.pwdTextField) {
        [textField resignFirstResponder];
        
        if ([self validateTextField]) {
            [SVProgressHUD showWithStatus:@"Please wait..."];
            [[SwingClient sharedClient] userIsEmailRegistered:self.emailTextField.text completion:^(NSNumber *result, NSError *error) {
                if (!error) {
                    LOG_D(@"isEmailRegistered success: %@", result);
                    if (![result boolValue]) {
                        [SVProgressHUD showSuccessWithStatus:@"The email is not registered"];
                        [SVProgressHUD dismissWithDelay:1.0];
                        //Go to register
                        UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
                        RegisterViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"Register"];
                        ctl.email = self.emailTextField.text;
                        ctl.pwd = self.pwdTextField.text;
                        [self.navigationController pushViewController:ctl animated:YES];
                    }
                    else {
                        [SVProgressHUD showWithStatus:@"Login, please wait..."];
                        [[SwingClient sharedClient] userLogin:self.emailTextField.text password:self.pwdTextField.text completion:^(NSError *error) {
                            if (!error) {
                                //Login success
                                [SVProgressHUD dismiss];
                                UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab2" bundle:nil];
                                UIViewController *ctl = [stroyBoard instantiateInitialViewController];
                                AppDelegate *ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                ad.window.rootViewController = ctl;
                            }
                            else {
                                LOG_D(@"login fail: %@", error);
                                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                            }
                        }];
                    }
                }
                else {
                    LOG_D(@"isEmailRegistered fail: %@", error);
                    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                }
            }];
        }
    }
    return YES;
}

- (void)doneAction {
    
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
