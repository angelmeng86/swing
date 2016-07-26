//
//  SecondViewController.m
//  Swing
//
//  Created by Mapple on 16/7/13.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testAction:(id)sender {
    UIStoryboard *secondStroyBoard=[UIStoryboard storyboardWithName:@"Test" bundle:nil];
    
    UIViewController *test2obj = [secondStroyBoard instantiateInitialViewController];
    
    [self.navigationController pushViewController:test2obj animated:YES];
}

@end
