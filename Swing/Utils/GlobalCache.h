//
//  GlobalCache.h
//  GmatProject
//
//  Created by Mapple on 15-6-10.
//  Copyright (c) 2015年 Yan Cui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonDef.h"
#import "JSONModel.h"

#define USER_PROFILE_LOAD_NOTI @"USER_PROFILE_LOAD_NOTI"
#define KIDS_LIST_LOAD_NOTI @"KIDS_LIST_LOAD_NOTI"
#define EVENT_LIST_UPDATE_NOTI @"EVENT_LIST_UPDATE_NOTI"
#define WEATHER_UPDATE_NOTI @"WEATHER_UPDATE_NOTI"

@interface GlobalCache : NSObject

+ (GlobalCache*)shareInstance;

- (void)initConfig;

- (void)saveInfo;

- (void)queryProfile;
//- (void)queryKids;
- (void)queryWeather;

- (void)logout;

+ (NSString*)dateToMonthString:(NSDate*)date;
+ (NSString*)dateToDayString:(NSDate*)date;

- (NSArray*)searchEventsByDay:(NSDate*)date;
- (NSMutableArray*)searchWeeklyEventsByDay:(NSDate*)date;

- (void)queryMonthEvents:(NSDate*)date;

- (void)addEvent:(EventModel*)model;

- (void)deleteEvent:(EventModel*)model;

//- (BOOL)haveEventForDay:(NSDate *)date;
- (NSArray*)queryEventColorForDay:(NSDate *)date;

@property (strong, nonatomic) LoginedModel* info;
@property (strong, nonatomic) UserModel* user;
@property (strong, nonatomic) LMLocalData* local;

@property (nonatomic) int battery;

@property (strong, nonatomic) WeatherModel* wearther;
@property (nonatomic) BOOL weartherRunning;

@property (strong, nonatomic) NSArray* kidsList;

@property (strong, nonatomic) NSMutableDictionary* calendarEventsByMonth;
@property (strong, nonatomic) NSMutableSet* calendarQueue;

@end
