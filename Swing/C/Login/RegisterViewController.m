//
//  RegisterViewController.m
//  Swing
//
//  Created by Mapple on 16/7/19.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "RegisterViewController.h"
#import "VPImageCropperViewController.h"
#import "CommonDef.h"
#import "AppDelegate.h"

@interface RegisterViewController ()<UITextFieldDelegate,CameraUtilityDelegate>
{
    UIImage *image;
    CameraUtility2 *cameraUtility;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.title;
    cameraUtility = [[CameraUtility2 alloc] init];
    cameraUtility.originMaxWidth = ORIGINAL_MAX_WIDTH;
    cameraUtility.targetMaxWidth = TAGET_MAX_WIDTH;
    
//    [self.firstNameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
//    [self.lastNameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
//    [self.phoneTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
//    [self.zipCodeTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.firstNameTF.placeholder=LOC_STR(@"First name");
    self.lastNameTF.placeholder=LOC_STR(@"Last name");
    self.phoneTF.placeholder=LOC_STR(@"Phone number");
    self.zipCodeTF.placeholder=LOC_STR(@"Zip code");
    [self.doneBtn setTitle:LOC_STR(@"Done") forState:UIControlStateNormal];
    
    self.firstNameTF.delegate = self;
    self.lastNameTF.delegate = self;
    self.phoneTF.delegate = self;
    self.zipCodeTF.delegate = self;
    
    self.imageBtn.layer.cornerRadius = 60.f;
    self.imageBtn.layer.borderColor = [self.imageBtn titleColorForState:UIControlStateNormal].CGColor;
    self.imageBtn.layer.borderWidth = 4.f;
    self.imageBtn.layer.masksToBounds = YES;
    image = nil;
    
    
    [self setCustomBackButton];
    
    [self addRedTip:self.firstNameTF];
    [self addRedTip:self.lastNameTF];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)validateTextField {
    if (self.firstNameTF.text.length == 0 || self.lastNameTF.text.length == 0) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"Please input info.")];
        return NO;
    }

    return YES;
}

- (void)commit
{
    if ([self validateTextField]) {
        [self.firstNameTF resignFirstResponder];
        [self.lastNameTF resignFirstResponder];
        [self.phoneTF resignFirstResponder];
        [self.zipCodeTF resignFirstResponder];
        
        [SVProgressHUD show];
//        [SVProgressHUD showWithStatus:@"Register, please wait..."];
        [[SwingClient sharedClient] userRegister:@{@"email":self.email, @"password":self.pwd, @"phoneNumber":(self.phoneTF.text == nil ? @"" : self.phoneTF.text), @"firstName":self.firstNameTF.text, @"lastName":self.lastNameTF.text, @"language":[GlobalCache shareInstance].curLanguage} completion:^(id user, NSError *error) {
            if (error) {
                LOG_D(@"registerUser fail: %@", error);
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }
            else {
//                [SVProgressHUD showWithStatus:@"Login, please wait..."];
                [[SwingClient sharedClient] userLogin:self.email password:self.pwd completion:^(NSError *error) {
                    if (!error) {
                        //Login success
                        if (image) {
//                            [SVProgressHUD showWithStatus:@"UploadImage, please wait..."];
                            [[SwingClient sharedClient] userUploadProfileImage:image completion:^(NSString *profileImage, NSError *error) {
                                if (error) {
                                    LOG_D(@"uploadProfileImage fail: %@", error);
                                }
                                [self queryMyContry];
                            }];
                        }
                        else {
                            [self queryMyContry];
                        }
                    }
                    else {
                        LOG_D(@"login fail: %@", error);
                        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                    }
                }];
                
            }
        }];
    }
}

- (void)goToNext {
    [SVProgressHUD dismiss];
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"AskStep"];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)queryMyContry {
    [[SwingClient sharedClient] myCountryCodeWithCompletion:^(NSString *countryCode, NSError *error) {
        [GlobalCache shareInstance].local.showJPNoticTip = NO;
        if (!error) {
            if ([countryCode isEqualToString:@"JP"]) {
                [GlobalCache shareInstance].local.showJPNoticTip = YES;
            }
        }
        [[GlobalCache shareInstance] saveInfo];
        [self goToNext];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstNameTF) {
        [self.lastNameTF becomeFirstResponder];
    }
    else if (textField == self.lastNameTF) {
        [self.phoneTF becomeFirstResponder];
    }
    else if (textField == self.phoneTF) {
        [self commit];
//        [self.zipCodeTF becomeFirstResponder];
    }
    return YES;
}

- (IBAction)imageAction:(id)sender {
    [self.firstNameTF resignFirstResponder];
    [self.lastNameTF resignFirstResponder];
    [self.phoneTF resignFirstResponder];
    [self.zipCodeTF resignFirstResponder];
    
    [cameraUtility getPhoto:self];
}

- (void)cameraUtilityFinished:(UIImage*)img
{
    image = img;
    [self setHeaderImage:image];
}

- (void)addRedTip:(UIView*)view {
    UILabel *label = [UILabel new];
    label.text = @"*";
    label.textColor = [UIColor redColor];
    [self.view addSubview:label];
    [label autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:view withOffset:-2];
    [label autoAlignAxis:ALAxisHorizontal toSameAxisOfView:view];
}

- (IBAction)doneAction:(id)sender {
    [self commit];
}

- (void)setHeaderImage:(UIImage*)headImage {
    [self.imageBtn setBackgroundImage:headImage forState:UIControlStateNormal];
    
    self.imageBtn.layer.borderColor = [self.imageBtn titleColorForState:UIControlStateNormal].CGColor;
    [self.imageBtn setTitle:nil forState:UIControlStateNormal];
}

@end
