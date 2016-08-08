//
//  GlobalCache.h
//  GmatProject
//
//  Created by Mapple on 15-6-10.
//  Copyright (c) 2015年 Yan Cui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonDef.h"

#define KIDS_LIST_LOAD_NOTI @"KIDS_LIST_LOAD_NOTI"
#define EVENT_LIST_UPDATE_NOTI @"EVENT_LIST_UPDATE_NOTI"

@interface GlobalCache : NSObject

+ (GlobalCache*)shareInstance;

- (void)initConfig;

- (void)saveInfo;

- (void)queryKids;

- (void)logout;

- (NSString*)dateToMonthString:(NSDate*)date;

- (NSArray*)searchEventsByDay:(NSDate*)date;

- (void)queryMonthEvents:(NSDate*)date;

- (void)addEvent:(EventModel*)model;

- (void)deleteEvent:(EventModel*)model;

- (BOOL)haveEventForDay:(NSDate *)date;

@property (strong, nonatomic) LoginedModel* info;
@property (strong, nonatomic) UserModel* user;

@property (strong, nonatomic) NSArray* kidsList;
@property (strong, nonatomic) NSURLSessionDataTask *kidsTask;

@property (strong, nonatomic) NSMutableDictionary* calendarEventsByMonth;
@property (strong, nonatomic) NSMutableSet* calendarQueue;

@end
