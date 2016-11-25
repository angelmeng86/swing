//
//  DBHelper.h
//  Swing
//
//  Created by Mapple on 2016/11/19.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonDef.h"

@interface DBHelper : NSObject

+ (NSCalendar*)calendar;

+ (void)clearDatabase;

+ (BOOL)addEvent:(EventModel*)model;
+ (BOOL)delEvent:(int)objId;

+ (BOOL)addTodo:(ToDoModel*)model;

+ (BOOL)addEvents:(NSArray*)array;

+ (NSArray*)queryEventModelByDay:(NSDate*)date;

+ (NSArray*)queryNearAlertEventModel:(int)limit;

+ (NSMutableArray*)queryActivityModel;

+ (BOOL)addActivity:(ActivityModel*)model;
+ (BOOL)delActivity:(NSManagedObjectID*)objId;

@end
