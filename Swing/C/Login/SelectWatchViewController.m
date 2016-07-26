//
//  SelectWatchViewController.m
//  Swing
//
//  Created by Mapple on 16/7/21.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "SelectWatchViewController.h"
#import "DeviceTableViewCell.h"

@interface SelectWatchViewController ()<DeviceTableViewCellDelegate>

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
    cell.delegate = self;
    if (indexPath.row == 0) {
        cell.titleLabel.text = @"SWING WATCH 123DAF523";
    }
    else {
        cell.titleLabel.text = @"SWING WATCH 568DANG5E";
    }
    
    return cell;
}

- (void)deviceTableViewCellDidClicked:(DeviceTableViewCell*)cell {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"LoginFlow" bundle:nil];
    UIViewController *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"KidBind"];
    [self.navigationController pushViewController:ctl animated:YES];
}

@end
