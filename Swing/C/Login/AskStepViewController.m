//
//  AskStepViewController.m
//  Swing
//
//  Created by Mapple on 16/7/20.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "AskStepViewController.h"
#import "AppDelegate.h"
#import "CommonDef.h"
#import "RequestAccessViewController.h"

@interface AskStepViewController ()
{
    BOOL isAsked;
}

@end

@implementation AskStepViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isAsked = NO;
    
    self.label1.adjustsFontSizeToFitWidth = YES;
    
    [self changeInfo];
    //[self setCustomBackButton];
}

- (void)changeInfo
{
    switch (_type) {
        case AskTypePurchase:
        {
            self.label1.text = LOC_STR(@"Would you like to purchase one?");
            self.subLabel.hidden = YES;
            
            [self.btn1 setTitle:LOC_STR(@"Yes, please") forState:UIControlStateNormal];
//            [self.btn2 setTitle:LOC_STR(@"Not yet") forState:UIControlStateNormal];
            [self.btn2 setTitle:LOC_STR(@"Request access to others") forState:UIControlStateNormal];
        }
            break;
        case AskTypeWatchRegisted:
        {
            self.label1.text = LOC_STR(@"This Watch has been resgitered");
            self.subLabel.hidden = YES;
            [self.btn1 setTitle:LOC_STR(@"Request access") forState:UIControlStateNormal];
            [self.btn2 setTitle:LOC_STR(@"Contact Us") forState:UIControlStateNormal];
            [self setCustomBackButton];
        }
            break;
        default:
        {
            self.label1.text = LOC_STR(@"Do you have a Swing Watch?");
            self.subLabel.hidden = NO;
            self.subLabel.text = LOC_STR(@"Please have your watch nearby");
            [self.btn1 setTitle:LOC_STR(@"Yes") forState:UIControlStateNormal];
            [self.btn2 setTitle:LOC_STR(@"No") forState:UIControlStateNormal];
        }
            break;
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

- (IBAction)btn1Action:(id)sender {
    switch (_type) {
        case AskTypeHasWatch:
        {
            //Go to search watch
            [self searchWatch];
        }
            break;
        case AskTypePurchase:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[GlobalCache shareInstance].cacheSupportUrl]];
        }
            break;
        case AskTypeWatchRegisted:
        {
            UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
            RequestAccessViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"Access"];
            ctl.type = RequestTypeAccess;
            ctl.kid = self.kid;
            [self.navigationController pushViewController:ctl animated:YES];
        }
            break;
        default:
            break;
    }
}

- (IBAction)btn2Action:(id)sender {
    switch (_type) {
        case AskTypeHasWatch:
        {
            //Ask to purchase
            _type = AskTypePurchase;
            [self changeInfo];
        }
            break;
        case AskTypePurchase:
        {
//            AppDelegate *ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
//            [ad goToMain];
            UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
            UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"SearchEmail"];
            [self.navigationController pushViewController:ctl animated:YES];
        }
            break;
        case AskTypeWatchRegisted:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[GlobalCache shareInstance].cacheSupportUrl]];
        }
            break;
        default:
            break;
    }
}

- (void)searchWatch {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"SearchWatch"];
    [self.navigationController pushViewController:ctl animated:YES];
}

@end
