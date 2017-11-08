//
//  MutiShareToViewController.h
//  Swing
//
//  Created by Mapple on 2017/11/6.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@class SubHostModel;
@class MutiRequestViewController;
@interface MutiShareToViewController : LMBaseViewController

@property (weak, nonatomic) MutiRequestViewController* preCtl;

@property (strong, nonatomic) SubHostModel* subHost;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *conllectionLabel1;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView1;

@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;

- (IBAction)btn1Action:(id)sender;
- (IBAction)btn2Action:(id)sender;

@end
