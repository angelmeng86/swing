//
//  EditProfileViewController.m
//  Swing
//
//  Created by Mapple on 16/7/30.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "EditProfileViewController.h"
#import "CommonDef.h"
#import "VPImageCropperViewController.h"
#import "UIButton+AFNetworking.h"
#import "ProfileDeviceCell.h"

@interface EditProfileViewController ()<UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, VPImageCropperDelegate>
{
    UIImage *image;
}

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    self.imageBtn.layer.cornerRadius = 60.f;
    self.imageBtn.layer.masksToBounds = YES;
    image = nil;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doneAction:)];
    
    if ([GlobalCache shareInstance].info.profileImage) {
        [self.imageBtn setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:[@"http://avatar.childrenlab.com/" stringByAppendingString:[GlobalCache shareInstance].info.profileImage]]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kidsListLoaded:) name:KIDS_LIST_LOAD_NOTI object:nil];
}

- (void)kidsListLoaded:(NSNotification*)notification {
    [self.deviceConllectionView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneAction:(id)sender {
    if ([self validateTextField]) {
        [SVProgressHUD showWithStatus:@"Saving, please wait..."];
        [[SwingClient sharedClient] userUpdateProfile:@{@"email":self.emailTF.text, @"phoneNumber":self.phoneTF.text, @"firstName":self.firstNameTF.text, @"lastName":self.lastNameTF.text} completion:^(NSError *error) {
            if (error) {
                LOG_D(@"userUpdateProfile fail: %@", error);
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }
            else {
                if (image) {
                    [SVProgressHUD showWithStatus:@"UploadImage, please wait..."];
                    [[SwingClient sharedClient] userUploadProfileImage:image completion:^(NSString *profileImage, NSError *error) {
                        if (error) {
                            LOG_D(@"uploadProfileImage fail: %@", error);
                            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                        }
                        else {
                            [SVProgressHUD dismiss];
                            [self.navigationController popViewControllerAnimated:YES];
                        }
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

- (BOOL)validateTextField {
    if (self.firstNameTF.text.length == 0 || self.lastNameTF.text.length == 0 || self.phoneTF.text.length == 0 || self.emailTF.text.length == 0) {
        [Fun showMessageBoxWithTitle:@"Error" andMessage:@"Please input info."];
        return NO;
    }
    
    return YES;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [GlobalCache shareInstance].kidsList.count + 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath

{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView2" forIndexPath:indexPath];
    }
    
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DeviceCell2" forIndexPath:indexPath];
    if (indexPath.row == [GlobalCache shareInstance].kidsList.count) {
        [cell.imageBtn setTitle:@"+" forState:UIControlStateNormal];
        [cell.imageBtn setBackgroundImage:nil forState:UIControlStateNormal];
        return cell;
    }
    
    KidModel *model = [[GlobalCache shareInstance].kidsList objectAtIndex:indexPath.row];
    if (model.profile) {
        [cell.imageBtn setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:[@"http://avatar.childrenlab.com/" stringByAppendingString:model.profile]]];
    }
    else {
        [cell.imageBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
    [cell.imageBtn setTitle:nil forState:UIControlStateNormal];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [GlobalCache shareInstance].kidsList.count) {
        UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
        UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"SearchWatch"];
        [self.navigationController pushViewController:ctl animated:YES];
    }
}

- (void)setHeaderImage:(UIImage*)headImage {
    [self.imageBtn setBackgroundImage:headImage forState:UIControlStateNormal];
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
            if ([CameraUtility isFrontCameraAvailable]) {
                controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
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

- (IBAction)imageBtnAction:(id)sender {
    [self.firstNameTF resignFirstResponder];
    [self.lastNameTF resignFirstResponder];
    [self.phoneTF resignFirstResponder];
    [self.emailTF resignFirstResponder];
    [self.streetTF resignFirstResponder];
    [self.cityTF resignFirstResponder];
    [self.stateTF resignFirstResponder];
    [self.zipCodeTF resignFirstResponder];
    
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Camera", nil), NSLocalizedString(@"Album", nil), nil];
    [choiceSheet showInView:self.view];
}
@end
