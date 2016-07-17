//
//  LoginViewController.m
//  Swing
//
//  Created by 刘武忠 on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LoginViewController.h"
#import "CommonDef.h"

@interface LoginViewController ()
{
    NSURLSessionDataTask *task;
    BOOL isLogin;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.emailTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwd2TextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    task = nil;
    isLogin = YES;
    self.tipLabel.text = nil;
    self.emailTextField.delegate = self;
    self.pwdTextField.delegate = self;
    self.pwd2TextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.emailTextField) {
        if (textField.text.length > 0) {
            if (task) {
                [task cancel];
            }
            
            NSDictionary *parameters = @{@"email":textField.text};
            task = [[SwingClient sharedClient] isEmailRegistered:parameters completion:^(NSNumber *result, NSError *error) {
                task = nil;
                if (!error) {
                    NSLog(@"isEmailRegistered success: %@", result);
                    isLogin = [result boolValue];
                    if (!isLogin) {
                        self.tipLabel.text = @"The email is not registered";
                        self.pwd2TextField.hidden = NO;
                    }
                    else {
                        self.pwd2TextField.hidden = YES;
                    }
                }
                else {
                    NSLog(@"isEmailRegistered fail: %@", error);
                }
            }];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.pwdTextField becomeFirstResponder];
    }
    else if (textField == self.pwdTextField) {
        [self performSegueWithIdentifier:<#(nonnull NSString *)#> sender:<#(nullable id)#>]
    }
    else if (textField == self.pwd2TextField) {
        
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
