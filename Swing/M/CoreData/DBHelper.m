//
//  DBHelper.m
//  Swing
//
//  Created by Mapple on 2016/11/19.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "DBHelper.h"
#import "CommonDef.h"


@interface DBHelper ()
{
    NSArray *repeatTypes;
}

@property (nonatomic, strong) NSMutableArray *repeatEventModels;

@end

@implementation DBHelper

+ (DBHelper*)privateInstance
{
    static DBHelper* globalCache = nil;
    if (globalCache == nil) {
        globalCache = [[DBHelper alloc] init];
    }
    return globalCache;
}

- (id)init {
    if (self = [super init]) {
        repeatTypes = @[@"DAILY", @"WEEKLY"];
        [self reloadRepeatEvent];
    }
    return self;
}

- (void)reloadRepeatEvent {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"repeat != ''"];
    NSArray *array = [Event MR_findAllWithPredicate:predicate];
    self.repeatEventModels = [NSMutableArray array];
    for (Event *e in array) {
        EventModel *model = [EventModel new];
        [model updateFrom:e];
        [_repeatEventModels addObject:model];
    }
}

- (void)addRepeatEventModel:(EventModel*)model {
    if ([repeatTypes containsObject:model.repeat]) {
        for (int i = (int)_repeatEventModels.count; --i >= 0; ) {
            EventModel *m = _repeatEventModels[i];
            if (m.objId == model.objId) {
                [_repeatEventModels replaceObjectAtIndex:i withObject:model];
                LOG_D(@"replace repeat event %lld", model.objId);
                return;
            }
        }
        [_repeatEventModels addObject:model];
        LOG_D(@"add repeat event %lld", model.objId);
    }
}

- (void)removeRepeatEventModel:(int64_t)objId repeat:(NSString*)repeat {
    for (EventModel *m in _repeatEventModels) {
        if (m.objId == objId) {
            [_repeatEventModels removeObject:m];
            LOG_D(@"remove repeat event %lld", m.objId);
            break;
        }
    }
}

