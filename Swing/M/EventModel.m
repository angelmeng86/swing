//
//  EventModel.m
//  Swing
//
//  Created by Mapple on 16/7/31.
//  Copyright © 2016年 zzteam. All rights reserved.
//

#import "EventModel.h"
#import "CommonDef.h"

@implementation EventModel

+ (JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"objId",
                                                       @"name": @"eventName",
                                                       @"description": @"desc",
                                                       }];
}

- (void)updateTo:(Event*)event {
    event.objId = _objId;
    event.eventName = _eventName;
    event.startDate = _startDate;
    event.endDate = _endDate;
    event.timezoneOffset = _timezoneOffset;
    event.color = _color;
    event.status = _status;
    event.desc = _desc;
    event.alert = _alert;
    event.city = _city;
    event.state = _state;
    event.repeat = _repeat;
    
    for (Todo *t in event.todoList) {
        LOG_D(@"del todo:%lld", t.objId);
        [t MR_deleteEntity];
    }
    if (event.todoList) {
        [event removeTodoList:event.todoList];
    }
    for (ToDoModel *m in _todo) {
        Todo *t = [Todo MR_createEntity];
        [m updateTo:t];
        [event addTodoListObject:t];
    }
    
    for (EventKid *k in event.kidList) {
        LOG_D(@"del event kid:%lld", k.objId);
        [k MR_deleteEntity];
    }
    if (event.kidList) {
        [event removeKidList:event.kidList];
    }
    for (KidModel *m in _kid) {
        EventKid *k = [EventKid MR_createEntity];
        [m updateTo2:k];
        [event addKidListObject:k];
    }
}

- (void)updateFrom:(Event*)event {
    self.objId = event.objId;
    self.eventName = event.eventName;
    self.startDate = event.startDate;
    self.endDate = event.endDate;
    self.timezoneOffset = event.timezoneOffset;
    self.color = event.color;
    self.status = event.status;
    self.desc = event.desc;
    self.alert = event.alert;
    self.city = event.city;
    self.state = event.state;
    self.repeat = event.repeat;
    
    if (event.todoList) {
        NSMutableArray *array = [NSMutableArray array];
        for (Todo *t in event.todoList) {
            ToDoModel *m = [ToDoModel new];
            [m updateFrom:t];
            [array addObject:m];
        }
        [array sortUsingComparator:^NSComparisonResult(ToDoModel *obj1, ToDoModel *obj2) {
            if (obj1.objId < obj2.objId) {
                return NSOrderedAscending;
            }
            else if (obj1.objId > obj2.objId) {
                return NSOrderedDescending;
            }
            return NSOrderedSame;
        }];
        self.todo = (NSArray<ToDoModel>*)array;
    }
    
    if (event.kidList) {
        NSMutableArray *array = [NSMutableArray array];
        for (EventKid *t in event.kidList) {
            KidModel *m = [KidModel new];
            [m updateFrom2:t];
            [array addObject:m];
        }
        self.kid = (NSArray<KidModel>*)array;
    }
}

- (NSDate*)minEndDate
{
    NSTimeInterval ti = [self.endDate timeIntervalSinceDate:self.startDate];
    //判断时间间隔小于30分钟
    if (ti < 1800) {
        NSDate *end = [self.startDate dateByAddingTimeInterval:1800];
        if([[NSCalendar currentCalendar] isDate:self.startDate inSameDayAsDate:end]) {
            return end;
        }
        else {
            NSDateComponents *comps = [[NSCalendar currentCalendar] components:kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:self.startDate];
            comps.hour = 23;
            comps.minute = 59;
            comps.second = 59;
            return [[NSCalendar currentCalendar] dateFromComponents:comps];
        }
    }
    else {
        return self.endDate;
    }
}

@end
