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
//    [[SwingClient sharedClient] invalidateSessionCancelingTasks:YES];
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

- (void)queryProfile {
    [[SwingClient sharedClient] userRetrieveProfileWithCompletion:^(id user, NSArray *kids, NSError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_PROFILE_LOAD_NOTI object:user];
        }
        else {
            LOG_D(@"retrieveProfile fail: %@", error);
            [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
        }
    }];
}

- (void)queryKids {
    [[SwingClient sharedClient] kidsListWithCompletion:^(NSArray *list, NSError *error) {
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

+ (NSString*)dateToMonthString:(NSDate*)date {
    static NSDateFormatter *df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM"];
    }
    return [df stringFromDate:date];
}

+ (NSString*)dateToDayString:(NSDate*)date {
    static NSDateFormatter *df = nil;
    if (df == nil) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
    }
    return [df stringFromDate:date];
}

- (NSArray*)searchEventsByDay:(NSDate*)date {
    NSString *month = [GlobalCache dateToMonthString:date];
    if (self.calendarEventsByMonth[month]) {
        NSString *key = [GlobalCache dateToDayString:date];
        return self.calendarEventsByMonth[month][key];
    }
    return nil;
}

- (void)queryMonthEvents:(NSDate*)date {
    NSString *month = [GlobalCache dateToMonthString:date];
    if ([self.calendarQueue containsObject:month]) {
        LOG_D(@"containsObject date: %@", month);
        return;
    }
    
    [self.calendarQueue addObject:month];
    [[SwingClient sharedClient] calendarGetEvents:date type:GetEventTypeMonth completion:^(NSArray *eventArray, NSError *error) {
        if (error) {
            LOG_D(@"calendarGetEvents fail: %@", error);
        }
        else {
            NSMutableDictionary *dict = [NSMutableDictionary new];
            self.calendarEventsByMonth[month] = dict;
            
            for (EventModel *model in eventArray) {
                NSString *key = [GlobalCache dateToDayString:model.startDate];
                if(!dict[key]){
                    dict[key] = [NSMutableArray new];
                }
                
                [dict[key] addObject:model];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_LIST_UPDATE_NOTI object:month];
        }
        [self.calendarQueue removeObject:month];
    }];
}

- (void)addEvent:(EventModel*)model {
    NSString *month = [GlobalCache dateToMonthString:model.startDate];
    NSMutableDictionary *dict = self.calendarEventsByMonth[month];
    if (!dict) {
        dict = [NSMutableDictionary new];
        self.calendarEventsByMonth[month] = dict;
    }
    NSString *key = [GlobalCache dateToDayString:model.startDate];
    if(!dict[key]){
        dict[key] = [NSMutableArray new];
    }
    [dict[key] addObject:model];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_LIST_UPDATE_NOTI object:month];
}

- (void)deleteEvent:(EventModel*)model {
    NSString *month = [GlobalCache dateToMonthString:model.startDate];
    NSString *key = [GlobalCache dateToDayString:model.startDate];
    NSMutableArray *array = self.calendarEventsByMonth[month][key];
    for (int i = (int)array.count; --i >= 0;) {
        EventModel* m = array[i];
        if (model.objId == m.objId) {
            [array removeObjectAtIndex:i];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:EVENT_LIST_UPDATE_NOTI object:month];
            return;
        }
    }
}

- (BOOL)haveEventForDay:(NSDate *)date
{
    NSString *month = [GlobalCache dateToMonthString:date];
    NSString *key = [GlobalCache dateToDayString:date];
        
    if(self.calendarEventsByMonth[month][key] && [self.calendarEventsByMonth[month][key] count] > 0){
        return YES;
    }
    
    return NO;
}

- (NSArray*)queryEventColorForDay:(NSDate *)date
{
    NSString *month = [GlobalCache dateToMonthString:date];
    NSString *key = [GlobalCache dateToDayString:date];
    
    if(self.calendarEventsByMonth[month][key] && [self.calendarEventsByMonth[month][key] count] > 0){
        NSArray* events = self.calendarEventsByMonth[month][key];
        NSMutableArray *array = [NSMutableArray new];
        for (EventModel *event in events) {
            [array addObject:event.color == nil ? [UIColor redColor] : event.color];
        }
        return array;
    }
    
    return nil;
}

- (void)queryWeather {
    if (_weartherRunning) {
        return;
    }
    _weartherRunning = YES;
    [[RCLocationManager sharedManager] requestUserLocationWhenInUseWithBlockOnce:^(CLLocationManager *manager, CLAuthorizationStatus status) {
        LOG_D(@"status:%d", status);
        [[RCLocationManager sharedManager] retrieveUserLocationWithBlock:^(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
            LOG_D(@"newLocation:%@ oldLocation:%@", newLocation, oldLocation);
            
            if (newLocation) {
                [WeatherModel weatherQuery:[NSString stringWithFormat:@"%f", newLocation.coordinate.latitude] lon:[NSString stringWithFormat:@"%f", newLocation.coordinate.longitude] completion:^(id weather, NSError *error) {
                    if (error) {
                        LOG_D(@"weatherQuery fail: %@", error);
                        _weartherRunning = NO;
                    }
                    else {
                        self.wearther = weather;
                        [[NSNotificationCenter defaultCenter] postNotificationName:WEATHER_UPDATE_NOTI object:weather];
                        _weartherRunning = NO;
                        LOG_D(@"weather:%@", weather);
                    }
                }];
            }
            
        } errorBlock:^(CLLocationManager *manager, NSError *error) {
            LOG_D(@"error:%@", error);
            _weartherRunning = NO;
            [SVProgressHUD showErrorWithStatus:@"User has explicitly denied authorization for this application, or location services are disabled in Settings."];
            [SVProgressHUD dismissWithDelay:1];
        }];
        
    }];
}

- (id)init
{
    if (self = [super init]) {
        _weartherRunning = NO;
    }
    return self;
}

@end
