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
    
    self.label1.text = LOC_STR(@"Do you have a Swing Watch?");
    [self.btn1 setTitle:LOC_STR(@"Yes") forState:UIControlStateNormal];
    [self.btn2 setTitle:LOC_STR(@"No") forState:UIControlStateNormal];
    
    [self setCustomBackButton];
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
    if (!isAsked) {
        //Go to search watch
        [self searchWatch];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://kidsdynamic.com"]];
    }
}

- (IBAction)btn2Action:(id)sender {
    if (!isAsked) {
        //Ask to purchase
        isAsked = YES;
        
        self.label1.text = LOC_STR(@"Would you like to purchase one?");

        [self.btn1 setTitle:LOC_STR(@"Yes, please") forState:UIControlStateNormal];
        [self.btn2 setTitle:LOC_STR(@"Continue as a guest") forState:UIControlStateNormal];
    }
    else {
        //Continue as a guest user
        UIStoryboard *stroyBoard = [UIStoryboard storyboardWithName:@"MainTab2" bundle:nil];
        UIViewController *ctl = [stroyBoard instantiateInitialViewController];
        AppDelegate *ad = (AppDelegate*)[UIApplication sharedApplication].delegate;
        ad.window.rootViewController = ctl;
    }
}

- (void)searchWatch {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"SearchWatch"];
    [self.navigationController pushViewController:ctl animated:YES];
}

@end
