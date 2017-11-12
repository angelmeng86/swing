//
//  MutiShareToViewController.m
//  Swing
//
//  Created by Mapple on 2017/11/6.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "MutiShareToViewController.h"
#import "CommonDef.h"
#import "ProfileDeviceCell.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "MutiRequestViewController.h"

@interface MutiShareToViewController ()

@property (nonatomic, strong) NSArray* array1;
@property (nonatomic, strong) NSMutableSet *selectedSet;

@end

@implementation MutiShareToViewController

- (NSArray*)array1
{
    if (_array1 == nil) {
        _array1 = [DBHelper queryKids:NO];
    }
    return _array1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.collectionView1.backgroundColor = [UIColor clearColor];
    self.collectionView1.backgroundView = [UIView new];
    
    self.collectionView1.allowsMultipleSelection = YES;
    self.selectedSet = [NSMutableSet set];
    
    self.title = LOC_STR(@"Request from");
    
    self.titleLabel.text = LOC_STR(@"Select share to watch");
    self.subTitleLabel.text = [LOC_STR(@"Please tap on one or more profile pictures to share with ") stringByAppendingString:self.subHost.requestFromUser.fullName];
    
    [self.button1 setTitle:LOC_STR(@"Confirm") forState:UIControlStateNormal];
    [self.button2 setTitle:LOC_STR(@"Decline") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn1Action:(id)sender {
    if (self.selectedSet.count == 0) {
        return;
    }
    [SVProgressHUD show];
    NSMutableArray *kidIds = [NSMutableArray array];
    for (NSIndexPath *indexPath in self.selectedSet) {
        KidInfo *model = [self.array1 objectAtIndex:indexPath.row];
        [kidIds addObject:@(model.objId)];
    }
    [[SwingClient sharedClient] subHostAccept:self.subHost.objId kidIds:kidIds completion:^(id subHost, NSError *error) {
        if (error) {
            LOG_D(@"subHostAccept fail: %@", error);
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
        else {
            [SVProgressHUD dismiss];
            [[GlobalCache shareInstance].subHostRequestFrom removeObject:self.subHost];
            [[GlobalCache shareInstance].subHostRequestFrom addObject:subHost];
            self.preCtl.type = MutiRequestTypeShareDone;
            [self.preCtl loadInfo];
            [self backAction];
        }
    }];
}

- (IBAction)btn2Action:(id)sender {
    self.preCtl.type = MutiRequestTypeFromDeny;
    [self.preCtl loadInfo];
    [self backAction];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.collectionView1) {
        return self.array1.count;
    }
    
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSUInteger count = 0;
    if (collectionView == self.collectionView1) {
        count = self.array1.count;
    }
    CGFloat left = (collectionView.frame.size.width - (55 * count - 5)) / 2;
    return UIEdgeInsetsMake(5, left > 10 ? left : 10, 0, 10);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    ProfileDeviceCell *deviceCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DeviceCell" forIndexPath:indexPath];
    
    NSString *profile = nil;

    KidInfo *model = [self.array1 objectAtIndex:indexPath.row];
    profile = model.profile;
  
    
    
    if (profile.length > 0) {
        [deviceCell.imageBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:profile]] forState:UIControlStateNormal];
    }
    else {
        [deviceCell.imageBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
    [deviceCell.imageBtn setTitle:nil forState:UIControlStateNormal];
    deviceCell.checked = [self.selectedSet containsObject:indexPath];
    cell = deviceCell;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.selectedSet containsObject:indexPath]) {
        [self.selectedSet removeObject:indexPath];
    }
    else {
        [self.selectedSet addObject:indexPath];
    }
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

@end
