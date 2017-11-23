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
//    [self.emailTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
//    [self.pwdTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.emailTextField.placeholder=LOC_STR(@"Email");
    self.pwdTextField.placeholder=LOC_STR(@"Password");
    [self.loginBtn setTitle:LOC_STR(@"Login") forState:UIControlStateNormal];
    [self.resetBtn setTitle:LOC_STR(@"Reset Password") forState:UIControlStateNormal];

    self.emailTextField.delegate = self;
    self.pwdTextField.delegate = self;
    self.tipLabel.text = nil;
    
//#ifdef MAPPLE_DEBUG
//    self.emailTextField.text = @"lwz1@swing.com";
//    self.emailTextField.text = @"test11@swing.com";
//    self.pwdTextField.text = @"1";
//#endif
    [self setCustomBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)validateTextField {
    if (self.emailTextField.text.length == 0 || self.pwdTextField.text.length == 0) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"Please input info.")];
        return NO;
    }
    if (![Fun isValidateEmail:self.emailTextField.text]) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"Please input info.")];
        return NO;
    }
    return YES;
}

- (void)cacheEventsV1 {
    [[SwingClient sharedClient] calendarGetAllEventsWithCompletion:^(NSArray *eventArray, NSError *error) {
        if (![self isError:error tag:@"calendarGetAllEvents"]) {
            [SVProgressHUD dismiss];
            [self goToMain];
        }
    }];
}

- (void)querySharedDevice {
    [[SwingClient sharedClient] subHostList:@"ACCEPTED" completion:^(NSArray *requestFrom, NSArray *requestTo, NSError *error) {
        if (error) {
            LOG_D(@"subHostList ACCEPTED fail: %@", error);
        }
    }];
}

- (void)cacheTodayActivity {
    int64_t kidId = [GlobalCache shareInstance].currentKid.objId;
    if (kidId == 0) {
        return;
    }
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    [[SwingClient sharedClient] deviceGetActivityByTime:kidId beginTimestamp:startDate endTimestamp:endDate completion:^(id dailyActs, NSError *error) {
        if (!error) {
            LOG_D(@"today dailyActs:%@", dailyActs);
            ActivityResultModel *indoorModel = nil;
            ActivityResultModel *outdoorModel = nil;
            for (ActivityResultModel *m in dailyActs) {
                if ([m.type isEqualToString:@"INDOOR"]) {
                    if (indoorModel) {
                        indoorModel.steps += m.steps;
                    }
                    else {
                        indoorModel = m;
                    }
                    
                }
                else if([m.type isEqualToString:@"OUTDOOR"]) {
                    if (outdoorModel) {
                        outdoorModel.steps += m.steps;
                    }
                    else {
                        outdoorModel = m;
                    }
                }
            }
            if (indoorModel) {
                [GlobalCache shareInstance].local.indoorSteps = indoorModel.steps;
            }
            if (outdoorModel) {
                [GlobalCache shareInstance].local.outdoorSteps = outdoorModel.steps;
            }
            [[GlobalCache shareInstance] saveInfo];
        }
        else {
            LOG_D(@"deviceGetActivity fail: %@", error);
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.pwdTextField becomeFirstResponder];
    }
    else if (textField == self.pwdTextField) {
        [textField resignFirstResponder];
        [self login];
    }
    return YES;
}

- (void)login {
    self.tipLabel.text = nil;
        if ([self validateTextField]) {
            [SVProgressHUD show];
//            [SVProgressHUD showWithStatus:@"Please wait..."];
            [[SwingClient sharedClient] userIsEmailRegistered:self.emailTextField.text completion:^(NSNumber *result, NSError *error) {
                if (![self isError:error tag:@"isEmailRegistered"]) {
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
//                        [SVProgressHUD showWithStatus:@"Login, please wait..."];
                        [[SwingClient sharedClient] userLogin:self.emailTextField.text password:self.pwdTextField.text completion:^(NSError *error) {
                            if (![self isError:error tag:@"Login"]) {
                                //Login success
                                [[SwingClient sharedClient] userRetrieveProfileWithCompletion:^(id user, NSArray *kids, NSError *error) {
                                    if (![self isError:error tag:@"retrieveProfile"]) {
//                                        [SVProgressHUD showWithStatus:@"Loading data, please wait..."];
                                        //继续获取所有Event进行本地缓存
                                        [self cacheEventsV1];
                                        //继续获取当天步数进行本地缓存
                                        [self cacheTodayActivity];
                                        //获取subHost分享的设备
                                        [[GlobalCache shareInstance] querySharedDevice];
                                    }
                                }];
                            }
                        }];
                    }
                }
            }];
        }
}

- (BOOL)isError:(NSError*)error tag:(NSString*)tag {
    if (error) {
        if (error.code == 400 && [tag isEqualToString:@"Login"]) {
            [SVProgressHUD dismiss];
            self.tipLabel.text = [error localizedDescription];
            self.resetBtn.hidden = NO;
            
            [self.loginBtn setTitle:LOC_STR(@"Login again") forState:UIControlStateNormal];
        }
        else {
            //清空登录信息
            [[GlobalCache shareInstance] logout:NO];
            LOG_D(@"%@ fail: %@", tag, error);
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
        return YES;
    }
    return NO;
}

- (void)goToMain {
//    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
//    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"AskStep"];
//    [self.navigationController pushViewController:ctl animated:YES];
    
    AppDelegate *ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [ad goToMain];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginAction:(id)sender {
    [self login];
}

- (IBAction)resetAction:(id)sender {
    if (self.emailTextField.text.length == 0 || ![Fun isValidateEmail:self.emailTextField.text]) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"Please input info.")];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOC_STR(@"Reset Password") message:LOC_STR(@"Are you sure you want to reset your password?") preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:LOC_STR(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:LOC_STR(@"Ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD show];
        [[SwingClient sharedClient] sendResetPasswordEmail:self.emailTextField.text completion:^(NSError *error) {
            if(!error) {
                [SVProgressHUD dismiss];
                [Fun showMessageBox:LOC_STR(@"") andFormat:LOC_STR(@"Please check your email at '%@' for the link to reset your password.This link will expire in 24 hours"), self.emailTextField.text];
            }
            else {
                LOG_D(@"sendResetPasswordEmailWithCompletion fail: %@", error);
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }
        }];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
