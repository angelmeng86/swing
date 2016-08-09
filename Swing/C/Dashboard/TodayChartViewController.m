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

@interface TodayChartViewController ()

@end

@implementation TodayChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBA(0xdc, 0xcc, 0xfe, 1.0f);
    
    self.stepProgress.progressTotal = 150;
    self.stepProgress.progressCounter = 95;
    
    self.distanceProgress.progressTotal = 150;
    self.distanceProgress.progressCounter = 73;
    
    self.flightsProgress.progressTotal = 150;
    self.flightsProgress.progressCounter = 85;
    
    self.indoorBtn.layer.borderWidth = 2;
    self.indoorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.outdoorBtn.layer.borderWidth = 2;
    self.outdoorBtn.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)outdoorBtn:(id)sender {
}
@end
