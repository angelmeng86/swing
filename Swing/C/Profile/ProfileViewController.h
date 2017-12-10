//
//  ProfileViewController.h
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@interface ProfileViewController : LMBaseViewController

@property (weak, nonatomic) IBOutlet UIButton *headerBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *deviceConllectionView;
@property (weak, nonatomic) IBOutlet UILabel *deviceLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *deviceSharedCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *deviceSharedLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *pendingRequestCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *pendingLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *requestCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *requestLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLC;

@end
