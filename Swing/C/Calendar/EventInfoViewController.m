//
//  EventInfoViewController.m
//  Swing
//
//  Created by Mapple on 16/8/1.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "EventInfoViewController.h"
#import "EventSelectTableViewCell.h"

@interface EventInfoViewController ()

@end

@implementation EventInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initCalendarManager:YES];
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    self.selectTableView.backgroundView = bgView;
    self.selectTableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"EventCell";
    
    EventSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell.
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    EventSelectTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
}

- (IBAction)saveAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
