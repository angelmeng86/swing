//
//  BatteryViewController.m
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "BatteryViewController.h"

@interface BatteryViewController ()


@end

@implementation BatteryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    UIColor *color = RGBA(0xe5, 0x65, 0x35, 1.0f);
    MDRadialProgressTheme *newTheme = [[MDRadialProgressTheme alloc] init];
    newTheme.completedColor = COMMON_TITLE_COLOR;
    newTheme.incompletedColor = [UIColor whiteColor];
    newTheme.centerColor = [UIColor clearColor];
    newTheme.sliceDividerHidden = YES;
    newTheme.thickness = 25;
    
    self.progressView.theme = newTheme;
    self.progressView.label.hidden = YES;
    
    self.progressView.progressTotal = 100;
    self.progressView.progressCounter = 75;
    self.progressView.theme.drawIncompleteArcIfNoProgress = YES;
    
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryNotify:) name:SWING_WATCH_BATTERY_NOTIFY object:nil];
    
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 70)];
//    view.backgroundColor = [UIColor redColor];
//    [self.navigationController.navigationBar addSubview:view];
    self.navigationItem.title = LOC_STR(@"My Watch");
    self.titleLabel.text = LOC_STR(@"Battery");
}

- (void)batteryNotify:(NSNotification*)notify {
    [self bluetoothClientBattery:[GlobalCache shareInstance].local.battery];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self bluetoothClientBattery:[GlobalCache shareInstance].local.battery];
}

- (void)bluetoothClientBattery:(int)value {
    NSLog(@"bluetoothClientBattery:%d", value);
    if (value <= 100) {
        self.progressView.progressCounter = value;
        self.textLabel.text = [NSString stringWithFormat:@"%d%%", value];
    }
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
