//
//  SearchEmailViewController.m
//  Swing
//
//  Created by Mapple on 2017/11/13.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "SearchEmailViewController.h"
#import "RequestAccessViewController.h"
#import "CommonDef.h"

@interface SearchEmailViewController ()

@property (nonatomic, strong) UserModel *user;

@end

@implementation SearchEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.deviceView.layer.cornerRadius = 5.0f;
    self.imageView.layer.cornerRadius = 12.0f;
    self.imageView.layer.masksToBounds = YES;
    
    [self.btn1 setTitle:LOC_STR(@"Search") forState:UIControlStateNormal];
    [self.deviceBtn setImage:LOAD_IMAGE(@"icon_add") forState:UIControlStateNormal];
    
    self.deviceView.hidden = YES;
    [self setCustomBackButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn1Action:(id)sender {
    if (![Fun isValidateEmail:self.emailTF.text]) {
        [Fun showMessageBoxWithTitle:LOC_STR(@"Error") andMessage:LOC_STR(@"Please input info.")];
        return;
    }
    [SVProgressHUD show];
    [[SwingClient sharedClient] getUserByEmail:self.emailTF.text completion:^(id model, NSError *error) {
        if (error) {
            LOG_D(@"getUserByEmail fail: %@", error);
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
        else {
            [SVProgressHUD dismiss];
            if ([GlobalCache shareInstance].user.objId == self.user.objId)
            {
                LOG_D(@"This is myself.");
                return;
            }
            self.user = model;
            [self loadInfo];
        }
    }];
}

- (void)loadInfo
{
    [UIView animateWithDuration:0.3f animations:^{
        self.deviceLabel.text = [self.user fullName];
        
        if (self.user.profile.length > 0) {
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.user.profile]] placeholderImage:LOAD_IMAGE(@"icon_profile")];
        }
        else {
            self.imageView.image = nil;
        }
        self.deviceView.hidden = NO;
    }];
}

- (IBAction)deviceAction:(id)sender {
    
    UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    RequestAccessViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"Access"];
    ctl.type = RequestTypeAccess;
    ctl.user = self.user;
    [self.navigationController pushViewController:ctl animated:YES];
}

@end
