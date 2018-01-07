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
+ (void)saveDatabase;

+ (BOOL)addEvent:(EventModel*)model;
+ (BOOL)delEvent:(int64_t)objId;

+ (BOOL)addTodo:(ToDoModel*)model;

+ (BOOL)resetEvents:(NSArray*)array;

+ (NSArray*)queryEventModelByDay:(NSDate*)date;
//+ (NSArray*)queryEventModelByDay:(NSDate*)date ascending:(BOOL)ascend;

+ (NSArray*)queryNearAlertEventModel:(int)limit;

+ (NSMutableArray*)queryActivityModel;

+ (BOOL)addActivity:(ActivityModel*)model;
+ (BOOL)delObject:(NSManagedObject*)obj;

+ (NSArray*)queryKids;
+ (NSArray*)queryKids:(BOOL)shared;

+ (KidInfo*)queryKid:(int64_t)kidId;
+ (KidInfo*)addKid:(KidModel*)kid;
+ (KidInfo*)addKid:(KidModel*)model save:(BOOL)save;

+ (BOOL)resetMyKids:(NSArray*)array;
+ (BOOL)resetSharedKids:(NSArray*)array;
+ (BOOL)delKid:(int64_t)objId;
+ (void)clearKids;

@end
