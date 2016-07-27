//
//  SearchWatchViewController.m
//  Swing
//
//  Created by Mapple on 16/7/21.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SearchWatchViewController.h"

@interface SearchWatchViewController ()

@end

@implementation SearchWatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performSelector:@selector(nextAction) withObject:nil afterDelay:3];
}

- (void)nextAction {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"SelectWatch"];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (IBAction)unwindSegueToSearchViewController:(UIStoryboardSegue *)segue {
    
}

@end
