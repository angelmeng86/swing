//
//  LogoutConfirmViewController.m
//  Swing
//
//  Created by Mapple on 2017/11/4.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "LogoutConfirmViewController.h"
#import "CommonDef.h"

@interface LogoutConfirmViewController ()

@end

@implementation LogoutConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView.layer.cornerRadius = 60.f;
    self.imageView.layer.borderColor = COMMON_HEADER_BORDER_COLOR.CGColor;
    self.imageView.layer.borderWidth = 4.f;
    self.imageView.layer.masksToBounds = YES;
    
    self.infoLabel.text = LOC_STR(@"Are you sure to log out?");
    [self.yesBtn setTitle:LOC_STR(@"Yes,I am sure") forState:UIControlStateNormal];
    [self.cancelBtn setTitle:LOC_STR(@"Cancel") forState:UIControlStateNormal];
    
    if ([GlobalCache shareInstance].user) {
        self.nameLabel.text = [GlobalCache shareInstance].user.fullName;
        self.emailLabel.text = [GlobalCache shareInstance].user.email;
        if ([GlobalCache shareInstance].user.profile.length > 0) {
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:[GlobalCache shareInstance].user.profile]]];
        }
    }
    else {
        self.nameLabel.text = @"";
        self.emailLabel.text = @"";
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

- (IBAction)yesAction:(id)sender {
    [[GlobalCache shareInstance] logout];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
