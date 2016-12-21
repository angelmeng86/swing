//
//  IndexViewController.m
//  Swing
//
//  Created by Mapple on 2016/12/21.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "IndexViewController.h"
#import "CommonDef.h"

@interface IndexViewController ()

@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.signLoginBtn setTitle:LOC_STR(@"Sign up/ login") forState:UIControlStateNormal];
    [self.googleLogin setTitle:LOC_STR(@"Login with Google") forState:UIControlStateNormal];
    [self.facebookLogin setTitle:LOC_STR(@"Login with Facebook") forState:UIControlStateNormal];
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
