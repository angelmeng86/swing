//
//  TodayChartViewController.m
//  Swing
//
//  Created by Mapple on 16/8/9.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "TodayChartViewController.h"
#import "RectProgress.h"
#import "CommonDef.h"
#import "LMArrowView.h"
#import "LFLineView.h"
#import "StepsTableViewController.h"

@interface TodayChartViewController ()
{
    LFLineView *line;
}

@property (nonatomic, strong) NSLayoutConstraint *lineWidth;

@property (nonatomic, strong) ActivityResultModel* indoor;
@property (nonatomic, strong) ActivityResultModel* outdoor;

@end

@implementation TodayChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBA(0xdc, 0xcc, 0xfe, 1.0f);
    
    long steps = [GlobalCache shareInstance].local.indoorSteps + [GlobalCache shareInstance].local.outdoorSteps;
    if (steps < STEPS_LEVEL_LOW) {
        self.titleLabel.textColor = RGBA(99, 92, 170, 1.0f);;
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-monster-1"]];
    }
    else if(steps > STEPS_LEVEL_GOOD) {
        self.titleLabel.textColor = RGBA(56, 181, 155, 1.0f);
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-monster-2"]];
    }
    else {
        self.titleLabel.textColor = RGBA(226, 103, 46, 1.0f);
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-monster-3"]];
    }
    
    LMArrowView *leftView = [LMArrowView new];
    LMArrowView *rightView = [LMArrowView new];
    rightView.arrow = LMArrowRight;
    
    leftView.color = _titleLabel.textColor;
    rightView.color = _titleLabel.textColor;
    
    self.subTitle.textColor = _titleLabel.textColor;
    
    [self.view addSubview:leftView];
    [self.view addSubview:rightView];
    [leftView autoSetDimensionsToSize:CGSizeMake(10, 10)];
    [leftView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_titleLabel];
    [leftView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:_titleLabel];
    [rightView autoSetDimensionsToSize:CGSizeMake(10, 10)];
    [rightView autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_titleLabel];
    [rightView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:_titleLabel];
    
    self.stepProgress.progressTotal = 150;
    self.stepProgress.progressCounter = 0;
    
    self.distanceProgress.progressTotal = 150;
    self.distanceProgress.progressCounter = 0;
    
    self.flightsProgress.progressTotal = 150;
    self.flightsProgress.progressCounter = 0;
    
//    LFLineView *line = [LFLineView new];
    line = [[LFLineView alloc] initWithLineLength:6 withLineSpacing:3 withLineColor:DASHBOARD_LINE_COLOR];
//    line.backgroundColor = [UIColor redColor];
    [self.view addSubview:line];
    
    [line autoSetDimension:ALDimensionWidth toSize:5];
    [line autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:_stepProgress withOffset:-15];
    [line autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:_stepProgress withOffset:15];
    
    
    
    UILabel *label = [UILabel new];
    label.textColor = DASHBOARD_LINE_COLOR;
    label.font = [UIFont boldAvenirFontOfSize:15];
    label.text = LOC_STR(@"Goal");
    [self.view addSubview:label];
    [label autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:line withOffset:3];
    [label autoAlignAxis:ALAxisVertical toSameAxisOfView:line];
    
    CGFloat lineWidth = STEPS_LEVEL_GOAL / (STEPS_LEVEL_HIGH / (kDeviceWidth - 40));
    self.lineWidth = [line autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:_stepProgress withOffset:lineWidth];
//    [line autoAlignAxis:ALAxisHorizontal toSameAxisOfView:_distanceProgress];
    
