//
//  RequestAccessViewController.m
//  Swing
//
//  Created by Mapple on 2017/10/22.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "RequestAccessViewController.h"
#import "SelectWatchViewController.h"
#import "AppDelegate.h"
#import "CommonDef.h"

@interface RequestAccessViewController ()

@end

@implementation RequestAccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.deviceLabel.text = self.kid.name;
    
    if (self.kid.profile) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.kid.profile]] placeholderImage:LOAD_IMAGE(@"dev_header_icon")];
    }
    
    [self.deviceBtn setTitle:@"+" forState:UIControlStateNormal];
}

- (void)changeInfo
{
    switch (_type) {
        case RequestTypePending:
        {
            self.label1.text = LOC_STR(@"Request access pending");
            
            [self.btn1 setTitle:LOC_STR(@"Search Again") forState:UIControlStateNormal];
            [self.btn2 setTitle:LOC_STR(@"Go to dashboard") forState:UIControlStateNormal];
        }
            break;
        default:
        {
            self.label1.text = LOC_STR(@"Request access");
            [self.btn1 setTitle:LOC_STR(@"Search Again") forState:UIControlStateNormal];
            [self.btn2 setTitle:LOC_STR(@"Cancel & go to dashboard") forState:UIControlStateNormal];
        }
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn1Action:(id)sender {
    NSArray *array = self.navigationController.viewControllers;
    for (UIViewController *ctl in array) {
        if ([ctl isKindOfClass:[SelectWatchViewController class]]) {
            [self.navigationController popToViewController:ctl animated:YES];
            break;
        }
    }
}

- (IBAction)btn2Action:(id)sender {
    AppDelegate *ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [ad goToMain];
}

- (IBAction)deviceAction:(id)sender {
    [SVProgressHUD show];
    [[SwingClient sharedClient] subHostAdd:self.kid.objId completion:^(SubHostModel *subHost, NSError *error) {
        if (error) {
            LOG_D(@"subHostAdd err: %@", error);
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
        else {
            _type = RequestTypePending;
            [self changeInfo];
            [self.deviceBtn setTitle:@"√" forState:UIControlStateNormal];
            [SVProgressHUD dismiss];
        }
    }];
}

@end
