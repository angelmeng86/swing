//
//  ProfileViewController.m
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ProfileViewController.h"
#import "CommonDef.h"
#import "UIButton+AFNetworking.h"
#import "ProfileDeviceCell.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.headerBtn.layer.cornerRadius = 60.f;
    self.headerBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headerBtn.layer.borderWidth = 2.f;
    self.headerBtn.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kidsListLoaded:) name:KIDS_LIST_LOAD_NOTI object:nil];
}

- (void)kidsListLoaded:(NSNotification*)notification {
    [self.deviceConllectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editProfileAction:)];
    if ([GlobalCache shareInstance].info.profileImage) {
        [self.headerBtn setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:[@"http://avatar.childrenlab.com/" stringByAppendingString:[GlobalCache shareInstance].info.profileImage]]];
    }
//    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [GlobalCache shareInstance].info., self.lastNameTF.text];
    self.emailLabel.text = [GlobalCache shareInstance].info.email;
}

- (void)editProfileAction:(id)sender {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"EditProfile"];
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
    
}

@end
