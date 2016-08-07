//
//  GlobalCache.m
//  GmatProject
//
//  Created by Mapple on 15-6-10.
//  Copyright (c) 2015年 Yan Cui. All rights reserved.
//

#import "GlobalCache.h"
#import "KeyboardManager.h"

@implementation GlobalCache

+ (GlobalCache*)shareInstance
{
    static GlobalCache* globalCache = nil;
    if (globalCache == nil) {
        globalCache = [[GlobalCache alloc] init];
    }
    return globalCache;
}

- (void)setKeyboradManager {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.shouldResignOnTouchOutside = YES;
    manager.enableAutoToolbar = NO;
    
    //    [manager disableInViewControllerClass:[TagImageViewController class]];
    //    [manager disableInViewControllerClass:[PhotoDetailViewController class]];
    //    [manager disableInViewControllerClass:[LCUserFeedbackViewController class]];
}

- (void)initConfig {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [self setKeyboradManager];
    
    NSString *json = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    _info = [[LoginedModel alloc] initWithString:json error:nil];
    
    json = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    _user = [[UserModel alloc] initWithString:json error:nil];
}

- (void)setInfo:(LoginedModel *)info {
    _info = info;
    [[NSUserDefaults standardUserDefaults] setObject:[_info toJSONString] forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setUser:(UserModel *)user {
    _user = user;
    [[NSUserDefaults standardUserDefaults] setObject:[_user toJSONString] forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveInfo {
    [[NSUserDefaults standardUserDefaults] setObject:[_info toJSONString] forKey:@"token"];
    [[NSUserDefaults standardUserDefaults] setObject:[_user toJSONString] forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)logout {
    [[SwingClient sharedClient] invalidateSessionCancelingTasks:YES];
    self.info = nil;
    self.user = nil;
    self.kidsList = nil;
    [self.calendarEventsByMonth removeAllObjects];
    [self.calendarQueue removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[SwingClient sharedClient] logout];
}

- (void)queryKids {
    self.kidsTask = [[SwingClient sharedClient] kidsListWithCompletion:^(NSArray *list, NSError *error) {
        if (error) {
            LOG_D(@"kidsListWithCompletion fail: %@", error);
        }
        else {
            self.kidsList = list;
            [[NSNotificationCenter defaultCenter] postNotificationName:KIDS_LIST_LOAD_NOTI object:list];
        }
    }];
}

//- (NSMutableDictionary*)calendarEventsByDate {
//    if (_calendarEventsByDate == nil) {
//        _calendarEventsByDate = [[NSMutableDictionary alloc] init];
//    }
//    return _calendarEventsByDate;
//}

- (NSMutableDictionary*)calendarEventsByMonth {
    if (_calendarEventsByMonth == nil) {
        _calendarEventsByMonth = [[NSMutableDictionary alloc] init];
    }
    return _calendarEventsByMonth;
}

- (NSMutableSet*)calendarQueue {
    if (_calendarQueue == nil) {
        _calendarQueue = [[NSMutableSet alloc] init];
    }
    return _calendarQueue;
}

- (NSString*)dateToMonthString:(NSDate*)date {
    static NSDateFormatter *df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM"];
    }
    return [df stringFromDate:date];
}

- (NSString*)dateToDayString:(NSDate*)date {
    static NSDateFormatter *df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
    }
    return [df stringFromDate:date];
}

- (NSArray*)searchEventsByDay:(NSDate*)date {
    NSString *month = [self dateToMonthString:date];
    if (self.calendarEventsByMonth[month]) {
        NSString *key = [self dateToDayString:date];
        return self.calendarEventsByMonth[month][key];
    }
    return nil;
}

- (void)queryMonthEvents:(NSDate*)date {
    NSString *month = [self dateToMonthString:date];
    if ([self.calendarQueue containsObject:month]) {
        LOG_D(@"containsObject date: %@", month);
        return;
    }
    
    [[SwingClient sharedClient] calendarGetEvents:date type:GetEventTypeMonth completion:^(NSArray *eventArray, NSError *error) {
        if (error) {
            LOG_D(@"calendarGetEvents fail: %@", error);
        }
        else {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            self.calendarEventsByMonth[month] = dict;
            
            for (EventModel *model in eventArray) {
                NSString *key = [self dateToDayString:model.startDate];
                if(!dict[key]){
                    dict[key] = [NSMutableArray new];
                }
                
                [dict[key] addObject:model];
            }
            
//            for (EventModel *model in eventArray) {
//                NSString *key = [self dateToDayString:model.startDate];
//                if(!self.calendarEventsByDate[key]){
//                    self.calendarEventsByDate[key] = [NSMutableArray new];
//                }
//                
//                [self.calendarEventsByDate[key] addObject:model];
//            }
            [self.calendarQueue removeObject:month];
            [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_LIST_UPDATE_NOTI object:month];
        }
    }];
}

- (void)addEvent:(EventModel*)model {
    NSString *month = [self dateToMonthString:model.startDate];
    NSMutableDictionary *dict = self.calendarEventsByMonth[month];
    if (!dict) {
        dict = [NSMutableDictionary new];
        self.calendarEventsByMonth[month] = dict;
    }
    NSString *key = [self dateToDayString:model.startDate];
    if(!dict[key]){
        dict[key] = [NSMutableArray new];
    }
    [dict[key] addObject:model];
}

- (void)deleteEvent:(EventModel*)model {
    NSString *month = [self dateToMonthString:model.startDate];
    NSString *key = [self dateToDayString:model.startDate];
    NSMutableArray *array = self.calendarEventsByMonth[month][key];
    for (int i = (int)array.count; --i >= 0;) {
        EventModel* m = array[i];
        if (model.objId == m.objId) {
            [array removeObjectAtIndex:i];
            return;
        }
    }
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *month = [self dateToMonthString:date];
    NSString *key = [self dateToDayString:date];
        
    if(self.calendarEventsByMonth[month][key] && [self.calendarEventsByMonth[month][key] count] > 0){
        return YES;
    }
    
    return NO;
    
}

- (id)init
{
    if (self = [super init]) {

    }
    return self;
}

@end
