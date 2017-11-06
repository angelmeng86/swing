//
//  MutiRequestViewController.m
//  Swing
//
//  Created by Mapple on 2017/11/5.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "MutiRequestViewController.h"
#import "MutiShareToViewController.h"
#import "CommonDef.h"

@interface MutiRequestViewController ()

@end

@implementation MutiRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.layer.cornerRadius = 50.f;
    self.imageView.layer.borderColor = COMMON_HEADER_BORDER_COLOR.CGColor;
    self.imageView.layer.borderWidth = 3.f;
    self.imageView.layer.masksToBounds = YES;
    
    self.imageView2.layer.cornerRadius = 50.f;
    self.imageView2.layer.borderColor = COMMON_HEADER_BORDER_COLOR.CGColor;
    self.imageView2.layer.borderWidth = 3.f;
    self.imageView2.layer.masksToBounds = YES;
    [self loadInfo];
}

- (void)loadInfo
{
    switch (_type) {
        case MutiRequestTypePending:
        {
            self.title = LOC_STR(@"Request to");
            
            self.titleLabel.text = LOC_STR(@"PENGDING");
            self.subTitleLabel.text = [NSString stringWithFormat: LOC_STR(@"You've requested access to %@'s watch."), self.subHost.requestToUser.fullName];
            
            if (self.subHost.requestFromUser.profile) {
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.subHost.requestFromUser.profile]]];
            }
            if (self.subHost.requestToUser.profile) {
                [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.subHost.requestToUser.profile]]];
            }
            
            self.iconView.image = LOAD_IMAGE(@"icon_line_arrow_r");
            
            self.button1.hidden = NO;
            [self.button1 setTitle:LOC_STR(@"Cancel request") forState:UIControlStateNormal];
            self.button2.hidden = YES;
            self.button3.hidden = YES;
        }
            break;
        case MutiRequestTypePendingCancel:
        {
            self.titleLabel.text = LOC_STR(@"Are you sure want to cancel this request?");
            self.subTitleLabel.text = nil;
            
            self.button1.hidden = NO;
            [self.button1 setTitle:LOC_STR(@"Yes,I am sure") forState:UIControlStateNormal];
            self.button2.hidden = NO;
            [self.button2 setTitle:LOC_STR(@"No") forState:UIControlStateNormal];
            self.button3.hidden = YES;
        }
            break;
        case MutiRequestTypeFrom:
        {
            self.title = LOC_STR(@"Request from");
            
            self.titleLabel.text = LOC_STR(@"You've got a request");
            self.subTitleLabel.text = [NSString stringWithFormat: LOC_STR(@"You've got a request from %@."), self.subHost.requestFromUser.fullName];
            
            if (self.subHost.requestFromUser.profile) {
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.subHost.requestFromUser.profile]]];
            }
            if (self.subHost.requestToUser.profile) {
                [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.subHost.requestToUser.profile]]];
            }
            
            self.iconView.image = LOAD_IMAGE(@"icon_line_arrow_r");
            
            self.button1.hidden = NO;
            [self.button1 setTitle:LOC_STR(@"Accept") forState:UIControlStateNormal];
            self.button2.hidden = NO;
            [self.button2 setTitle:LOC_STR(@"Decline") forState:UIControlStateNormal];
            self.button3.hidden = YES;
        }
            break;
        case MutiRequestTypeFromDeny:
        {
            self.title = LOC_STR(@"Request to");
            self.titleLabel.text = [NSString stringWithFormat: LOC_STR(@"Are you sure to stop sharing with %@?"), self.subHost.requestFromUser.fullName];
            self.subTitleLabel.text = nil;
            
            if (self.subHost.requestFromUser.profile) {
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.subHost.requestFromUser.profile]]];
            }
            if (self.subHost.requestToUser.profile) {
                [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.subHost.requestToUser.profile]]];
            }
            
            self.iconView.image = LOAD_IMAGE(@"icon_line_arrow_d");
            
            self.button1.hidden = NO;
            [self.button1 setTitle:LOC_STR(@"Yes,I am sure") forState:UIControlStateNormal];
            self.button2.hidden = NO;
            [self.button2 setTitle:LOC_STR(@"No") forState:UIControlStateNormal];
            self.button3.hidden = YES;
        }
            break;
        case MutiRequestTypeShareDone:
        {
            self.title = LOC_STR(@"Request from");
            self.titleLabel.text = LOC_STR(@"Sharing now!");
            self.subTitleLabel.text = nil;
            
            if (self.subHost.requestFromUser.profile) {
                [self.imageView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.subHost.requestFromUser.profile]]];
            }
            if (self.subHost.requestToUser.profile) {
                [self.imageView2 sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.subHost.requestToUser.profile]]];
            }
            
            self.iconView.image = LOAD_IMAGE(@"icon_line_arrow_d");
            
            self.button1.hidden = NO;
            [self.button1 setTitle:LOC_STR(@"Remove") forState:UIControlStateNormal];
            self.button2.hidden = YES;
            self.button3.hidden = YES;
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btn1Action:(id)sender {
    switch (_type) {
        case MutiRequestTypePending:
        {
            _type = MutiRequestTypePendingCancel;
            [self loadInfo];
        }
            break;
        case MutiRequestTypePendingCancel:
        {
            [SVProgressHUD show];
            [[SwingClient sharedClient] subHostDelete:self.subHost.objId completion:^(NSError *error) {
                if (error) {
                    LOG_D(@"subHostDelete fail: %@", error);
                    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                }
                else {
                    [[GlobalCache shareInstance].subHostRequestTo removeObject:self.subHost];
                    [SVProgressHUD showSuccessWithStatus:@""];
                    [self backAction];
                }
            }];
        }
            break;
        case MutiRequestTypeFrom:
        {
            UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
            MutiShareToViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"MutiShareTo"];
            ctl.subHost = self.subHost;
            [self.navigationController pushViewController:ctl animated:YES];
        }
            break;
        case MutiRequestTypeFromDeny:
        {
            [SVProgressHUD show];
            [[SwingClient sharedClient] subHostDeny:self.subHost.objId completion:^(NSError *error) {
                if (error) {
                    LOG_D(@"subHostDeny fail: %@", error);
                    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
                }
                else {
                    [[GlobalCache shareInstance].subHostRequestFrom removeObject:self.subHost];
                    [SVProgressHUD showSuccessWithStatus:@""];
                    [self backAction];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (IBAction)btn2Action:(id)sender {
    switch (_type) {
        case MutiRequestTypePendingCancel:
        case MutiRequestTypeFromDeny:
        {
            [self backAction];
        }
            break;
        case MutiRequestTypeFrom:
        {
            _type = MutiRequestTypeFromDeny;
            [self loadInfo];
        }
            break;
        default:
            break;
    }
}

- (IBAction)btn3Action:(id)sender {
}

@end
