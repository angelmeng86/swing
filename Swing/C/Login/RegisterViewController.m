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

@interface RegisterViewController ()<UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate>
{
    UIImage *image;
}

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
    self.imageBtn.layer.borderWidth = 3.f;
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
        [Fun showMessageBoxWithTitle:@"Error" andMessage:@"Please input info."];
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
                                [SVProgressHUD dismiss];
                                UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
                                UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"AskStep"];
                                [self.navigationController pushViewController:ctl animated:YES];
                            }];
                        }
                        else {
                            [SVProgressHUD dismiss];
                            UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
                            UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"AskStep"];
                            [self.navigationController pushViewController:ctl animated:YES];
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
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:LOC_STR(@"Cancel")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:LOC_STR(@"Take a picture"), LOC_STR(@"Choose from library"), nil];
    [choiceSheet showInView:self.view];
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
//                if ([CameraUtility isFrontCameraAvailable]) {
//                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
//                }
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
