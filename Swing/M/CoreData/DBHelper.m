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

- (BOOL)hasAlertRepeatEvent {
    BOOL has = NO;
    for (int i = (int)_repeatEventModels.count; --i >= 0; ) {
        EventModel *model = _repeatEventModels[i];
        if(![repeatTypes containsObject:model.repeat]) {
            [_repeatEventModels removeObjectAtIndex:i];
            LOG_D(@"clear normal event %lld", model.objId);
            continue;
        }
        if (model.alert <= 35) {
            continue;
        }
        has = YES;
    }
    return has;
}

- (void)appendOneDayAlertEvents:(NSMutableArray*)array date:(NSDate*)date checkDue:(BOOL)checked {
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    for (int i = (int)_repeatEventModels.count; --i >= 0; ) {
        EventModel *model = _repeatEventModels[i];
        NSDateComponents *comps2 = [[NSCalendar currentCalendar] components:kCFCalendarUnitHour|kCFCalendarUnitMinute|kCFCalendarUnitSecond|NSCalendarUnitWeekday fromDate:model.startDate];
        if ([model.repeat isEqualToString:@"DAILY"]) {

        }
        else if([model.repeat isEqualToString:@"WEEKLY"]) {
            if (comps.weekday != comps2.weekday) {
                continue;
            }
            
        }
        else {
            [_repeatEventModels removeObjectAtIndex:i];
            LOG_D(@"clear normal event %lld", model.objId);
            continue;
        }
        if (model.alert <= 35) {
            continue;
        }
        if (checked && NSOrderedDescending != [Fun compareTimePart:model.startDate andDate:date]) {
            //检查当天是否过期
            continue;
        }
        EventModel *newModel = [model copy];
        comps2.year = comps.year;
        comps2.month = comps.month;
        comps2.day = comps.day;
        newModel.startDate = [[NSCalendar currentCalendar] dateFromComponents:comps2];
        [array addObject:newModel];
//        LOG_D(@"date1[%@]~date2[%@]", [Fun dateToString:model.startDate], [Fun dateToString:newModel.startDate]);
    }
}

- (NSMutableArray*)generateEvents:(int)count {
    NSMutableArray *array = [NSMutableArray array];
    if ([self hasAlertRepeatEvent]) {
        int days = 180;
        NSDate *date = [NSDate date];
        [self appendOneDayAlertEvents:array date:date checkDue:YES];
        while (array.count < count) {
            date = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:1 toDate:date options:0];
            [self appendOneDayAlertEvents:array date:date checkDue:NO];
            if(--days < 0) {
                //产生至多days天的repeat event
                break;
            }
        }
    }
    return array;
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
    [KidInfo MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+ (void)saveDatabase
{
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
    //根据传入的limit参数来产生同等数量的repeat event作为备用，最后与normal event进行排序，截取前limit个event返回。
    NSPredicate *predicate_date = [NSPredicate predicateWithFormat:@"startDate > %@ AND alert > 0 AND repeat == ''", [NSDate date]];
    
    NSFetchRequest *request = [Event MR_requestAllSortedBy:@"startDate"
                                                ascending:YES
                                            withPredicate:predicate_date
                                                inContext:[NSManagedObjectContext MR_defaultContext]];
    request.fetchLimit = limit;
    NSArray *array =  [Event MR_executeFetchRequest:request inContext:[NSManagedObjectContext MR_defaultContext]];
//    NSArray *array = [Event MR_findAllSortedBy:@"startDate" ascending:YES withPredicate:predicate_date];
    NSMutableArray *list = [NSMutableArray array];
    for (Event *e in array) {
        EventModel *model = [EventModel new];
        [model updateFrom:e];
        [list addObject:model];
        LOG_D(@"model date %@, name %@, alert %d", model.startDate, model.eventName, model.alert);
    }
    
    NSArray *repeatEvents = [[DBHelper privateInstance] generateEvents:limit];
    [list addObjectsFromArray:repeatEvents];
    [list sortUsingComparator:^NSComparisonResult(EventModel *obj1, EventModel *obj2) {
        return [obj1.startDate compare:obj2.startDate];
    }];
    
//    for (EventModel *em in list) {
//        LOG_D(@"date[%@]", [Fun dateToString:em.startDate]);
//    }
    if (list.count > limit) {
        return [list subarrayWithRange:NSMakeRange(0, limit)];
    }
    return list;
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

+ (KidInfo*)addKid:(KidModel*)model save:(BOOL)save {
    KidInfo *m = [KidInfo MR_findFirstByAttribute:@"objId" withValue:@(model.objId)];
    if (m) {
        LOG_D(@"update KidInfo %lld", m.objId);
    }
    else {
        LOG_D(@"create KidInfo %lld", model.objId);
        m = [KidInfo MR_createEntity];
    }
    [model updateTo:m];
    if (save) {
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    return m;
}

+ (NSArray*)queryKids
{
    return [KidInfo MR_findAll];
}

+ (NSArray*)queryKids:(BOOL)shared
{
    if (shared) {
//        return [KidInfo MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"subHostId > 0"]];
        
        return [KidInfo MR_findAllSortedBy:@"objId" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"subHostId > 0"]];

    }
    else {
//        return [KidInfo MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(subHostId = 0) || (subHostId = nil)"]];
        
        return [KidInfo MR_findAllSortedBy:@"objId" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(subHostId = 0) || (subHostId = nil)"]];
    }
}

+ (KidInfo*)queryKid:(int64_t)kidId
{
    KidInfo *m = [KidInfo MR_findFirstByAttribute:@"objId" withValue:@(kidId)];
    return m;
}

+ (KidInfo*)addKid:(KidModel*)model
{
    return [DBHelper addKid:model save:YES];
}

+ (BOOL)addKids:(NSArray*)array
{
    if (array.count == 0) {
        return NO;
    }
    for (KidModel *m in array) {
        [self addKid:m save:NO];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return YES;
}

+ (BOOL)resetSharedKids:(NSArray*)subHosts;
{
    [KidInfo MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"subHostId > 0"]];
    if (subHosts.count == 0) {
        return NO;
    }
    for (SubHostModel *m in subHosts) {
        for (KidModel *k in m.kids) {
            KidInfo *kid = [self addKid:k save:NO];
            if (kid) {
                kid.subHostId = m.objId;
            }
        }
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    return YES;
}

+ (BOOL)delKid:(int64_t)objId
{
    BOOL ret = NO;
    KidInfo *m = [KidInfo MR_findFirstByAttribute:@"objId" withValue:@(objId)];
    if (m) {
        LOG_D(@"delete KidInfo %lld", m.objId);
        ret = [m MR_deleteEntity];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
    return ret;
}

+ (void)clearKids
{
    [KidInfo MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

@end