//    UIImage *image = [ControlFactory imageFromColor:RGBA(0x67, 0x5c, 0xa7, 1.0f) size:CGSizeMake(100, 30)];
    UIImage *image = [ControlFactory imageFromColor:_titleLabel.textColor size:CGSizeMake(100, 30)];
    
    self.indoorBtn.layer.borderWidth = 2;
    self.indoorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.indoorBtn.layer.masksToBounds = YES;
    self.indoorBtn.adjustsImageWhenHighlighted = NO;
    self.indoorBtn.showsTouchWhenHighlighted = NO;
    [self.indoorBtn setTitleColor:_titleLabel.textColor forState:UIControlStateNormal];
    [self.indoorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.indoorBtn setBackgroundImage:image forState:UIControlStateSelected];
    [self.indoorBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.outdoorBtn.layer.borderWidth = 2;
    self.outdoorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.outdoorBtn.layer.masksToBounds = YES;
    self.outdoorBtn.adjustsImageWhenHighlighted = NO;
    self.outdoorBtn.showsTouchWhenHighlighted = NO;
    [self.outdoorBtn setTitleColor:_titleLabel.textColor forState:UIControlStateNormal];
    [self.outdoorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.outdoorBtn setBackgroundImage:image forState:UIControlStateSelected];
    [self.outdoorBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.stepProgress.adjustsFontSizeToFitWidth = YES;
//    self.stepProgress.backgroundColor = [UIColor lightGrayColor];
    
    self.titleLabel.text = LOC_STR(@"Today");
    self.titleLabel.font = [UIFont boldAvenirFontOfSize:17];
    [self.indoorBtn setTitle:LOC_STR(@"Indoor") forState:UIControlStateNormal];
    [self.outdoorBtn setTitle:LOC_STR(@"Outdoor") forState:UIControlStateNormal];
    self.subTitle.adjustsFontSizeToFitWidth = YES;
    self.subTitle.text = LOC_STR(@"Don't give up. You can do this!");
    
    if (self.outdoorFirstShow) {
        self.outdoorBtn.selected = YES;
    }
    else {
        self.indoorBtn.selected = YES;
    }
    
    self.indoor = [ActivityResultModel new];
    self.outdoor = [ActivityResultModel new];
    self.indoor.steps = [GlobalCache shareInstance].local.indoorSteps;
    self.outdoor.steps = [GlobalCache shareInstance].local.outdoorSteps;
    [self reloadData];
    
    [ControlFactory setClickAction:self.stepProgress target:self action:@selector(stepAction)];
}

- (void)stepAction
{
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Dashboard" bundle:nil];
    StepsTableViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"StepsTableCtl"];
    ctl.title = self.titleLabel.text;
    ctl.type = StepsTypeToday;
    ctl.stepChartColor = _titleLabel.textColor;
    ctl.backgroundColor = self.view.backgroundColor;
    ctl.outdoorFirstShow = self.outdoorBtn.selected;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)btnAction:(id)sender {
    if (self.indoorBtn == sender) {
        self.indoorBtn.selected = YES;
        self.outdoorBtn.selected = NO;
        [self reloadData];
    }
    else {
        self.indoorBtn.selected = NO;
        self.outdoorBtn.selected = YES;
        [self reloadData];
    }
    if ([_delegate respondsToSelector:@selector(showChanged:)]) {
        [_delegate showChanged:self.outdoorBtn.selected];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadData {
    if (self.indoorBtn.selected) {
//        self.stepProgress.progressTotal = self.indoor.steps * 2;
//        self.stepProgress.progressCounter = self.indoor.steps;
        
        if (self.indoor.steps == 0) {
            self.stepProgress.progressTotal = 0;
            self.stepProgress.progressCounter = 0;
            self.subTitle.text = LOC_STR(@"Don't give up. You can do this!");
        }
        else if (self.indoor.steps < STEPS_LEVEL_LOW) {
            self.stepProgress.progressTotal = 100;
            self.stepProgress.progressCounter = 40;
            self.subTitle.text = LOC_STR(@"Don't give up. You can do this!");
        }
        else if (self.indoor.steps < STEPS_LEVEL_GOOD) {
            self.stepProgress.progressTotal = STEPS_LEVEL_HIGH;
            self.stepProgress.progressCounter = self.indoor.steps;
            self.subTitle.text = LOC_STR(@"One more time. You are almost there");
        }
        else if (self.indoor.steps < STEPS_LEVEL_HIGH) {
            self.stepProgress.progressTotal = STEPS_LEVEL_HIGH;
            self.stepProgress.progressCounter = self.indoor.steps;
            self.subTitle.text = LOC_STR(@"Woohoo! You've reached your goal!");
        }
        
        self.stepProgress.text = [NSString stringWithFormat:@"%@ %ld", LOC_STR(@"Steps"), self.indoor.steps];
    }
    else {
        if (self.outdoor.steps == 0) {
            self.stepProgress.progressTotal = 0;
            self.stepProgress.progressCounter = 0;
            self.subTitle.text = LOC_STR(@"Don't give up. You can do this!");
        }
        else if (self.outdoor.steps < STEPS_LEVEL_LOW) {
            self.stepProgress.progressTotal = 100;
            self.stepProgress.progressCounter = 40;
//            self.subTitle.text = LOC_STR(@"Don't give up. You can do this!");
        }
        else if (self.outdoor.steps < STEPS_LEVEL_GOOD) {
            self.stepProgress.progressTotal = STEPS_LEVEL_HIGH;
            self.stepProgress.progressCounter = self.outdoor.steps;
//            self.subTitle.text = LOC_STR(@"One more time. You are almost there");
        }
        else if (self.outdoor.steps < STEPS_LEVEL_HIGH) {
            self.stepProgress.progressTotal = STEPS_LEVEL_HIGH;
            self.stepProgress.progressCounter = self.outdoor.steps;
//            self.subTitle.text = LOC_STR(@"Woohoo! You've reached your goal!");
        }
        
//        self.stepProgress.progressTotal = self.outdoor.steps * 2;
//        self.stepProgress.progressCounter = self.outdoor.steps;
        self.stepProgress.text = [NSString stringWithFormat:@"%@ %ld", LOC_STR(@"Steps"), self.outdoor.steps];
    }
//    [self.stepProgress setNeedsLayout];
    [self.stepProgress setNeedsDisplay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    if (self.indoorBtn.selected) {
//        self.stepProgress.progressTotal = [GlobalCache shareInstance].indoorSteps * 2 + 60;
//        self.stepProgress.progressCounter = [GlobalCache shareInstance].indoorSteps;
//    }
//    else {
//        self.stepProgress.progressTotal = [GlobalCache shareInstance].outdoorSteps * 2 + 60;
//        self.stepProgress.progressCounter = [GlobalCache shareInstance].outdoorSteps;
//    }
//    [self.stepProgress setNeedsLayout];
    [self requestData];
}

- (void)requestData {
    if ([GlobalCache shareInstance].local.indoorSteps > 0 || [GlobalCache shareInstance].local.outdoorSteps > 0) {
        //判断如果本地有缓存数据则不向后台请求，主要解决因数据未上传引起的前后台数据不一致问题
        self.indoor = [ActivityResultModel new];
        self.outdoor = [ActivityResultModel new];
        self.indoor.steps = [GlobalCache shareInstance].local.indoorSteps;
        self.outdoor.steps = [GlobalCache shareInstance].local.outdoorSteps;
        [self reloadData];
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
                self.indoor = indoorModel;
                [GlobalCache shareInstance].local.indoorSteps = self.indoor.steps;
            }
            if (outdoorModel) {
                self.outdoor = outdoorModel;
                [GlobalCache shareInstance].local.outdoorSteps = self.outdoor.steps;
            }
            [[GlobalCache shareInstance] saveInfo];
            [self reloadData];
        }
        else {
            LOG_D(@"deviceGetActivity fail: %@", error);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
