//
//  AskStepViewController.m
//  Swing
//
//  Created by 刘武忠 on 16/7/20.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "AskStepViewController.h"

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
        
        self.label1.text = @"WOULD YOU LIKE";
        self.label2.text = @"TO PURCHASE ONE?";
        [self.btn1 setTitle:@"Yes, please" forState:UIControlStateNormal];
        [self.btn2 setTitle:@"Continue as a guest user" forState:UIControlStateNormal];
    }
    else {
        //Go to search watch
        [self searchWatch];
    }
}

- (void)searchWatch {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"SearchWatch"];
    [self.navigationController pushViewController:ctl animated:YES];
}

@end
