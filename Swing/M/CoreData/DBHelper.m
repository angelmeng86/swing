//
//  DBHelper.m
//  Swing
//
//  Created by Mapple on 2016/11/19.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "DBHelper.h"
#import "CommonDef.h"

@implementation DBHelper

+ (NSCalendar*)calendar {
    static NSCalendar *cal = nil;
    if (cal == nil) {
        cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return cal;
}

+ (void)clearDatabase {
    [Event MR_truncateAll];
    [Todo MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+ (BOOL)addEvent:(EventModel*)model {
    return [self addEvent:model save:YES];
}

+ (BOOL)addTodo:(ToDoModel*)model {
    Todo *todo = [Todo MR_findFirstByAttribute:@"objId" withValue:@(model.objId)];
    if (todo) {
        LOG_D(@"update Todo %d", todo.objId);
    }
    else {
        LOG_D(@"create Todo %d", model.objId);
        todo = [Todo MR_createEntity];
    }
    [model updateTo:todo];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return YES;
}

+ (BOOL)delEvent:(int)objId {
    Event *event = [Event MR_findFirstByAttribute:@"objId" withValue:@(objId)];
    if (event) {
        LOG_D(@"delete Event %d", event.objId);
        [event MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    return NO;
}

+ (BOOL)addEvent:(EventModel*)model save:(BOOL)save {
    Event *event = [Event MR_findFirstByAttribute:@"objId" withValue:@(model.objId)];
    if (event) {
        LOG_D(@"update Event %d", event.objId);
    }
    else {
        LOG_D(@"create Event %d", model.objId);
        event = [Event MR_createEntity];
    }
    [model updateTo:event];
    if (save) {
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    return YES;
}

+ (BOOL)addEvents:(NSArray*)array {
    if (array.count == 0) {
        return NO;
    }
    for (EventModel *m in array) {
        [self addEvent:m save:NO];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return YES;
}

+ (NSArray*)queryEventModelByDay:(NSDate*)date {
    NSDateComponents *comps = [[DBHelper calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDate *oneDay = [[DBHelper calendar] dateFromComponents:comps];
    NSDate *nextDay = [oneDay dateByAddingTimeInterval:24*60*60];
    
    NSPredicate *predicate_date = [NSPredicate predicateWithFormat:@"startDate >= %@ AND startDate < %@", oneDay,nextDay];
    NSArray *array = [Event MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:predicate_date];
    if(array.count > 0) {
        NSMutableArray *list = [NSMutableArray array];
        for (Event *e in array) {
            EventModel *model = [EventModel new];
            [model updateFrom:e];
            [list addObject:model];
//            for (Todo *t in e.todoList) {
//                NSLog(@"objId:%d,text:%@,status:%@", t.objId, t.text,t.status);
//            }
//            NSLog(@"OYE");
//            for (ToDoModel *t in model.todo) {
//                NSLog(@"objId:%d,text:%@,status:%@", t.objId, t.text,t.status);
//            }
        }
        return list;
    }
    return nil;
}

+ (NSArray*)queryNearAlertEventModel:(int)limit {
//    NSDateComponents *comps = [[DBHelper calendar] components:NSYearCalendarUnit|NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
//    NSDate *oneDay = [[DBHelper calendar] dateFromComponents:comps];
//    NSLog(@"oneDay:%@", oneDay);
    NSPredicate *predicate_date = [NSPredicate predicateWithFormat:@"startDate > %@ AND alert > 35", [NSDate date]];
    
    NSFetchRequest *request = [Event MR_requestAllSortedBy:@"startDate"
                                                ascending:YES
                                            withPredicate:predicate_date
                                                inContext:[NSManagedObjectContext MR_defaultContext]];
    request.fetchLimit = limit;
    NSArray *array =  [Event MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
//    NSArray *array = [Event MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:predicate_date];
    if(array.count > 0) {
        NSMutableArray *list = [NSMutableArray array];
        for (Event *e in array) {
            EventModel *model = [EventModel new];
            [model updateFrom:e];
            [list addObject:model];
            LOG_D(@"model date %@, name %@, alert %d", model.startDate, model.eventName, model.alert);
        }
        return list;
    }
    return nil;
}

@end
