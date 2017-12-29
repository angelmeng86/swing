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
#import "OptionViewController.h"
#import "MutiRequestViewController.h"
#import "MutiListViewController.h"
#import "MutiConfirmViewController.h"
#import "LFDevicesActionSheet.h"

@interface ProfileViewController ()

@property (nonatomic, strong) NSArray* kids;
@property (nonatomic, strong) NSArray* sharedKids;
@property (nonatomic, strong) NSArray* pendingRequestToList;
@property (nonatomic, strong) NSArray* requestFromList;

@end

@implementation ProfileViewController

- (NSArray*)kids
{
    if (_kids == nil) {
        _kids = [DBHelper queryKids:NO];
    }
    return _kids;
}

- (NSArray*)sharedKids
{
    if (_sharedKids == nil) {
        _sharedKids = [DBHelper queryKids:YES];;
    }
    return _sharedKids;
}

- (NSArray*)pendingRequestToList
{
    if (_pendingRequestToList == nil) {
        _pendingRequestToList = [SubHostModel loadSubHost:[GlobalCache shareInstance].subHostRequestTo status:@"PENDING"];
    }
    return _pendingRequestToList;
}

- (NSArray*)requestFromList
{
    if (_requestFromList == nil) {
        _requestFromList = [SubHostModel loadSubHost:[GlobalCache shareInstance].subHostRequestFrom status:@"PENDING"];
    }
    return _requestFromList;
}

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.headerBtn.layer.cornerRadius = 60.f;
    self.headerBtn.layer.borderColor = COMMON_HEADER_BORDER_COLOR.CGColor;
    self.headerBtn.layer.borderWidth = 4.f;
    self.headerBtn.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userProfileLoaded:) name:USER_PROFILE_LOAD_NOTI object:nil];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"navi_edit") style:UIBarButtonItemStylePlain target:self action:@selector(editProfileAction:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"navi_option") style:UIBarButtonItemStylePlain target:self action:@selector(optionAction)];
    
    self.navigationItem.title = LOC_STR(@"Profile");
    
    [self.deviceConllectionView registerNib:[UINib nibWithNibName:@"ProfileReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileReusableView"];
    [self.deviceSharedCollectionView registerNib:[UINib nibWithNibName:@"ProfileReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileReusableView"];
    [self.pendingRequestCollectionView registerNib:[UINib nibWithNibName:@"ProfileReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileReusableView"];
    [self.requestCollectionView registerNib:[UINib nibWithNibName:@"ProfileReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ProfileReusableView"];
    
    self.deviceConllectionView.backgroundColor = [UIColor clearColor];
    self.deviceSharedCollectionView.backgroundColor = [UIColor clearColor];
    self.pendingRequestCollectionView.backgroundColor = [UIColor clearColor];
    self.requestCollectionView.backgroundColor = [UIColor clearColor];
    self.deviceConllectionView.backgroundView = [UIView new];
    self.deviceSharedCollectionView.backgroundView = [UIView new];
    self.pendingRequestCollectionView.backgroundView = [UIView new];
    self.requestCollectionView.backgroundView = [UIView new];
    
    self.deviceLabel.text = LOC_STR(@"My devices");
    self.deviceSharedLabel.text = LOC_STR(@"Devices shared with me");
    self.pendingLabel.text = LOC_STR(@"Your pending request to");
    self.requestLabel.text = [NSString stringWithFormat: LOC_STR(@"You have %d requests from"), 0];
    
    UIImage *image = LOAD_IMAGE(@"california_bg");
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.scrollView addSubview:imageView];
    
    [imageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    [imageView autoSetDimension:ALDimensionHeight toSize:kDeviceWidth * image.size.height / image.size.width];
    self.bottomLC.constant = kDeviceWidth * image.size.height / image.size.width;
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
        self.nameLabel.text = [GlobalCache shareInstance].user.fullName;
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
    
    [[SwingClient sharedClient] subHostList:nil completion:^(NSArray *requestFrom, NSArray *requestTo, NSError *error) {
        if (!error) {
            [GlobalCache shareInstance].subHostRequestTo = [NSMutableArray arrayWithArray:requestTo];
            [GlobalCache shareInstance].subHostRequestFrom = [NSMutableArray arrayWithArray:requestFrom];
            [self reloadSubHost];
        }
        else {
            LOG_D(@"subHostList fail: %@", error);
        }
    }];
    [self reloadSubHost];
}

- (void)reloadSubHost {
    self.kids = nil;
    self.sharedKids = nil;
    self.pendingRequestToList = nil;
    self.requestFromList = nil;
    
    [self.deviceSharedCollectionView reloadData];
    [self.pendingRequestCollectionView reloadData];
    [self.requestCollectionView reloadData];
    
    self.requestLabel.text = [NSString stringWithFormat: LOC_STR(@"You have %d requests from"), (int)self.requestFromList.count];
}

- (void)editProfileAction:(id)sender {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
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
        return self.kids.count + 1;
    }
    else if (collectionView == self.deviceSharedCollectionView) {
        return self.sharedKids.count;
    }
    else if (collectionView == self.pendingRequestCollectionView) {
        return self.pendingRequestToList.count + 1;
    }
    else if (collectionView == self.requestCollectionView) {
        return self.requestFromList.count;
    }
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSUInteger count = 0;
    if (collectionView == self.deviceConllectionView) {
        count = self.kids.count + 1;
    }
    else if (collectionView == self.deviceSharedCollectionView) {
        count = self.sharedKids.count;
    }
    else if (collectionView == self.pendingRequestCollectionView) {
        count = self.pendingRequestToList.count + 1;
    }
    else if (collectionView == self.requestCollectionView) {
        count = self.requestFromList.count;
    }
    CGFloat left = (collectionView.frame.size.width - (55 * count - 5)) / 2;
    return UIEdgeInsetsMake(5, left > 10 ? left : 10, 0, 10);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    ProfileDeviceCell *deviceCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DeviceCell" forIndexPath:indexPath];
    
    NSString *profile = nil;
    if (collectionView == self.deviceConllectionView) {
        if (indexPath.row == self.kids.count) {
            [deviceCell.imageBtn sd_cancelBackgroundImageLoadForState:UIControlStateNormal];
            [deviceCell.imageBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [deviceCell.imageBtn setTitle:@"+" forState:UIControlStateNormal];
            deviceCell.checked = NO;
            return deviceCell;
        }
        KidInfo *model = [self.kids objectAtIndex:indexPath.row];
        profile = model.profile;
        deviceCell.checked = model.objId == [GlobalCache shareInstance].currentKid.objId;
    }
    else if (collectionView == self.deviceSharedCollectionView) {
        KidInfo *model = [self.sharedKids objectAtIndex:indexPath.row];
        profile = model.profile;
        deviceCell.checked = model.objId == [GlobalCache shareInstance].currentKid.objId;
    }
    else if (collectionView == self.pendingRequestCollectionView) {
        if (indexPath.row == self.pendingRequestToList.count) {
            [deviceCell.imageBtn sd_cancelBackgroundImageLoadForState:UIControlStateNormal];
            [deviceCell.imageBtn setBackgroundImage:nil forState:UIControlStateNormal];
            [deviceCell.imageBtn setTitle:@"+" forState:UIControlStateNormal];
            return deviceCell;
        }
        SubHostModel *model = [self.pendingRequestToList objectAtIndex:indexPath.row];
        profile = model.requestToUser.profile;
    }
    else if (collectionView == self.requestCollectionView) {
        SubHostModel *model = [self.requestFromList objectAtIndex:indexPath.row];
        profile = model.requestFromUser.profile;
    }
    
    
    if (profile.length > 0) {
        [deviceCell.imageBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:profile]] forState:UIControlStateNormal];
    }
    else {
        [deviceCell.imageBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
    [deviceCell.imageBtn setTitle:nil forState:UIControlStateNormal];
    cell = deviceCell;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.deviceConllectionView) {
        if (indexPath.row == self.kids.count) {
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
            UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"SearchWatch"];
            [self.navigationController pushViewController:ctl animated:YES];
            return;
        }
        KidInfo *model = [self.kids objectAtIndex:indexPath.row];
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
        MutiListViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"MutiList2"];
        ctl.kid = model;
        ctl.type = MutiListTypeKidProfile;
        [self.navigationController pushViewController:ctl animated:YES];
    }
    else if (collectionView == self.deviceSharedCollectionView) {
        KidInfo *model = [self.sharedKids objectAtIndex:indexPath.row];
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
        MutiConfirmViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"MutiConfirm"];
        ctl.kid = model;
        ctl.type = MutiConfirmTypeSharedKid;
        [self.navigationController pushViewController:ctl animated:YES];
    }
    else if (collectionView == self.pendingRequestCollectionView) {
        if (indexPath.row == self.pendingRequestToList.count) {
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
            UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"SearchEmail"];
            [self.navigationController pushViewController:ctl animated:YES];
            return;
        }
        SubHostModel *model = [self.pendingRequestToList objectAtIndex:indexPath.row];
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
        MutiRequestViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"MutiRequest"];
        ctl.type = MutiRequestTypePending;
        ctl.subHost = model;
        [self.navigationController pushViewController:ctl animated:YES];
    }
    else if (collectionView == self.requestCollectionView) {
        SubHostModel *model = [self.requestFromList objectAtIndex:indexPath.row];
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
        MutiRequestViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"MutiRequest"];
        ctl.type = MutiRequestTypeFrom;
        ctl.subHost = model;
        [self.navigationController pushViewController:ctl animated:YES];
    }
}

@end
