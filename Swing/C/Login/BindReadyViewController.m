//
//  BindReadyViewController.m
//  Swing
//
//  Created by Mapple on 16/7/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "BindReadyViewController.h"
#import "AppDelegate.h"
#import "CommonDef.h"

@interface BindReadyViewController ()

@end

@implementation BindReadyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView.layer.cornerRadius = 60.f;
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = 4.f;
    self.imageView.layer.masksToBounds = YES;
    
    [self.goDashBtn setTitle:LOC_STR(@"Go to dashboard") forState:UIControlStateNormal];
    [self.addWatchBtn setTitle:LOC_STR(@"Add another watch") forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_image) {
        self.imageView.image = _image;
    }
    self.nameLabel.text = self.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goAction:(id)sender {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab2" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateInitialViewController];
    AppDelegate *ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ad.window.rootViewController = ctl;
}

@end
