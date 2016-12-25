//
//  EventInfoViewController.h
//  Swing
//
//  Created by Mapple on 16/8/1.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "BaseCalendarViewController.h"
@class EventModel;
@interface EventInfoViewController : BaseCalendarViewController

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UITableView *selectTableView;

@property (strong, nonatomic) EventModel *model;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

- (IBAction)saveAction:(id)sender;
- (IBAction)delAction:(id)sender;

@end
