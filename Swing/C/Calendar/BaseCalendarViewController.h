//
//  BaseCalendarViewController.h
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "LMBaseViewController.h"
#import <JTCalendar/JTCalendar.h>

@interface BaseCalendarViewController : LMBaseViewController<JTCalendarDelegate>

@property (strong, nonatomic) JTCalendarManager *calendarManager;

@property (nonatomic, strong) NSDate *dateSelected;

- (void)initCalendarManager:(BOOL)weekModeEnabled;

// Getters
- (JTCalendarMenuView *)calendarMenuView; // subclasses to return instance
- (JTHorizontalCalendarView *)calendarContentView; // subclasses to return instance

@end
