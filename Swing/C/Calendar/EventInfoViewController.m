//
//  EventInfoViewController.m
//  Swing
//
//  Created by Mapple on 16/8/1.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "EventInfoViewController.h"
#import "EventSelectTableViewCell.h"
#import "AddEventViewController2.h"
#import "CommonDef.h"

@interface EventInfoViewController ()

@property (nonatomic, strong) NSMutableArray* selected;

@end

@implementation EventInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selected = [NSMutableArray array];
    [self initCalendarManager:YES];
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor clearColor];
    self.selectTableView.backgroundView = bgView;
    self.selectTableView.tableFooterView = [UIView new];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:LOAD_IMAGE(@"edit_btn") style:UIBarButtonItemStylePlain target:self action:@selector(editEventAction)];
    [self reloadData];
//    self.navigationItem.rightBarButtonItem = nil;
    [self.saveBtn setTitle:LOC_STR(@"Save") forState:UIControlStateNormal];
}

- (void)reloadData {
    if (_model) {
        self.titleLabel.text = [self getTitle];
        self.descLabel.text = _model.desc;
    }
    [self.selectTableView reloadData];
}

- (void)editEventAction {
    UIStoryboard *stroyBoard=[UIStoryboard storyboardWithName:@"MainTab" bundle:nil];
    AddEventViewController2 *ctl = [stroyBoard instantiateViewControllerWithIdentifier:@"AddEvent2"];
    ctl.model = self.model;
    ctl.delegate = self;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)eventViewDidAdded:(NSDate*)date {
    [self reloadData];
    self.dateSelected = date;
    [self.calendarManager setDate:date];
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
    if ([model.status isEqualToString:@"DONE"]) {
        [cell update:YES];
    }
    else {
        [cell update:[self.selected containsObject:model]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ToDoModel *model = _model.todo[indexPath.row];
    if ([model.status isEqualToString:@"PENDING"]) {
        
        if ([self.selected containsObject:model]) {
            [self.selected removeObject:model];
        }
        else {
            [self.selected addObject:model];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        EventSelectTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        [cell setSelected:!cell.selected animated:YES];
        
    }
    
//    EventSelectTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    [cell setSelected:YES animated:YES];
}

- (BOOL)uploadDoneInfo {
    ToDoModel *model = [self.selected firstObject];
    if (model == nil) {
        return NO;
    }
    [[SwingClient sharedClient] calendarTodoDone:model.objId eventId:self.model.objId completion:^(NSError *error) {
        if (!error) {
            model.status = @"DONE";
            [DBHelper addTodo:model];
            [self.selected removeObject:model];
            if (![self uploadDoneInfo]) {
                [SVProgressHUD dismiss];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else {
            LOG_D(@"calendarTodoDone fail: %@", error);
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
    return YES;
}

- (IBAction)saveAction:(id)sender {
    
    if (![self uploadDoneInfo]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [SVProgressHUD showWithStatus:@"Saving, please wait..."];
    }
}

- (IBAction)delAction:(id)sender {
    [SVProgressHUD showWithStatus:@"Removing, please wait..."];
    [[SwingClient sharedClient] calendarDeleteEvent:self.model.objId completion:^(NSError *error) {
        if (!error) {
            LOG_D(@"calendarDeleteEvent sucess.");
            [[GlobalCache shareInstance] deleteEvent:self.model];
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            LOG_D(@"calendarDeleteEvent fail: %@", error);
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
}

@end
