//
//  BindReadyViewController.m
//  Swing
//
//  Created by Mapple on 16/7/26.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "BindReadyViewController.h"
#import "AppDelegate.h"

@interface BindReadyViewController ()

@end

@implementation BindReadyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView.layer.cornerRadius = 60.f;
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = 2.f;
    self.imageView.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_image) {
        self.imageView.image = _image;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goAction:(id)sender {
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateInitialViewController];
    AppDelegate *ad = [UIApplication sharedApplication].delegate;
    ad.window.rootViewController = ctl;
}

@end