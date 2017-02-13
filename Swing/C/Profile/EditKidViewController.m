//
//  KidBindViewController.m
//  Swing
//
//  Created by Mapple on 16/7/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "EditKidViewController.h"
#import "VPImageCropperViewController.h"
#import "CommonDef.h"
#import "BindReadyViewController.h"
#import "EditProfileViewController.h"
#import "SyncDeviceViewController.h"
#import <SDWebImage/UIButton+WebCache.h>

@interface EditKidViewController ()<UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate>
{
    UIImage *image;
}

@end

@implementation EditKidViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = LOC_STR(@"Edit");;
    
    [self.firstNameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.firstNameTF.placeholder=LOC_STR(@"Kid's name");
    
    self.firstNameTF.delegate = self;
    
    self.imageBtn.layer.cornerRadius = 60.f;
    self.imageBtn.layer.borderColor = [self.imageBtn titleColorForState:UIControlStateNormal].CGColor;
    self.imageBtn.layer.borderWidth = 3.f;
    self.imageBtn.layer.masksToBounds = YES;
    image = nil;
    
    if ([GlobalCache shareInstance].kid) {
        self.firstNameTF.text = [GlobalCache shareInstance].kid.name;
        if ([GlobalCache shareInstance].kid.profile) {
            [self.imageBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:[GlobalCache shareInstance].kid.profile]] forState:UIControlStateNormal];
            self.imageBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            [self.imageBtn setTitle:nil forState:UIControlStateNormal];
        }
        
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"navi_save") style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)validateTextField {
    if (self.firstNameTF.text.length == 0) {
        [Fun showMessageBoxWithTitle:@"Error" andMessage:@"Please input info."];
        return NO;
    }
    
    return YES;
}

- (void)doneAction {
        if ([self validateTextField]) {
            [SVProgressHUD showWithStatus:@"Edit kid info, please wait..."];
            
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{@"name":self.firstNameTF.text, @"kidId":@([GlobalCache shareInstance].kid.objId)}];
//            NSString *mac = [GlobalCache shareInstance].kid.macId;
//            if (mac) {
//                [data setObject:mac forKey:@"macId"];
//            }
            
            [[SwingClient sharedClient] kidsUpdate:data completion:^(id kid, NSError *error) {
                if (error) {
                    LOG_D(@"kidsUpdate fail: %@", error);
                    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                }
                else {
                    KidModel *model = kid;
                    BOOL finded = NO;
                    [GlobalCache shareInstance].kid = model;
                    
                    for (KidModel *m in [GlobalCache shareInstance].kidsList) {
                        if (m.objId == model.objId) {
                            m.name = model.name;
                            m.profile = model.profile;
                            model = m;
                            finded = YES;
                            break;
                        }
                    }
                    if (!finded) {
                        if ([GlobalCache shareInstance].kidsList) {
                            [GlobalCache shareInstance].kidsList = [[GlobalCache shareInstance].kidsList arrayByAddingObject:model];
                        }
                        else {
                            [GlobalCache shareInstance].kidsList = @[model];
                        }
                    }
                    if (image && model) {
                        [SVProgressHUD showWithStatus:@"UploadImage, please wait..."];
                        [[SwingClient sharedClient] kidsUploadKidsProfileImage:image kidId:model.objId completion:^(NSString *profileImage, NSError *error) {
                            if (error) {
                                LOG_D(@"uploadProfileImage fail: %@", error);
                            }
                            else {
                                model.profile = profileImage;
                                [GlobalCache shareInstance].kid = model;
                            }
                            [SVProgressHUD dismiss];
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    }
                    else {
                        [SVProgressHUD dismiss];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }];
        }
}

- (IBAction)imageAction:(id)sender {
    [self.firstNameTF resignFirstResponder];
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Take a picture", nil), NSLocalizedString(@"Choose from library", nil), nil];
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
        [Fun showMessageBoxWithTitle:NSLocalizedString(@"Prompt", nil) andMessage:@"Simulator does not support camera."];
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
