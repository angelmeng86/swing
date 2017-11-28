//
//  StepsTableViewController.h
//  Swing
//
//  Created by Mapple on 2017/11/24.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

@interface StepsTableViewController : LMBaseViewController

@property (nonatomic) BOOL todaySteps;
@property (nonatomic) BOOL outdoorFirstShow;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *indoorBtn;
@property (weak, nonatomic) IBOutlet UIButton *outdoorBtn;

@property (nonatomic, strong) NSArray *indoorData;
@property (nonatomic, strong) NSArray *outdoorData;

@end
