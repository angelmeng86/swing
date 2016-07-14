//
//  LMBaseTableViewController2.h
//  GmatProject
//
//  Created by Mapple on 15-5-28.
//  Copyright (c) 2015年 Yan Cui. All rights reserved.
//

#import "LMBaseViewController.h"

@interface LMBaseTableViewController2 : LMBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

- (id)initWithStyle:(UITableViewStyle)style;

@end
