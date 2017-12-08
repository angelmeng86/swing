//
//  MutiListViewController.m
//  Swing
//
//  Created by Mapple on 2017/11/5.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "MutiListViewController.h"
#import "ProfileDeviceCell.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "CommonDef.h"
#import "EditKidViewController.h"
#import "MutiConfirmViewController.h"
#import "MutiRequestViewController.h"

@interface MutiListViewController ()

@property (nonatomic, strong) NSArray* array1;
@property (nonatomic, strong) NSArray* array2;

@end

@implementation MutiListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.layer.cornerRadius = 60.f;
    self.imageView.layer.borderColor = COMMON_HEADER_BORDER_COLOR.CGColor;
    self.imageView.layer.borderWidth = 4.f;
    self.imageView.layer.masksToBounds = YES;
    
    self.collectionView1.backgroundColor = [UIColor clearColor];
    self.collectionView1.backgroundView = [UIView new];
    
    self.collectionView2.backgroundColor = [UIColor clearColor];
    self.collectionView2.backgroundView = [UIView new];
    
//    [self loadInfo];
}

- (void)loadInfo
{
    switch (_type) {
        case MutiListTypeKidProfile:
        {
            self.title = LOC_STR(@"Kid's profile");
            if (self.kid) {
                self.titleLabel.text = self.kid.name;
                self.subTitleLabel.text = nil;
                if (self.kid.profile) {
                    [self.imageView sd_setBackgroundImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.kid.profile]] forState:UIControlStateNormal];
                }
                
            }
            self.conllectionLabel1.text = LOC_STR(@"is sharing with");
            self.conllectionLabel2.text = [NSString stringWithFormat: LOC_STR(@"You have %d requests from"), (int)self.array2.count];
            
            [self.button1 setTitle:LOC_STR(@"Edit kid's account") forState:UIControlStateNormal];
            [self.button2 setTitle:LOC_STR(@"Switch to this account") forState:UIControlStateNormal];
            self.button3.hidden = YES;
            [self.button3 setTitle:LOC_STR(@"Remove") forState:UIControlStateNormal];
        }
            break;
        case MutiListTypeSwitchAccount:
        {
            self.title = LOC_STR(@"Switch account");
            
            if (self.kid) {
                self.titleLabel.text = self.kid.name;
                self.subTitleLabel.text = nil;
                if (self.kid.profile) {
                    [self.imageView sd_setBackgroundImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.kid.profile]] forState:UIControlStateNormal];
                }
                
            }
            
            self.subTitleLabel.text = LOC_STR(@"*Tap on profile pictures to switch account");
            
            self.conllectionLabel1.text = LOC_STR(@"My devices");
            self.conllectionLabel2.text = LOC_STR(@"Devices shared with me");
        }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn1Action:(id)sender {
    if (_type == MutiListTypeKidProfile) {
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
        EditKidViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"Profile"];
        ctl.kid = self.kid;
        [self.navigationController pushViewController:ctl animated:YES];
    }
}

- (IBAction)btn2Action:(id)sender {
    if (_type == MutiListTypeKidProfile) {
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
        MutiConfirmViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"MutiConfirm"];
        ctl.kid = self.kid;
        ctl.type = MutiConfirmTypeSwitch;
        [self.navigationController pushViewController:ctl animated:YES];
    }
}

- (IBAction)btn3Action:(id)sender {
    if (_type == MutiListTypeKidProfile) {
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadInfo];
    [self reloadInfo];
}

- (void)reloadInfo {
    self.array1 = nil;
    self.array2 = nil;
    
    [self.collectionView1 reloadData];
    [self.collectionView2 reloadData];
}

- (NSArray*)array1
{
    if (_array1 == nil) {
        if (_type == MutiListTypeSwitchAccount) {
            _array1 = [DBHelper queryKids:NO];
        }
        else {
            NSArray *requests = [SubHostModel loadSubHost:[GlobalCache shareInstance].subHostRequestFrom status:@"ACCEPTED"];
            
            NSMutableArray *array = [NSMutableArray array];
            for (SubHostModel *m in requests) {
                for (KidModel *k in m.kids) {
                    if (k.objId == self.kid.objId) {
                        [array addObject:m];
                        break;
                    }
                }
            }
            _array1 = array;
        }
    }
    return _array1;
}

- (NSArray*)array2
{
    if (_array2 == nil) {
        if (_type == MutiListTypeSwitchAccount) {
            _array2 = [DBHelper queryKids:YES];
        }
        else {
            _array2 = [SubHostModel loadSubHost:[GlobalCache shareInstance].subHostRequestFrom status:@"PENDING"];
        }
    }
    return _array2;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.collectionView1) {
        return self.array1.count;
    }
    else if (collectionView == self.collectionView2) {
        return self.array2.count;
    }
    
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSUInteger count = 0;
    if (collectionView == self.collectionView1) {
        count = self.array1.count;
    }
    else if (collectionView == self.collectionView2) {
        count = self.array2.count;
    }
    CGFloat left = (collectionView.frame.size.width - (55 * count - 5)) / 2;
    return UIEdgeInsetsMake(5, left > 10 ? left : 10, 0, 10);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    ProfileDeviceCell *deviceCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DeviceCell" forIndexPath:indexPath];
    
    NSString *profile = nil;
    if (_type == MutiListTypeSwitchAccount) {
        if (collectionView == self.collectionView1) {
            KidInfo *model = [self.array1 objectAtIndex:indexPath.row];
            profile = model.profile;
        }
        else if (collectionView == self.collectionView2) {
            KidInfo *model = [self.array2 objectAtIndex:indexPath.row];
            profile = model.profile;
        }
    }
    else {
        if (collectionView == self.collectionView1) {
            SubHostModel *model = [self.array1 objectAtIndex:indexPath.row];
            profile = model.requestFromUser.profile;
        }
        else if (collectionView == self.collectionView2) {
            SubHostModel *model = [self.array2 objectAtIndex:indexPath.row];
            profile = model.requestFromUser.profile;
        }
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
    if (_type == MutiListTypeSwitchAccount) {
        if (collectionView == self.collectionView1) {
            KidInfo *model = [self.array1 objectAtIndex:indexPath.row];
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
            MutiConfirmViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"MutiConfirm"];
            ctl.kid = model;
            ctl.type = MutiConfirmTypeSwitch;
            [self.navigationController pushViewController:ctl animated:YES];
        }
        else if (collectionView == self.collectionView2) {
            KidInfo *model = [self.array2 objectAtIndex:indexPath.row];
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
            MutiConfirmViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"MutiConfirm"];
            ctl.kid = model;
            ctl.type = MutiConfirmTypeSwitch;
            [self.navigationController pushViewController:ctl animated:YES];
        }
    }
    else {
        if (collectionView == self.collectionView1) {
            SubHostModel *model = [self.array1 objectAtIndex:indexPath.row];
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
            MutiRequestViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"MutiRequest"];
            ctl.type = MutiRequestTypeShareDone;
            ctl.kid = self.kid;
            ctl.subHost = model;
            [self.navigationController pushViewController:ctl animated:YES];
        }
        else if (collectionView == self.collectionView2) {
            SubHostModel *model = [self.array2 objectAtIndex:indexPath.row];
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
            MutiRequestViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"MutiRequest"];
            ctl.type = MutiRequestTypeFrom;
            ctl.subHost = model;
            [self.navigationController pushViewController:ctl animated:YES];
        }
    }
}

@end
