//
//  MonthCalendarViewController.h
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "BaseCalendarViewController.h"

@protocol MonthCalendarDelegate <NSObject>

- (void)monthCalendarDidSelected:(NSDate*)date;

@end

@interface MonthCalendarViewController : BaseCalendarViewController

@property (weak, nonatomic) id delegate;

@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTHorizontalCalendarView *calendarContentView;
@property (weak, nonatomic) IBOutlet UIButton *syncBtn;
- (IBAction)syncAction:(id)sender;

@end
