//
//  RegisterViewController.m
//  Swing
//
//  Created by Mapple on 16/7/19.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()<UITextFieldDelegate>

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.title;
    
    [self.firstNameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.lastNameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.phoneTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.zipCodeTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.firstNameTF.delegate = self;
    self.lastNameTF.delegate = self;
    self.phoneTF.delegate = self;
    self.zipCodeTF.delegate = self;
    
    self.imageBtn.layer.cornerRadius = 60.f;
    self.imageBtn.layer.borderColor = [self.imageBtn titleColorForState:UIControlStateNormal].CGColor;
    self.imageBtn.layer.borderWidth = 2.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstNameTF) {
        [self.lastNameTF becomeFirstResponder];
    }
    else if (textField == self.lastNameTF) {
        [self.phoneTF resignFirstResponder];
    }
    else if (textField == self.phoneTF) {
        [self.zipCodeTF resignFirstResponder];
    }
    else if (textField == self.zipCodeTF) {
        //Go
        UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
        UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"AskStep"];
        [self.navigationController pushViewController:ctl animated:YES];
    }
    return YES;
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
