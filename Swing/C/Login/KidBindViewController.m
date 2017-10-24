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

@interface KidBindViewController ()<UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate>
{
    UIImage *image;
}

@end

@implementation KidBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.title;
    
    [self.firstNameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.lastNameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.birthdayTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.firstNameTF.placeholder=LOC_STR(@"Kid's name");
    self.lastNameTF.placeholder=LOC_STR(@"Kid's name");
    self.birthdayTF.placeholder=LOC_STR(@"Kid's birthday");
    
    self.firstNameTF.delegate = self;
    self.lastNameTF.delegate = self;
    self.birthdayTF.delegate = self;
    
    self.imageBtn.layer.cornerRadius = 60.f;
    self.imageBtn.layer.borderColor = [self.imageBtn titleColorForState:UIControlStateNormal].CGColor;
    self.imageBtn.layer.borderWidth = 3.f;
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
        if ([ctl isKindOfClass:[SyncDeviceViewController class]]) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            return;
        }
    }
    
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    BindReadyViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"BindReady"];
    ctl.image = image;
    ctl.name = [NSString stringWithFormat:@"%@ %@", self.firstNameTF.text, self.lastNameTF.text];
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
                    if ([GlobalCache shareInstance].kid) {
                        [SVProgressHUD showErrorWithStatus:@"You had been bind a watch!"];
                        return;
                    }
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
                            [GlobalCache shareInstance].local.firmwareVer = self.version;
                            [[GlobalCache shareInstance] saveInfo];
                            
                            if (self.macAddress && [GlobalCache shareInstance].kid == nil) {
                                [GlobalCache shareInstance].kid = model;
                            }
                            [DBHelper addKid:model];
                            if (image && model) {
                                [SVProgressHUD showWithStatus:@"UploadImage, please wait..."];
                                [[SwingClient sharedClient] kidsUploadKidsProfileImage:image kidId:model.objId completion:^(NSString *profileImage, NSError *error) {
                                    if (error) {
                                        LOG_D(@"uploadProfileImage fail: %@", error);
                                    }
                                    else {
                                        model.profile = profileImage;
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
    [self.lastNameTF resignFirstResponder];
    [self.birthdayTF resignFirstResponder];
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:LOC_STR(@"Cancel")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:LOC_STR(@"Take a picture"), LOC_STR(@"Choose from library"), nil];
    [choiceSheet showInView:self.view];
}

- (void)setHeaderImage:(UIImage*)headImage {
    [self.imageBtn setBackgroundImage:headImage forState:UIControlStateNormal];
    
    self.imageBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.imageBtn setTitle:nil forState:UIControlStateNormal];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
#if TARGET_IPHONE_SIMULATOR
        [Fun showMessageBoxWithTitle:LOC_STR(@"Prompt") andMessage:@"Simulator does not support camera."];
#else
        // 拍照
        if ([CameraUtility isCameraAvailable] && [CameraUtility doesCameraSupportTakingPhotos]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypeCamera;
//            if ([CameraUtility isFrontCameraAvailable]) {
//                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
//            }
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 LOG_D(@"Picker View Controller is presented");
                             }];
        }
#endif
    } else if (buttonIndex == 1) {
        // 从相册中选取
        if ([CameraUtility isPhotoLibraryAvailable]) {
            UIImagePickerController *controller = [[UIImagePickerController alloc] init];
            controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
            [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
            controller.mediaTypes = mediaTypes;
            controller.delegate = self;
            [self presentViewController:controller
                               animated:YES
                             completion:^(void){
                                 LOG_D(@"Picker View Controller is presented");
                             }];
        }
    }
}


#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
        image = [Fun imageByScalingToMaxSize:editedImage maxWidth:TAGET_MAX_WIDTH];
        [self setHeaderImage:image];
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [Fun imageByScalingToMaxSize:portraitImg maxWidth:ORIGINAL_MAX_WIDTH];
        // present the cropper view controller
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
