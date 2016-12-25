//
//  DashboardViewController.m
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "DashboardViewController.h"
#import "CommonDef.h"

typedef enum : NSUInteger {
    DashboardTypeHappy = 0,
    DashboardTypeNormal,
    DashboardTypeDown,
} DashboardType;

@interface DashboardViewController ()
{
    NSUInteger _type;
}

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    self.notLoadBackgroudImage = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.uvBtn.layer.cornerRadius = 40.f;
    self.uvBtn.layer.masksToBounds = YES;
    
    self.stepBtn.layer.cornerRadius = 40.f;
    self.stepBtn.layer.masksToBounds = YES;
    
    self.tempBtn.layer.cornerRadius = 40.f;
    self.tempBtn.layer.masksToBounds = YES;
    _type = -1;
    
    self.navigationItem.title = LOC_STR(@"Dashboard");
    self.titleLabel.text = LOC_STR(@"How are you doing today?");
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sync" style:UIBarButtonItemStylePlain target:self action:@selector(showSyncDialog)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    long steps = [GlobalCache shareInstance].local.indoorSteps + [GlobalCache shareInstance].local.outdoorSteps;
    if (steps < 7000) {
        [self setType:DashboardTypeDown];
    }
    else if(steps > 10000) {
        [self setType:DashboardTypeHappy];
    }
    else {
        [self setType:DashboardTypeNormal];
    }
    /*
    switch (_type) {
        case DashboardTypeHappy:
            [self setType:DashboardTypeNormal];
            break;
            
        case DashboardTypeNormal:
            [self setType:DashboardTypeDown];
            break;
            
        default:
            [self setType:DashboardTypeHappy];
            break;
    }
     */
}

- (void)setType:(DashboardType)type {
    switch (type) {
        case DashboardTypeHappy:
        {
            self.titleLabel.textColor = RGBA(226, 103, 46, 1.0f);
            self.subTitleLabel.textColor = self.titleLabel.textColor;
            self.subTitleLabel.text = LOC_STR(@"Excellent!");
//            self.view.backgroundColor = RGBA(249, 211, 186, 1.0f);
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dashboard-bg-monster-3"]];
            self.imageView.image = LOAD_IMAGE(@"monster-yellow");
            [self.uvBtn setImage:LOAD_IMAGE(@"orange_uv_button") forState:UIControlStateNormal];
            [self.stepBtn setImage:LOAD_IMAGE(@"orange_activity_button") forState:UIControlStateNormal];
            [self.tempBtn setImage:LOAD_IMAGE(@"orange_weather_button") forState:UIControlStateNormal];
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
            [self.uvBtn setImage:LOAD_IMAGE(@"blue_uv_button") forState:UIControlStateNormal];
            [self.stepBtn setImage:LOAD_IMAGE(@"blue_activity_button") forState:UIControlStateNormal];
            [self.tempBtn setImage:LOAD_IMAGE(@"blue_weather_button") forState:UIControlStateNormal];
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
            [self.uvBtn setImage:LOAD_IMAGE(@"uv_button") forState:UIControlStateNormal];
            [self.stepBtn setImage:LOAD_IMAGE(@"activity_button") forState:UIControlStateNormal];
            [self.tempBtn setImage:LOAD_IMAGE(@"weather_button") forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    _type = type;
}

//- (void)showSyncDialog {
//    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"SyncDevice" bundle:nil];
//    UIViewController *ctl = [stroyBoard instantiateInitialViewController];
//    [self presentViewController:ctl animated:YES completion:nil];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
