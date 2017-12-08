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
#import "ProfileDeviceCell.h"
#import "OptionViewController.h"
#import <SDWebImage/UIButton+WebCache.h>

@interface EditProfileViewController ()<UITextFieldDelegate, CameraUtilityDelegate>
{
    UIImage *image;
    CameraUtility2 *cameraUtility;
}

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    cameraUtility = [[CameraUtility2 alloc] init];
    cameraUtility.originMaxWidth = ORIGINAL_MAX_WIDTH;
    cameraUtility.targetMaxWidth = TAGET_MAX_WIDTH;
    
//    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self.saveBtn setTitle:LOC_STR(@"Save") forState:UIControlStateNormal];
    self.imageBtn.layer.cornerRadius = 60.f;
    self.imageBtn.layer.borderColor = [self.imageBtn titleColorForState:UIControlStateNormal].CGColor;
    self.imageBtn.layer.borderWidth = 4.f;
    self.imageBtn.layer.masksToBounds = YES;
    image = nil;
    
    UIView *panelView = [UIView new];
    [self.imageBtn addSubview:panelView];
    panelView.backgroundColor = [UIColor whiteColor];
    panelView.userInteractionEnabled = NO;
    panelView.alpha = 0.5f;
    [panelView autoPinEdgesToSuperviewEdges];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(doneAction:)];
    self.navigationItem.title = LOC_STR(@"Edit profile");
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"navi_save") style:UIBarButtonItemStylePlain target:self action:@selector(doneAction:)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"navi_option") style:UIBarButtonItemStylePlain target:self action:@selector(optionAction)];
    
    if ([GlobalCache shareInstance].user.profile) {
        [self.imageBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:[GlobalCache shareInstance].user.profile]] forState:UIControlStateNormal];
    }
    
    if ([GlobalCache shareInstance].user) {
        self.firstNameTF.text = [GlobalCache shareInstance].user.firstName;
        self.lastNameTF.text = [GlobalCache shareInstance].user.lastName;
        self.phoneTF.text = [GlobalCache shareInstance].user.phoneNumber;
        self.emailTF.text = [GlobalCache shareInstance].user.email;
        
        self.streetTF.text = [GlobalCache shareInstance].user.address;
        self.cityTF.text = [GlobalCache shareInstance].user.city;
        self.stateTF.text = [GlobalCache shareInstance].user.state;
        self.zipCodeTF.text = [GlobalCache shareInstance].user.zipCode;
    }
    self.emailTF.userInteractionEnabled = NO;
    
    self.firstNameTF.placeholder = LOC_STR(@"First name");
    self.lastNameTF.placeholder = LOC_STR(@"Last name");
    self.phoneTF.placeholder = LOC_STR(@"Phone number");
    self.zipCodeTF.placeholder = LOC_STR(@"Zip code");
    self.emailTF.placeholder = LOC_STR(@"Email");
//    self.streetTF.placeholder = LOC_STR(@"");
//    self.cityTF.placeholder = LOC_STR(@"City");
//    self.stateTF.placeholder = LOC_STR(@"State");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userProfileLoaded:) name:USER_PROFILE_LOAD_NOTI object:nil];
    
    self.firstNameTF.delegate = self;
    self.lastNameTF.delegate = self;
    self.phoneTF.delegate = self;
    self.emailTF.delegate = self;
    
    self.streetTF.delegate = self;
    self.cityTF.delegate = self;
    self.stateTF.delegate = self;
    self.zipCodeTF.delegate = self;
}

- (void)optionAction {
    OptionViewController *ctl = [[OptionViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)userProfileLoaded:(NSNotification*)notification {
    [self.deviceConllectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.deviceConllectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveAction:(id)sender {
    if ([self validateTextField]) {
        [SVProgressHUD show];
//        [SVProgressHUD showWithStatus:@"Saving, please wait..."];
        NSDictionary *data = @{ @"phoneNumber":self.phoneTF.text, @"firstName":self.firstNameTF.text, @"lastName":self.lastNameTF.text, @"zipCode":self.zipCodeTF.text};
        [[SwingClient sharedClient] userUpdateProfile:data completion:^(id user, NSError *error) {
            if (error) {
                LOG_D(@"userUpdateProfile fail: %@", error);
                [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
            }
            else {
                if (image) {
//                    [SVProgressHUD showWithStatus:@"UploadImage, please wait..."];
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
    if (self.firstNameTF.text.length == 0 || self.lastNameTF.text.length == 0 /*|| self.phoneTF.text.length == 0*/) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"Please input info.")];
        return NO;
    }
    
    return YES;
}
/*
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [GlobalCache shareInstance].kidsList.count;// + 1;
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
        [cell.imageBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:model.profile]] forState:UIControlStateNormal];
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
*/
- (void)setHeaderImage:(UIImage*)headImage {
    [self.imageBtn setBackgroundImage:headImage forState:UIControlStateNormal];
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
    
    [cameraUtility getPhoto:self];
}

- (void)cameraUtilityFinished:(UIImage*)img
{
    image = img;
    [self setHeaderImage:image];
}

@end
