//
//  EventInfoViewController.m
//  Swing
//
//  Created by Mapple on 16/8/1.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "EventInfoViewController.h"
#import "EventSelectTableViewCell.h"
#import "CommonDef.h"

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
    
    if (_model) {
        self.titleLabel.text = [self getTitle];
        self.descLabel.text = _model.desc;
    }
    self.navigationItem.rightBarButtonItem = nil;
}

- (NSString*)getTitle {
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"HH:mm";
    }
    NSMutableString *info = [NSMutableString string];
    [info appendString:[dateFormatter stringFromDate:_model.startDate]];
    [info appendString:@"-"];
    [info appendString:[dateFormatter stringFromDate:_model.endDate]];
    [info appendString:@" "];
    [info appendString:_model.eventName];
    return info;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _model.todo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"EventCell";
    
    EventSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell.
    ToDoModel *model = _model.todo[indexPath.row];
    cell.contentLabel.text = model.text;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    EventSelectTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
}

- (IBAction)saveAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
