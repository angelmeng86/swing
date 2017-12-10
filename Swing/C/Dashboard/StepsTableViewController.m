//
//  StepsTableViewController.m
//  Swing
//
//  Created by Mapple on 2017/11/24.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "StepsTableViewController.h"
#import "CommonDef.h"
#import "TodayStepCell.h"
#import "DateStepCell.h"

@interface StepsTableViewController ()
{
    NSDateFormatter *dateFormatter;
    NSDateFormatter *dateFormatter2;
    NSDateFormatter *dateFormatter3;
}

@end

@implementation StepsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [ControlFactory imageFromColor:self.stepChartColor size:CGSizeMake(100, 30)];
    self.view.backgroundColor = self.backgroundColor;
    //    UIImage *image = [ControlFactory imageFromColor:[UIColor redColor] size:CGSizeMake(100, 30)];
    
    self.indoorBtn.layer.borderWidth = 2;
    self.indoorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.indoorBtn.layer.masksToBounds = YES;
    self.indoorBtn.adjustsImageWhenHighlighted = NO;
    self.indoorBtn.showsTouchWhenHighlighted = NO;
    [self.indoorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.indoorBtn setBackgroundImage:image forState:UIControlStateSelected];
    [self.indoorBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.outdoorBtn.layer.borderWidth = 2;
    self.outdoorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.outdoorBtn.layer.masksToBounds = YES;
    self.outdoorBtn.adjustsImageWhenHighlighted = NO;
    self.outdoorBtn.showsTouchWhenHighlighted = NO;
    [self.outdoorBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.outdoorBtn setBackgroundImage:image forState:UIControlStateSelected];
    [self.outdoorBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DateStepCell" bundle:nil] forCellReuseIdentifier:@"DateStepCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"TodayStepCell" bundle:nil] forCellReuseIdentifier:@"TodayStepCell"];
    
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.backgroundView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    
    if (self.outdoorFirstShow) {
        self.outdoorBtn.selected = YES;
    }
    else {
        self.indoorBtn.selected = YES;
    }
    
    [self.indoorBtn setTitle:LOC_STR(@"Indoor") forState:UIControlStateNormal];
    [self.outdoorBtn setTitle:LOC_STR(@"Outdoor") forState:UIControlStateNormal];
    
    if (self.type == StepsTypeToday) {
        [self requestData];
    }
}

- (void)requestData {
    
    int64_t kidId = [GlobalCache shareInstance].currentKid.objId;
    if (kidId == 0) {
        return;
    }
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    [[SwingClient sharedClient] deviceGetActivityHourlyByTime:kidId beginTimestamp:startDate endTimestamp:endDate completion:^(id dailyActs, NSError *error) {
        if (!error) {
            LOG_D(@"hourly dailyActs:%@", dailyActs);
            NSMutableArray *indoors = [NSMutableArray array];
            NSMutableArray *outdoors = [NSMutableArray array];
            for (ActivityResultModel *m in dailyActs) {
                if ([m.type isEqualToString:@"INDOOR"]) {
                    [indoors addObject:m];
                }
                else if([m.type isEqualToString:@"OUTDOOR"]) {
                    [outdoors addObject:m];
                }
            }
            
            [indoors sortUsingComparator:^NSComparisonResult(ActivityResultModel *obj1, ActivityResultModel* obj2) {
                return [obj2.receivedDate compare:obj1.receivedDate];
            }];
            [outdoors sortUsingComparator:^NSComparisonResult(ActivityResultModel *obj1, ActivityResultModel* obj2) {
                return [obj2.receivedDate compare:obj1.receivedDate];
            }];
            
            self.indoorData = indoors;
            self.outdoorData = outdoors;
            
            [self.tableView reloadData];
        }
        else {
            LOG_D(@"deviceGetActivity fail: %@", error);
        }
    }];
}

