//
//  KidBindViewController.m
//  Swing
//
//  Created by Mapple on 16/7/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "KidBindViewController.h"
#import "VPImageCropperViewController.h"
#import "CommonDef.h"
#import "BindReadyViewController.h"
#import "EditProfileViewController.h"
#import "SyncDeviceViewController.h"
#import "ProfileViewController.h"

@interface KidBindViewController ()<UITextFieldDelegate, CameraUtilityDelegate>
{
    UIImage *image;
    CameraUtility2 *cameraUtility;
}

@end

@implementation KidBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.title;
    cameraUtility = [[CameraUtility2 alloc] init];
    cameraUtility.originMaxWidth = ORIGINAL_MAX_WIDTH;
    cameraUtility.targetMaxWidth = TAGET_MAX_WIDTH;
    
//    [self.firstNameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
//    [self.lastNameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
//    [self.birthdayTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.firstNameTF.placeholder=LOC_STR(@"Kid's name");
//    self.lastNameTF.placeholder=LOC_STR(@"Kid's name");
//    self.birthdayTF.placeholder=LOC_STR(@"Kid's birthday");
    
    [self.doneBtn setTitle:LOC_STR(@"Done") forState:UIControlStateNormal];
    
    self.firstNameTF.delegate = self;
//    self.lastNameTF.delegate = self;
//    self.birthdayTF.delegate = self;
    
    self.imageBtn.layer.cornerRadius = 60.f;
    self.imageBtn.layer.borderColor = [self.imageBtn titleColorForState:UIControlStateNormal].CGColor;
    self.imageBtn.layer.borderWidth = 4.f;
    self.imageBtn.layer.masksToBounds = YES;
    image = nil;
    
    [self setCustomBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)validateTextField {
    if (self.firstNameTF.text.length == 0) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"Please input info.")];
        return NO;
    }
    
    return YES;
}

- (void)goNext {
    for (UIViewController *ctl in self.navigationController.viewControllers) {
        if ([ctl isKindOfClass:[EditProfileViewController class]]) {
            //EditProfile add device flow
            [self.navigationController popToViewController:ctl animated:YES];
            return;
        }
        if ([ctl isKindOfClass:[ProfileViewController class]]) {
            //Profile add device flow
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        }
        if ([ctl isKindOfClass:[SyncDeviceViewController class]]) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            return;
        }
    }
    
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    BindReadyViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"BindReady"];
    ctl.image = image;
    ctl.name = self.firstNameTF.text;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstNameTF) {
//        [self.lastNameTF becomeFirstResponder];
//    }
//    else if (textField == self.lastNameTF) {
        
        if ([self validateTextField]) {
            //查询后台数据是否已存在绑定的Mac
            [SVProgressHUD show];
//            [SVProgressHUD showWithStatus:@"Check kid info, please wait..."];
            [[SwingClient sharedClient] userRetrieveProfileWithCompletion:^(id user, NSArray *kids, NSError *error) {
                if (!error) {
//                    if ([GlobalCache shareInstance].currentKid) {
//                        [SVProgressHUD showErrorWithStatus:@"You had been bind a watch!"];
//                        return;
//                    }
                    [SVProgressHUD show];
//                    [SVProgressHUD showWithStatus:@"Add kid info, please wait..."];
                    
                    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{@"name":self.firstNameTF.text}];
                    if (self.macAddress) {
                        //Mac 地址进行倒置转换
//                        NSData *realMac = [Fun dataReversal:self.macAddress];
                        //这里的MAC已经倒置过了
                        NSString *mac = [Fun dataToHex:self.macAddress];
                        [data setObject:mac forKey:@"macId"];//new api
                    }
                    
                    [[SwingClient sharedClient] kidsAdd:data completion:^(id kid, NSError *error) {
                        if (error) {
                            LOG_D(@"kidsAdd fail: %@", error);
                            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                        }
                        else {
                            KidModel *model = kid;
                            //保存kid对应的固件版本至本地
                            
                            KidInfo *m = [DBHelper addKid:model save:NO];
                            m.currentVersion = self.version;
                            [DBHelper saveDatabase];
                            
                            if (image && model) {
                                [SVProgressHUD showWithStatus:@"UploadImage, please wait..."];
                                [[SwingClient sharedClient] kidsUploadKidsProfileImage:image kidId:model.objId completion:^(NSString *profileImage, NSError *error) {
                                    if (error) {
                                        LOG_D(@"uploadProfileImage fail: %@", error);
                                    }
                                    else {
                                        model.profile = profileImage;
                                        [DBHelper addKid:model];
                                        [[NSNotificationCenter defaultCenter] postNotificationName:KID_AVATAR_NOTIFICATION object:nil];
                                    }
                                    [SVProgressHUD dismiss];
                                    [self goNext];
                                }];
                            }
                            else {
                                [SVProgressHUD dismiss];
                                [self goNext];
                            }
                        }
                    }];
                }
                else {
                    LOG_D(@"retrieveProfile fail: %@", error);
                    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                }
            }];
            
        }
        
    }
    return YES;
}

- (IBAction)imageAction:(id)sender {
    [self.firstNameTF resignFirstResponder];
    
    [cameraUtility getPhoto:self];
}

- (IBAction)doneAction:(id)sender {
    [self textFieldShouldReturn:self.firstNameTF];
}

- (void)cameraUtilityFinished:(UIImage*)img
{
    image = img;
    [self setHeaderImage:image];
}

- (void)setHeaderImage:(UIImage*)headImage {
    [self.imageBtn setBackgroundImage:headImage forState:UIControlStateNormal];
    
    self.imageBtn.layer.borderColor = [self.imageBtn titleColorForState:UIControlStateNormal].CGColor;
    [self.imageBtn setTitle:nil forState:UIControlStateNormal];
}

@end
