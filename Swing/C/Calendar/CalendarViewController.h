//
//  CalendarViewController.h
//  Swing
//
//  Created by Mapple on 16/7/17.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "BaseCalendarViewController.h"
@class MDRadialProgressView;
@interface CalendarViewController : BaseCalendarViewController

- (void)eventViewDidAdded:(NSDate*)date;

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarHeight;

@property (weak, nonatomic) IBOutlet UIButton *monthBtn;
@property (weak, nonatomic) IBOutlet UIButton *todayBtn;
@property (weak, nonatomic) IBOutlet UIButton *syncBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet MDRadialProgressView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeHeightConstraint;

- (IBAction)todayAction:(id)sender;
- (IBAction)monthlyAction:(id)sender;
- (IBAction)syncAction:(id)sender;
@end
