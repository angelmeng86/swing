//
//  DashboardViewController2.h
//  Swing
//
//  Created by Mapple on 2017/11/17.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"
@class StepsInfoView;

@interface DashboardViewController2 : LMBaseViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *stepBtn;
- (IBAction)stepAction:(id)sender;
@property (weak, nonatomic) IBOutlet StepsInfoView *indoorView;
@property (weak, nonatomic) IBOutlet StepsInfoView *outdoorView;

@end
