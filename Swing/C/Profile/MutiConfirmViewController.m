//
//  MutiConfirmViewController.m
//  Swing
//
//  Created by Mapple on 2017/11/5.
//  Copyright © 2017年 zzteam. All rights reserved.
//

#import "MutiConfirmViewController.h"
#import "CommonDef.h"

@interface MutiConfirmViewController ()

@end

@implementation MutiConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.layer.cornerRadius = 60.f;
    self.imageView.layer.borderColor = COMMON_HEADER_BORDER_COLOR.CGColor;
    self.imageView.layer.borderWidth = 4.f;
    self.imageView.layer.masksToBounds = YES;
    [self loadInfo];
}

- (void)loadInfo
{
    switch (_type) {
        case MutiConfirmTypeSwitch:
        {
            self.title = LOC_STR(@"Switch account");
            if (self.kid) {
                self.titleLabel.text = self.kid.name;
                self.subTitleLabel.text = nil;
                if (self.kid.profile) {
                    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.kid.profile]]];
                }
                
            }
            self.infoLabel.text = LOC_STR(@"Are you sure to switch this account?");
            
            self.button1.hidden = NO;
            [self.button1 setTitle:LOC_STR(@"Yes,I am sure") forState:UIControlStateNormal];
            self.button2.hidden = NO;
            [self.button2 setTitle:LOC_STR(@"Cancel") forState:UIControlStateNormal];
            self.button3.hidden = YES;
        }
            break;
        case MutiConfirmTypeSwitchDone:
        {
            self.infoLabel.text = LOC_STR(@"It's done! You are on this account now.");
            
            self.button1.hidden = YES;
            self.button2.hidden = YES;
            self.button3.hidden = YES;
        }
            break;
        case MutiConfirmTypeRemove:
        {
            self.title = LOC_STR(@"Remove");
            if (self.kid) {
                self.titleLabel.text = self.kid.name;
                self.subTitleLabel.text = nil;
                if (self.kid.profile) {
                    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[AVATAR_BASE_URL stringByAppendingString:self.kid.profile]]];
                }
                
            }
            self.infoLabel.text = LOC_STR(@"Are you sure to remove this account?");
            
            self.button1.hidden = NO;
            [self.button1 setTitle:LOC_STR(@"Yes,I am sure") forState:UIControlStateNormal];
            self.button2.hidden = NO;
            [self.button2 setTitle:LOC_STR(@"Cancel") forState:UIControlStateNormal];
            self.button3.hidden = YES;
        }
            break;
        case MutiConfirmTypeRemoveDone:
        {
            self.infoLabel.text = LOC_STR(@"This account has been removed.");
            
            self.button1.hidden = YES;
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
        case MutiConfirmTypeSwitch:
        {
            _type = MutiConfirmTypeSwitchDone;
            [self loadInfo];
        }
            break;
        case MutiConfirmTypeRemove:
        {
            /*
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
             */
            _type = MutiConfirmTypeRemoveDone;
            [self loadInfo];
        }
            break;
        default:
            break;
    }
}

- (IBAction)btn2Action:(id)sender {
    switch (_type) {
        case MutiConfirmTypeSwitch:
        case MutiConfirmTypeRemove:
        {
            [self backAction];
        }
            break;
        default:
            break;
    }
}

- (IBAction)btn3Action:(id)sender {
}
@end
