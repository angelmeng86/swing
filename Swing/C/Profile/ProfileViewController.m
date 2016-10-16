//
//  ProfileViewController.m
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ProfileViewController.h"
#import "CommonDef.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "ProfileDeviceCell.h"
#import "AppDelegate.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.headerBtn.layer.cornerRadius = 60.f;
    self.headerBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headerBtn.layer.borderWidth = 3.f;
    self.headerBtn.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userProfileLoaded:) name:USER_PROFILE_LOAD_NOTI object:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"navi_edit") style:UIBarButtonItemStylePlain target:self action:@selector(editProfileAction:)];
}

- (void)userProfileLoaded:(NSNotification*)notification {
    [self loadProfile];
    [self.deviceConllectionView reloadData];
}

- (void)loadProfile {
    if ([GlobalCache shareInstance].user) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [GlobalCache shareInstance].user.firstName, [GlobalCache shareInstance].user.lastName];
        self.phoneLabel.text = [GlobalCache shareInstance].user.phoneNumber;
        self.addressLabel.text = [GlobalCache shareInstance].user.address;
        self.addressLabel2.text = [[GlobalCache shareInstance].user address2];
    }
    self.emailLabel.text = [GlobalCache shareInstance].info.email;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editProfileAction:)];
    
    
    if ([GlobalCache shareInstance].info.profileImage) {
        [self.headerBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[@"http://avatar.childrenlab.com/" stringByAppendingString:[GlobalCache shareInstance].info.profileImage]] forState:UIControlStateNormal];
    }
    [self loadProfile];
    [[GlobalCache shareInstance] queryProfile];
}

- (void)editProfileAction:(id)sender {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"EditProfile2"];
//    [self presentViewController:ctl animated:YES completion:nil];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [GlobalCache shareInstance].kidsList.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath

{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    }
    
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ProfileDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DeviceCell" forIndexPath:indexPath];
    KidModel *model = [[GlobalCache shareInstance].kidsList objectAtIndex:indexPath.row];
    if (model.profile) {
        [cell.imageBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[@"http://avatar.childrenlab.com/" stringByAppendingString:model.profile]] forState:UIControlStateNormal];
    }
    else {
        [cell.imageBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
    [cell.imageBtn setTitle:nil forState:UIControlStateNormal];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)logoutAction:(id)sender {
    [[GlobalCache shareInstance] logout];
}

@end
