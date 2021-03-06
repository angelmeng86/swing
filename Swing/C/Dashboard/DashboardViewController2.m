//
//  DashboardViewController2.m
//  Swing
//
//  Created by Mapple on 2017/11/17.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "DashboardViewController2.h"
#import "StepsTableViewController.h"
#import "ActivityViewController.h"
#import "StepsInfoView.h"
#import "CommonDef.h"

typedef enum : NSUInteger {
    DashboardTypeHappy = 0,
    DashboardTypeNormal,
    DashboardTypeDown,
} DashboardType;

@interface DashboardViewController2 ()
{
    NSUInteger _type;
}

@end

@implementation DashboardViewController2

- (void)viewDidLoad {
//    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *v = [self.view viewWithTag:2017];
    v.alpha = 0.2f;
    self.stepBtn.layer.cornerRadius = 40.f;
    self.stepBtn.layer.masksToBounds = YES;
    
    _type = -1;
    
    self.navigationItem.title = LOC_STR(@"Dashboard");
    self.titleLabel.text = LOC_STR(@"How are you doing today?");
    self.infoLabel.text = LOC_STR(@"Today's Summary");
    
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.subTitleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.indoorView.leftLabel1.text = LOC_STR(@"Indoor");
    self.outdoorView.leftLabel1.text = LOC_STR(@"Outdoor");
    
    self.indoorView.timeLabel.text = LOC_STR(@"Today");
    self.outdoorView.timeLabel.text = LOC_STR(@"Today");
    
    
    [ControlFactory setClickAction:self.indoorView target:self action:@selector(indoorAction)];
    [ControlFactory setClickAction:self.outdoorView target:self action:@selector(outdoorAction)];
    
    self.indoorView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    self.outdoorView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
}

- (void)indoorAction {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"Activity"];
    [self.navigationController pushViewController:ctl animated:YES];
    
//    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Dashboard" bundle:nil];
//    StepsTableViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"StepsTableCtl"];
//    ctl.title = LOC_STR(@"Today");
//    ctl.todaySteps = YES;
//    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)outdoorAction {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    ActivityViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"Activity"];
    ctl.outdoorFirstShowInToday = YES;
    [self.navigationController pushViewController:ctl animated:YES];
    
//    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Dashboard" bundle:nil];
//    StepsTableViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"StepsTableCtl"];
//    ctl.title = LOC_STR(@"Today");
//    ctl.todaySteps = YES;
//    ctl.outdoorFirstShow = YES;
//    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
    [self requestData];
//    static int oye = 0;
//    [self setType:oye];
//    oye++;
//    oye %= 3;
}

- (void)reloadData {
    long steps = [GlobalCache shareInstance].local.indoorSteps + [GlobalCache shareInstance].local.outdoorSteps;
    if (steps < STEPS_LEVEL_LOW) {
        [self setType:DashboardTypeDown];
    }
    else if(steps > STEPS_LEVEL_GOOD) {
        [self setType:DashboardTypeHappy];
    }
    else {
        [self setType:DashboardTypeNormal];
    }
}

- (void)requestData {
    if ([GlobalCache shareInstance].local.indoorSteps > 0 || [GlobalCache shareInstance].local.outdoorSteps > 0) {
        //判断如果本地有缓存数据则不向后台请求，主要解决因数据未上传引起的前后台数据不一致问题
        return;
    }
    int64_t kidId = [GlobalCache shareInstance].currentKid.objId;
    if (kidId == 0) {
        return;
    }
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    [[SwingClient sharedClient] deviceGetActivityByTime:kidId beginTimestamp:startDate endTimestamp:endDate completion:^(id dailyActs, NSError *error) {
        if (!error) {
            LOG_D(@"today dailyActs:%@", dailyActs);
            ActivityResultModel *indoorModel = nil;
            ActivityResultModel *outdoorModel = nil;
            for (ActivityResultModel *m in dailyActs) {
                if ([m.type isEqualToString:@"INDOOR"]) {
                    if (indoorModel) {
                        indoorModel.steps += m.steps;
                    }
                    else {
                        indoorModel = m;
                    }
                    
                }
                else if([m.type isEqualToString:@"OUTDOOR"]) {
                    if (outdoorModel) {
                        outdoorModel.steps += m.steps;
                    }
                    else {
                        outdoorModel = m;
                    }
                }
            }
            if (indoorModel) {
                [GlobalCache shareInstance].local.indoorSteps = indoorModel.steps;
            }
            if (outdoorModel) {
                [GlobalCache shareInstance].local.outdoorSteps = outdoorModel.steps;
            }
            [[GlobalCache shareInstance] saveInfo];
            [self reloadData];
        }
        else {
            LOG_D(@"deviceGetActivity fail: %@", error);
        }
    }];
}

- (void)setType:(DashboardType)type {
    self.indoorView.valueLabel.text = [Fun countNumAndChangeformat:[GlobalCache shareInstance].local.indoorSteps];
    self.outdoorView.valueLabel.text = [Fun countNumAndChangeformat:[GlobalCache shareInstance].local.outdoorSteps];
    switch (type) {
        case DashboardTypeHappy:
        {
            self.titleLabel.textColor = RGBA(226, 103, 46, 1.0f);
            self.subTitleLabel.textColor = self.titleLabel.textColor;
            self.subTitleLabel.text = LOC_STR(@"Excellent!");
            //            self.view.backgroundColor = RGBA(249, 211, 186, 1.0f);
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-monster-3"]];
            self.imageView.image = LOAD_IMAGE(@"monster-yellow");
//            [self.stepBtn setImage:LOAD_IMAGE(@"orange_activity_button") forState:UIControlStateNormal];
        }
            break;
        case DashboardTypeNormal:
        {
            self.titleLabel.textColor = RGBA(56, 181, 155, 1.0f);
            self.subTitleLabel.textColor = self.titleLabel.textColor;
            self.subTitleLabel.text = LOC_STR(@"Almost There!");
            //            self.view.backgroundColor = RGBA(167, 205, 191, 1.0f);
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-monster-2"]];
            self.imageView.image = LOAD_IMAGE(@"monster-bluegreen");
//            [self.stepBtn setImage:LOAD_IMAGE(@"blue_activity_button") forState:UIControlStateNormal];
        }
            break;
        case DashboardTypeDown:
        {
            self.titleLabel.textColor = RGBA(99, 92, 170, 1.0f);
            self.subTitleLabel.textColor = self.titleLabel.textColor;
            self.subTitleLabel.text = LOC_STR(@"Below Average!");
            //            self.view.backgroundColor = RGBA(218, 193, 247, 1.0f);
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-monster-1"]];
            self.imageView.image = LOAD_IMAGE(@"monster-purple");
//            [self.stepBtn setImage:LOAD_IMAGE(@"activity_button") forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    _type = type;
    
    self.infoLabel.textColor = self.titleLabel.textColor;
    [self.indoorView setThemeColor:self.titleLabel.textColor];
    [self.outdoorView setThemeColor:self.titleLabel.textColor];
    self.stepBtn.backgroundColor = self.titleLabel.textColor;
}

- (IBAction)stepAction:(id)sender {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"Activity"];
    [self.navigationController pushViewController:ctl animated:YES];
}
@end
