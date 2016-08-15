//
//  ChoicesViewController.m
//  Swing
//
//  Created by Mapple on 16/8/15.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "ChoicesViewController.h"
#import "CommonDef.h"

@interface ChoicesViewController ()

@end

@implementation ChoicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _textArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        //        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont avenirFontOfSize:17];
    }
    
    cell.textLabel.text = _textArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(choicesViewControllerDidSelected:)]) {
        [_delegate choicesViewControllerDidSelected:_textArray[indexPath.row]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
