//
//  SyncDeviceViewController.m
//  Swing
//
//  Created by Mapple on 16/7/27.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SyncDeviceViewController.h"
#import "CommonDef.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define TAG_SEARCH_WATCH    2017

@interface SyncDeviceViewController ()

@end

@implementation SyncDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.imageView.layer.cornerRadius = 60.f;
    self.imageView.layer.borderColor = COMMON_HEADER_BORDER_COLOR.CGColor;
    self.imageView.layer.borderWidth = 4.f;
    self.imageView.layer.masksToBounds = YES;
    
    self.label1.adjustsFontSizeToFitWidth = YES;
    
    self.navigationItem.title = LOC_STR(@"Sync");
    
    self.label1.text = LOC_STR(@"Would you like to sync now?");
    [self.button1 setTitle:LOC_STR(@"Yes, please") forState:
     UIControlStateNormal];
    self.button2.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.button2 setTitle:LOC_STR(@"No, go to dashboard") forState:UIControlStateNormal];
    
    self.button3.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.button3 setTitle:LOC_STR(@"Add another watch") forState:UIControlStateNormal];
    
    if ([GlobalCache shareInstance].currentKid) {
        self.nameLabel.text = [GlobalCache shareInstance].currentKid.name;
        if ([GlobalCache shareInstance].currentKid.profile) {
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:[GlobalCache shareInstance].currentKid.profile]]];
        }
    }
    else {
        self.nameLabel.text = nil;
    }
    
    [self setCustomBackBarButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userProfileLoaded:) name:USER_PROFILE_LOAD_NOTI object:nil];
    
    if (![GlobalCache shareInstance].currentKid) {
        //当前用户没有绑定设备，执行查询
        [[GlobalCache shareInstance] queryProfile];
        [[GlobalCache shareInstance] querySharedDevice];
    }
}

- (void)userProfileLoaded:(NSNotification*)notification {
    if (![GlobalCache shareInstance].currentKid) {
        //确认当前用户没有绑定设备
        self.label1.text = LOC_STR(@"You have not bind device yet.");
        self.button1.tag = TAG_SEARCH_WATCH;
        [self.button1 setTitle:LOC_STR(@"Search a watch") forState:UIControlStateNormal];
        [self.button2 setTitle:LOC_STR(@"Go to dashboard") forState:UIControlStateNormal];
        self.button3.hidden = YES;
    }
    else {
        self.nameLabel.text = [GlobalCache shareInstance].currentKid.name;
        if ([GlobalCache shareInstance].currentKid.profile) {
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:[GlobalCache shareInstance].currentKid.profile]]];
        }
        
        self.label1.text = LOC_STR(@"Would you like to sync now?");
        [self.button1 setTitle:LOC_STR(@"Yes, please") forState:
         UIControlStateNormal];
        self.button2.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.button2 setTitle:LOC_STR(@"No, go to dashboard") forState:UIControlStateNormal];
        
        self.button3.titleLabel.adjustsFontSizeToFitWidth = YES;
        [self.button3 setTitle:LOC_STR(@"Add another watch") forState:UIControlStateNormal];
    }
}

- (void)backAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)syncAnotherAction:(id)sender {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"SearchWatch"];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (IBAction)goDashboardAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)syncCurrentAction:(UIButton*)sender {
    if (self.button1.tag == TAG_SEARCH_WATCH) {
        [self syncAnotherAction:sender];
        return;
    }
    if ([GlobalCache shareInstance].currentKid) {
        UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"SyncDevice" bundle:nil];
        UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"Syncing"];
        [self.navigationController pushViewController:ctl animated:YES];
    }
    else {
        [SVProgressHUD showErrorWithStatus:LOC_STR(@"you have not bind device yet, please sync a watch.")];
    }
    
    
}

@end
