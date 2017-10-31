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

@interface EditKidViewController ()<UITextFieldDelegate, CameraUtilityDelegate>
{
    UIImage *image;
    CameraUtility2 *cameraUtility;
}

@end

@implementation EditKidViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = LOC_STR(@"Edit");
    cameraUtility = [[CameraUtility2 alloc] init];
    cameraUtility.originMaxWidth = ORIGINAL_MAX_WIDTH;
    cameraUtility.targetMaxWidth = TAGET_MAX_WIDTH;
    
    [self.firstNameTF setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.firstNameTF.placeholder=LOC_STR(@"Kid's name");
    
    self.firstNameTF.delegate = self;
    
    self.imageBtn.layer.cornerRadius = 60.f;
//    self.imageBtn.layer.borderColor = [self.imageBtn titleColorForState:UIControlStateNormal].CGColor;
//    self.imageBtn.layer.borderWidth = 3.f;
    self.imageBtn.layer.masksToBounds = YES;
    image = nil;
    
    if ([GlobalCache shareInstance].currentKid) {
        self.firstNameTF.text = [GlobalCache shareInstance].currentKid.name;
        if ([GlobalCache shareInstance].currentKid.profile) {
            [self.imageBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:[GlobalCache shareInstance].currentKid.profile]] forState:UIControlStateNormal];
//            self.imageBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//            [self.imageBtn setTitle:nil forState:UIControlStateNormal];
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
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"Please input info.")];
        return NO;
    }
    
    return YES;
}

- (void)doneAction {
        if ([self validateTextField]) {
            [SVProgressHUD show];
//            [SVProgressHUD showWithStatus:@"Edit kid info, please wait..."];
            
            NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{@"name":self.firstNameTF.text, @"kidId":@([GlobalCache shareInstance].currentKid.objId)}];
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
                    [DBHelper addKid:model];
                    if (image && model) {
                        [SVProgressHUD show];
//                        [SVProgressHUD showWithStatus:@"UploadImage, please wait..."];
                        [[SwingClient sharedClient] kidsUploadKidsProfileImage:image kidId:model.objId completion:^(NSString *profileImage, NSError *error) {
                            if (error) {
                                LOG_D(@"kidsUploadKidsProfileImage fail: %@", error);
                            }
                            else {
                                model.profile = profileImage;
                                [DBHelper addKid:model];
                                [[NSNotificationCenter defaultCenter] postNotificationName:KID_AVATAR_NOTIFICATION object:nil];
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
    
    [cameraUtility getPhoto:self];
}

- (void)cameraUtilityFinished:(UIImage*)img
{
    image = img;
    [self setHeaderImage:image];
}

- (void)setHeaderImage:(UIImage*)headImage {
    [self.imageBtn setBackgroundImage:headImage forState:UIControlStateNormal];
    
//    self.imageBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    [self.imageBtn setTitle:nil forState:UIControlStateNormal];
}

@end