- (void)btnAction:(id)sender {
    if (self.indoorBtn == sender) {
        self.indoorBtn.selected = YES;
        self.outdoorBtn.selected = NO;
        [self.tableView reloadData];
    }
    else {
        self.indoorBtn.selected = NO;
        self.outdoorBtn.selected = YES;
        [self.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_type == StepsTypeToday) {
        return 24;
    }
    return self.indoorBtn.selected ? self.indoorData.count : self.outdoorData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.type == StepsTypeToday) {
        static NSString *CellIdentifier = @"TodayStepCell";
        
        TodayStepCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.startTimeLabel.textColor = self.stepChartColor;
        cell.endTimeLabel.textColor = self.stepChartColor;
        cell.valueLabel.textColor = self.stepChartColor;
        cell.stepsLabel.textColor = self.stepChartColor;
        
        if (dateFormatter3 == nil) {
            dateFormatter3 = [[NSDateFormatter alloc] init];
            dateFormatter3.locale = [NSLocale localeWithLocaleIdentifier:[GlobalCache shareInstance].curLanguage];
            [dateFormatter3 setDateFormat:@"hh:mm a"];
        }
        
        NSArray *array = self.indoorBtn.selected ? self.indoorData : self.outdoorData;
        
        cell.subTitleLabel.text = LOC_STR(@"Today");
        for (ActivityResultModel *model in array) {
            NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:model.receivedDate];
            if (comps.hour == indexPath.row) {
                NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
                NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMinute value:59 toDate:startDate options:0];
                cell.startTimeLabel.text = [dateFormatter3 stringFromDate:startDate];
                cell.endTimeLabel.text = [dateFormatter3 stringFromDate:endDate];
                
                cell.valueLabel.text = [Fun countNumAndChangeformat:model.steps];
                return cell;
            }
        }
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setValue:indexPath.row forComponent:NSCalendarUnitHour];
        NSDate *startDate = [[NSCalendar currentCalendar] dateFromComponents:comps];
        NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMinute value:59 toDate:startDate options:0];
        cell.startTimeLabel.text = [dateFormatter3 stringFromDate:startDate];
        cell.endTimeLabel.text = [dateFormatter3 stringFromDate:endDate];
        
        cell.valueLabel.text = @"0";
        return cell;
    }
    else if(self.type == StepsTypeYear){
        static NSString *CellIdentifier = @"DateStepCell";
        
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:[GlobalCache shareInstance].curLanguage];
            [dateFormatter setDateFormat:@"MMM"];
            
            dateFormatter2 = [NSDateFormatter new];
            dateFormatter2.dateFormat = @"yyyy";
            
            dateFormatter2.locale = [NSLocale localeWithLocaleIdentifier:[GlobalCache shareInstance].curLanguage];
        }
        
        NSArray *array = self.indoorBtn.selected ? self.indoorData : self.outdoorData;
        
        ActivityResultModel *model = array[indexPath.row];
        DateStepCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.dateLabel.textColor = self.stepChartColor;
        cell.valueLabel.textColor = self.stepChartColor;
        cell.stepsLabel.textColor = self.stepChartColor;
        
        cell.dateLabel.text = [dateFormatter stringFromDate:model.receivedDate];
        cell.weekDayLabel.text = [dateFormatter2 stringFromDate:model.receivedDate];
        cell.valueLabel.text = [Fun countNumAndChangeformat:model.steps];
        
        return cell;
    }
    else {
        static NSString *CellIdentifier = @"DateStepCell";
        if(!dateFormatter){
            dateFormatter = [NSDateFormatter new];
            if ([[GlobalCache shareInstance].curLanguage.lowercaseString isEqualToString:@"ja"] || [[GlobalCache shareInstance].curLanguage.lowercaseString isEqualToString:@"zh-hant"]) {
                dateFormatter.dateFormat = @"MMM d日, yyyy";
            }
            else {
                dateFormatter.dateFormat = @"MMM d, yyyy";
            }
//            dateFormatter.dateFormat = @"MMM d, yyyy";
            
            dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:[GlobalCache shareInstance].curLanguage];
            
            dateFormatter2 = [NSDateFormatter new];
            dateFormatter2.dateFormat = @"EEEE";
            
            dateFormatter2.locale = [NSLocale localeWithLocaleIdentifier:[GlobalCache shareInstance].curLanguage];
        }
        
        NSArray *array = self.indoorBtn.selected ? self.indoorData : self.outdoorData;
        
        ActivityResultModel *model = array[indexPath.row];
        DateStepCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.dateLabel.textColor = self.stepChartColor;
        cell.valueLabel.textColor = self.stepChartColor;
        cell.stepsLabel.textColor = self.stepChartColor;
        
        cell.dateLabel.text = [dateFormatter stringFromDate:model.receivedDate];
        cell.weekDayLabel.text = [dateFormatter2 stringFromDate:model.receivedDate];
        cell.valueLabel.text = [Fun countNumAndChangeformat:model.steps];
        
        return cell;
    }
}

@end
