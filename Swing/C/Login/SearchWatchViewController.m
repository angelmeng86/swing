//
//  SearchWatchViewController.m
//  Swing
//
//  Created by 刘武忠 on 16/7/21.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SearchWatchViewController.h"

@interface SearchWatchViewController ()

@end

@implementation SearchWatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSelector:@selector(nextAction) withObject:nil afterDelay:5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nextAction {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"SelectWatch"];
    [self.navigationController pushViewController:ctl animated:YES];
}

@end
