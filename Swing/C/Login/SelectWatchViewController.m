//
//  SelectWatchViewController.m
//  Swing
//
//  Created by 刘武忠 on 16/7/21.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SelectWatchViewController.h"
#import "DeviceTableViewCell.h"

@interface SelectWatchViewController ()

@end

@implementation SelectWatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = bgView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"DeviceCell";
    DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.titleLabel.text = @"SWING WATCH 123DAF523";
    }
    else {
        cell.titleLabel.text = @"SWING WATCH 568DANG5E";
    }
    
    return cell;
}

@end
