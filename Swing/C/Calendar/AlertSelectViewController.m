//
//  AlertSelectViewController.m
//  Swing
//
//  Created by Mapple on 16/8/11.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "AlertSelectViewController.h"
#import "CommonDef.h"

@interface AlertSelectViewController ()

@property (nonatomic, strong) NSArray *alertArray;

@end

@implementation AlertSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Select Event";//@"Alert";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"json"];
    self.alertArray = [AlertModel arrayOfModelsFromString:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] error:nil];
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
    return _alertArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        //        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont avenirFontOfSize:17];
    }
    
    AlertModel *model = _alertArray[indexPath.row];
    cell.textLabel.text = model.text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(alertSelectViewControllerDidSelected:)]) {
        [_delegate alertSelectViewControllerDidSelected:_alertArray[indexPath.row]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
