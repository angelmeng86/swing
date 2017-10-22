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
#import "ChoicesViewController.h"
#import "OptionViewController.h"

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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"navi_option") style:UIBarButtonItemStylePlain target:self action:@selector(optionAction)];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LOC_STR(@"Language") style: UIBarButtonItemStylePlain target:self action:@selector(languageAction)];
    
    self.navigationItem.title = LOC_STR(@"Profile");
    [self.logoutBtn setTitle:LOC_STR(@"Logout") forState:UIControlStateNormal];
    if ([GlobalCache shareInstance].kidsList == nil && [GlobalCache shareInstance].kid) {
        [GlobalCache shareInstance].kidsList = @[[GlobalCache shareInstance].kid];
    }
}

- (void)optionAction {
    OptionViewController *ctl = [[OptionViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)languageAction {
    ChoicesViewController *ctl = [[ChoicesViewController alloc] initWithStyle:UITableViewStylePlain];
    ctl.delegate = self;
    ctl.navigationItem.title = LOC_STR(@"Language");
    ctl.textArray = @[LOC_STR(@"English"), LOC_STR(@"Spanish"), LOC_STR(@"Russian")];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)choicesViewControllerDidSelectedIndex:(int)index {
    NSString *lang = @"en";
    switch (index) {
        case 1:
            lang = @"es";
            break;
        case 2:
            lang = @"ru";
            break;
        default:
            break;
    }
    [GlobalCache shareInstance].local.language = lang;
    [[GlobalCache shareInstance] saveInfo];
    [self performSelector:@selector(goToMain) withObject:nil afterDelay:0.5];
}

- (void)goToMain {
    [GlobalCache shareInstance].cacheLang = nil;
    AppDelegate *ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [ad goToMain];
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
        self.emailLabel.text = [GlobalCache shareInstance].user.email;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editProfileAction:)];
    
    
    if ([GlobalCache shareInstance].user.profile) {
        [self.headerBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:[GlobalCache shareInstance].user.profile]] forState:UIControlStateNormal];
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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (collectionView == self.deviceConllectionView) {
        return 1;
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.deviceConllectionView) {
        return [GlobalCache shareInstance].kidsList.count;
    }
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (collectionView == self.deviceConllectionView) {
        CGFloat left = (collectionView.frame.size.width - (55 * [GlobalCache shareInstance].kidsList.count - 5)) / 2;
        return UIEdgeInsetsMake(10, left > 10 ? left : 10, 0, 10);
    }
    return UIEdgeInsetsZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath

{
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        if (collectionView == self.deviceConllectionView) {
            reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
            UILabel *label = (UILabel*)[reusableview viewWithTag:2016];
            label.text = LOC_STR(@"My hosting device");
        }
    }
    
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (collectionView == self.deviceConllectionView) {
        ProfileDeviceCell *deviceCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DeviceCell" forIndexPath:indexPath];
        KidModel *model = [[GlobalCache shareInstance].kidsList objectAtIndex:indexPath.row];
        if (model.profile) {
            [deviceCell.imageBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:model.profile]] forState:UIControlStateNormal];
        }
        else {
            [deviceCell.imageBtn setBackgroundImage:nil forState:UIControlStateNormal];
        }
        [deviceCell.imageBtn setTitle:nil forState:UIControlStateNormal];
        cell = deviceCell;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.deviceConllectionView) {
        
    }
}

- (IBAction)logoutAction:(id)sender {
    [[GlobalCache shareInstance] logout];
}

@end
