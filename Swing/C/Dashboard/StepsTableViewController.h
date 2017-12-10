//
//  StepsTableViewController.h
//  Swing
//
//  Created by Mapple on 2017/11/24.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"

typedef enum : NSUInteger {
    StepsTypeYear,
    StepsTypeMonth,
    StepsTypeWeek,
    StepsTypeToday,
} StepsType;

@interface StepsTableViewController : LMBaseViewController

@property (nonatomic) StepsType type;
@property (nonatomic) BOOL outdoorFirstShow;

@property (nonatomic, strong) UIColor *stepChartColor;
@property (nonatomic, strong) UIColor *backgroundColor;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *indoorBtn;
@property (weak, nonatomic) IBOutlet UIButton *outdoorBtn;

@property (nonatomic, strong) NSArray *indoorData;
@property (nonatomic, strong) NSArray *outdoorData;

@end
