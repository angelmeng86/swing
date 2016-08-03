//
//  WeatherContentViewController.m
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "WeatherContentViewController.h"

@interface WeatherContentViewController ()

@end

@implementation WeatherContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.progressView.theme.completedColor = COMMON_TITLE_COLOR;
    self.progressView.theme.incompletedColor = [UIColor whiteColor];
    self.progressView.theme.centerColor = [UIColor clearColor];
    self.progressView.theme.sliceDividerHidden = YES;
    self.progressView.theme.thickness = 25;
    
    self.progressView.label.hidden = YES;
    self.progressView.progressTotal = 100;
    self.progressView.progressCounter = 88;
    
    if (_pageIndex == 1) {
        UIColor *color = RGBA(0x4b, 0xbf, 0xdc, 1.0f);
        
        self.titleLabel.textColor = color;
        self.valueLabel.textColor = color;
        self.infoLabel.textColor = color;
        self.progressView.theme.completedColor = color;
        
        
        self.titleLabel.text = @"Humidity";
        self.valueLabel.text = @"90%";
        self.infoLabel.text = @"Beware of something";
        self.progressView.progressCounter = 90;
        self.view.backgroundColor = RGBA( 0xb6, 0xdd, 0xf0, 1.0f);
    }
    else {
        self.view.backgroundColor = RGBA( 0xff, 0xff, 0xa5, 1.0f);
    }
    
    
    
    
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

@end