- (void)insertRepeatEventModel:(NSMutableArray*)array date:(NSDate*)date ascending:(BOOL)ascend {
    NSComparisonResult compareRet = ascend ? NSOrderedDescending : NSOrderedAscending;
    NSDateComponents *comps = [[DBHelper calendar] components:NSCalendarUnitWeekday fromDate:date];
    for (int i = (int)_repeatEventModels.count; --i >= 0; ) {
        EventModel *model = _repeatEventModels[i];
        BOOL inserted = NO;
        if ([model.repeat isEqualToString:@"DAILY"]) {
            for (int j = (int)array.count; --j >= 0; ) {
                EventModel *m = array[j];
                if (compareRet == [Fun compareTimePart:model.startDate andDate:m.startDate]) {
                    [array insertObject:model atIndex:j + 1];
                    inserted = YES;
//                    LOG_D(@"insert daily event %lld into date[%@]", m.objId, date);
                    break;
                }
            }
            if (!inserted) {
                [array insertObject:model atIndex:0];
            }
        }
        else if([model.repeat isEqualToString:@"WEEKLY"]) {
            NSDateComponents *comps2 = [[DBHelper calendar] components:NSCalendarUnitWeekday fromDate:model.startDate];
            if (comps.weekday == comps2.weekday) {
                BOOL inserted = NO;
                for (int j = (int)array.count; --j >= 0; ) {
                    EventModel *m = array[j];
                    if (compareRet == [Fun compareTimePart:model.startDate andDate:m.startDate]) {
                        [array insertObject:model atIndex:j + 1];
                        inserted = YES;
//                        LOG_D(@"insert weekly event %lld into date[%@]", m.objId, date);
                        break;
                    }
                }
                if (!inserted) {
                    [array insertObject:model atIndex:0];
                }
            }
        }
        else {
            [_repeatEventModels removeObjectAtIndex:i];
            LOG_D(@"clear normal event %lld", model.objId);
        }
        
    }
    
}

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
    [Activity MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+ (BOOL)addEvent:(EventModel*)model {
    BOOL ret = [self addEvent:model save:YES];
    if (model.repeat.length > 0) {
        [[DBHelper privateInstance] addRepeatEventModel:model];
    }
    return ret;
}

+ (BOOL)addTodo:(ToDoModel*)model {
    Todo *todo = [Todo MR_findFirstByAttribute:@"objId" withValue:@(model.objId)];
    if (todo) {
        LOG_D(@"update Todo %lld", todo.objId);
    }
    else {
        LOG_D(@"create Todo %lld", model.objId);
        todo = [Todo MR_createEntity];
    }
    [model updateTo:todo];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return YES;
}

+ (BOOL)delEvent:(int64_t)objId {
    BOOL ret = NO;
    Event *event = [Event MR_findFirstByAttribute:@"objId" withValue:@(objId)];
    if (event) {
        LOG_D(@"delete Event %lld", event.objId);
        NSString *repeat = event.repeat;
        ret = [event MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        if (ret && repeat.length > 0) {
            [[DBHelper privateInstance] removeRepeatEventModel:objId repeat:repeat];
        }
    }
    return ret;
}

+ (BOOL)addEvent:(EventModel*)model save:(BOOL)save {
    Event *event = [Event MR_findFirstByAttribute:@"objId" withValue:@(model.objId)];
    if (event) {
        LOG_D(@"update Event %lld", event.objId);
    }
    else {
        LOG_D(@"create Event %lld", model.objId);
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
    [[DBHelper privateInstance] reloadRepeatEvent];
    return YES;
}

+ (NSArray*)queryEventModelByDay:(NSDate*)date
{
    return [DBHelper queryEventModelByDay:date ascending:YES];
}

+ (NSArray*)queryEventModelByDay:(NSDate*)date ascending:(BOOL)ascend
{
    NSDateComponents *comps = [[DBHelper calendar] components:NSCalendarUnitYear|NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDate *oneDay = [[DBHelper calendar] dateFromComponents:comps];
    NSDate *nextDay = [oneDay dateByAddingTimeInterval:24*60*60];
    
    NSPredicate *predicate_date = [NSPredicate predicateWithFormat:@"startDate >= %@ AND startDate < %@ AND repeat == ''", oneDay,nextDay];
    NSArray *array = [Event MR_findAllSortedBy:@"startDate" ascending:ascend withPredicate:predicate_date];
    NSMutableArray *list = [NSMutableArray array];
    if(array.count > 0) {
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
    }
    [[DBHelper privateInstance] insertRepeatEventModel:list date:date ascending:ascend];
    return list;
}

+ (NSArray*)queryNearAlertEventModel:(int)limit {
//    NSDateComponents *comps = [[DBHelper calendar] components:NSYearCalendarUnit|NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
//    NSDate *oneDay = [[DBHelper calendar] dateFromComponents:comps];
//    NSLog(@"oneDay:%@", oneDay);
    NSPredicate *predicate_date = [NSPredicate predicateWithFormat:@"startDate > %@ AND alert > 35 AND repeat == ''", [NSDate date]];
    
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

+ (NSMutableArray*)queryActivityModel {
    NSArray *array = [Activity MR_findAllSortedBy:@"time" ascending:YES];
    if(array.count > 0) {
        NSMutableArray *list = [NSMutableArray array];
        for (Activity *e in array) {
            ActivityModel *model = [ActivityModel new];
            [model updateFrom:e];
            model.obj = e;
            [list addObject:model];
        }
        return list;
    }
    return nil;
}

+ (BOOL)addActivity:(ActivityModel*)model {
    if (model.obj) {
        return NO;
    }
    Activity *m = [Activity MR_createEntity];
    [model updateTo:m];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    model.obj = m;
    LOG_D(@"create Activity %@", m.objectID);
    return YES;
}

+ (BOOL)delObject:(NSManagedObject*)obj {
    if (obj) {
        LOG_D(@"del Object %@", obj.objectID);
        [obj MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        return YES;
    }
    return NO;
}

@end
