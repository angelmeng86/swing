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
    
    self.progressView.progressTotal = 12;
    self.progressView.progressCounter = 1;
    self.progressView.clockwise = NO;
    self.progressView.theme.completedColor = COMMON_TITLE_COLOR;
    self.progressView.theme.incompletedColor = [UIColor whiteColor];
    self.progressView.theme.thickness = 15;
    self.progressView.theme.sliceDividerHidden = YES;
    self.progressView.label.hidden = YES;
    [self.progressView setIsIndeterminateProgress:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.progressView.isIndeterminateProgress = YES;
    
    
    [self performSelector:@selector(nextAction) withObject:nil afterDelay:1];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.progressView.isIndeterminateProgress = NO;
}

- (void)nextAction {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"SelectWatch"];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (IBAction)unwindSegueToSearchViewController:(UIStoryboardSegue *)segue {
    
}

@end
