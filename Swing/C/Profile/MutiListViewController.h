//
//  MutiListViewController.h
//  Swing
//
//  Created by Mapple on 2017/11/5.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

typedef enum : NSUInteger {
    MutiListTypeKidProfile,
    MutiListTypeSwitchAccount,
} MutiListType;
@class KidInfo;
@interface MutiListViewController : LMBaseViewController

@property (nonatomic) MutiListType type;

@property (nonatomic, strong) KidInfo* kid;

@property (weak, nonatomic) IBOutlet UIButton *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (weak, nonatomic) IBOutlet UILabel *conllectionLabel1;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView1;
@property (weak, nonatomic) IBOutlet UILabel *conllectionLabel2;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView2;

@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;

- (IBAction)btn1Action:(id)sender;
- (IBAction)btn2Action:(id)sender;
- (IBAction)btn3Action:(id)sender;

@end
