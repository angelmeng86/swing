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

@property (nonatomic, strong) NSArray* kids;

@end

@implementation ProfileViewController

- (NSArray*)kids
{
    if (_kids == nil) {
        _kids = [DBHelper queryKids];
    }
    return _kids;
}

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
    
    self.navigationItem.title = LOC_STR(@"Profile");
    
    [self.deviceConllectionView registerNib:[UINib nibWithNibName:@"ProfileReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileReusableView"];
    [self.deviceSharedCollectionView registerNib:[UINib nibWithNibName:@"ProfileReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileReusableView"];
    [self.pendingRequestCollectionView registerNib:[UINib nibWithNibName:@"ProfileReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileReusableView"];
    [self.requestCollectionView registerNib:[UINib nibWithNibName:@"ProfileReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileReusableView"];
    
    self.deviceConllectionView.backgroundColor = self.view.backgroundColor;
    self.deviceSharedCollectionView.backgroundColor = self.view.backgroundColor;
    self.pendingRequestCollectionView.backgroundColor = self.view.backgroundColor;
    self.requestCollectionView.backgroundColor = self.view.backgroundColor;
    
    self.deviceLabel.text = LOC_STR(@"My devices");
    self.deviceSharedLabel.text = LOC_STR(@"Devices shared with me");
    self.pendingLabel.text = LOC_STR(@"Your pending request to");
    self.requestLabel.text = LOC_STR(@"You have 2 requests from");
}

- (void)optionAction {
    OptionViewController *ctl = [[OptionViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)userProfileLoaded:(NSNotification*)notification {
    [self loadProfile];
    self.kids = nil;
    [self.deviceConllectionView reloadData];
}

- (void)loadProfile {
    if ([GlobalCache shareInstance].user) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", [GlobalCache shareInstance].user.firstName, [GlobalCache shareInstance].user.lastName];
        self.emailLabel.text = [GlobalCache shareInstance].user.email;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editProfileAction:)];
    
    
    if ([GlobalCache shareInstance].user.profile.length > 0) {
        [self.headerBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:[GlobalCache shareInstance].user.profile]] forState:UIControlStateNormal];
    }
    [self loadProfile];
    [[GlobalCache shareInstance] queryProfile];
}

- (void)editProfileAction:(id)sender {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"EditProfile2"];
//    [self presentViewController:ctl animated:YES completion:nil];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.deviceConllectionView) {
        return self.kids.count;
    }
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (collectionView == self.deviceConllectionView) {
        CGFloat left = (collectionView.frame.size.width - (55 * self.kids.count - 5)) / 2;
        return UIEdgeInsetsMake(5, left > 10 ? left : 10, 0, 10);
    }
    return UIEdgeInsetsZero;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if (collectionView == self.deviceConllectionView) {
        ProfileDeviceCell *deviceCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DeviceCell" forIndexPath:indexPath];

        Kid *model = [self.kids objectAtIndex:indexPath.row];
        if (model.profile.length > 0) {
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

@end
